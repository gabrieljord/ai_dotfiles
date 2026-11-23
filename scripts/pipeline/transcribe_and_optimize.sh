#!/usr/bin/env bash
# ==============================================================================
# Transcribe and Optimize Dictation Pipeline
# ==============================================================================
# Records audio from microphone until silence, transcribes with whisper.cpp,
# filters and optimizes prompt using local LLM (Ollama), and dispatches to IDE.
# ==============================================================================

set -euo pipefail

# Find and source environment
ENV_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/ai_dotfiles/.env"
if [[ ! -f "$ENV_FILE" ]]; then
    ENV_FILE="$(dirname "$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")")/.env"
fi

if [[ -f "$ENV_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$ENV_FILE"
else
    echo "[WARN] No .env file found. Using default environment values."
fi

# Fallback defaults
TMP_DIR="${AI_TMP_DIR:-/tmp/ai_dotfiles}"
AUDIO_FILE="${TMP_DIR}/input_recording.wav"
TXT_RAW_FILE="${TMP_DIR}/raw_transcript.txt"
WHISPER_BIN="${WHISPER_BIN_PATH:-whisper-cli}"
WHISPER_MODEL="${WHISPER_MODEL_PATH:-$HOME/.local/share/whisper.cpp/models/ggml-large-v3-turbo.bin}"
OLLAMA_URL="${LOCAL_LLM_ENDPOINT:-http://localhost:11434}"
LLM_MODEL="${LLM_MODEL_NAME:-prompt-optimizer:latest}"

mkdir -p "$TMP_DIR"

log() { printf "[ai-dictate] %s\n" "$*"; }

usage() {
    cat <<EOF
ai-dictate: Record audio, transcribe via Whisper, optimize prompt via LLM, and paste to IDE.

Usage: $(basename "$0") [OPTIONS]

Options:
  --record-only       Only record and output raw transcription.
  --skip-record FILE  Use existing WAV audio file instead of recording.
  --raw-text TEXT     Skip audio recording/transcription; run LLM prompt optimization on TEXT.
  -h, --help          Show this message.
EOF
    exit 0
}

SKIP_RECORD=false
INPUT_AUDIO=""
INPUT_TEXT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-record)
            SKIP_RECORD=true
            INPUT_AUDIO="$2"
            shift 2
            ;;
        --raw-text)
            INPUT_TEXT="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            shift
            ;;
    esac
done

# Step 1: Audio Capture (if raw text not directly provided)
if [[ -z "$INPUT_TEXT" ]]; then
    if [[ "$SKIP_RECORD" == "true" ]]; then
        AUDIO_FILE="$INPUT_AUDIO"
    else
        log "Listening... (Speak now; recording stops after silence)"
        if command -v sox &>/dev/null; then
            sox -d -r 16000 -c 1 -b 16 "$AUDIO_FILE" silence 1 0.1 2% 1 1.2 2% 2>/dev/null
        elif command -v ffmpeg &>/dev/null; then
            log "Using ffmpeg (5 second capture fallback)..."
            ffmpeg -y -f alsa -i default -t 5 -ar 16000 -ac 1 "$AUDIO_FILE" -loglevel quiet
        else
            log "Error: Neither sox nor ffmpeg found for audio recording."
            exit 1
        fi
        log "Audio capture finished."
    fi

    # Step 2: Transcription with whisper.cpp
    log "Transcribing audio with whisper ($WHISPER_MODEL)..."
    if ! command -v "$WHISPER_BIN" &>/dev/null && [[ ! -x "$WHISPER_BIN" ]]; then
        log "Error: Whisper binary not found at $WHISPER_BIN"
        exit 1
    fi

    "$WHISPER_BIN" -m "$WHISPER_MODEL" \
                   -f "$AUDIO_FILE" \
                   --no-timestamps \
                   -nt \
                   -ngl "${WHISPER_N_GPU_LAYERS:-0}" \
                   --threads "${WHISPER_THREADS:-4}" \
                   > "$TXT_RAW_FILE" 2>/dev/null || true

    # Clean up blank lines or carriage returns
    RAW_TRANSCRIPT="$(tr -d '\r' < "$TXT_RAW_FILE" | sed '/^[[:space:]]*$/d' | paste -sd " " -)"
else
    RAW_TRANSCRIPT="$INPUT_TEXT"
fi

if [[ -z "${RAW_TRANSCRIPT// }" ]]; then
    log "No speech detected."
    exit 0
fi

log "Raw speech: \"${RAW_TRANSCRIPT}\""

# Step 3: LLM Prompt Optimization via Ollama API
log "Optimizing prompt via LLM (${LLM_MODEL})..."

SYSTEM_PROMPT="You are an expert developer assistant. Rewrite the following spoken speech into a clean, concise, unambiguous engineering prompt or code instruction. Strip verbal filler. Normalize code syntax. Output ONLY the resulting prompt."
if [[ -n "${LLM_SYSTEM_PROMPT_FILE:-}" && -f "${LLM_SYSTEM_PROMPT_FILE}" ]]; then
    SYSTEM_PROMPT="$(cat "${LLM_SYSTEM_PROMPT_FILE}")"
fi

PAYLOAD="$(node -e 'console.log(JSON.stringify({
    model: process.argv[1],
    prompt: process.argv[2],
    system: process.argv[3],
    stream: false,
    options: { temperature: 0.2 }
}))' "$LLM_MODEL" "$RAW_TRANSCRIPT" "$SYSTEM_PROMPT" 2>/dev/null || python3 -c '
import sys, json
print(json.dumps({
    "model": sys.argv[1],
    "prompt": sys.argv[2],
    "system": sys.argv[3],
    "stream": False,
    "options": {"temperature": 0.2}
}))' "$LLM_MODEL" "$RAW_TRANSCRIPT" "$SYSTEM_PROMPT")"

RESPONSE="$(curl -s -X POST "${OLLAMA_URL}/api/generate" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD" 2>/dev/null || echo "")"

OPTIMIZED_PROMPT=""
if [[ -n "$RESPONSE" ]]; then
    OPTIMIZED_PROMPT="$(echo "$RESPONSE" | grep -o '"response":"[^"]*' | sed 's/"response":"//' | sed 's/\\n/\n/g' | sed 's/\\"/"/g' || true)"
fi

if [[ -z "$OPTIMIZED_PROMPT" ]]; then
    log "Warning: LLM transformation returned empty. Falling back to raw transcript."
    FINAL_OUTPUT="$RAW_TRANSCRIPT"
else
    FINAL_OUTPUT="$OPTIMIZED_PROMPT"
fi

log "Final prompt:"
printf "\033[1;32m%s\033[0m\n" "$FINAL_OUTPUT"

# Step 4: Dispatch to Clipboard / IDE
if command -v wl-copy &>/dev/null; then
    printf "%s" "$FINAL_OUTPUT" | wl-copy
    log "Copied to Wayland clipboard."
elif command -v xclip &>/dev/null; then
    printf "%s" "$FINAL_OUTPUT" | xclip -selection clipboard
    log "Copied to X11 clipboard."
elif command -v pbcopy &>/dev/null; then
    printf "%s" "$FINAL_OUTPUT" | pbcopy
    log "Copied to macOS clipboard."
fi

# Optional: Auto-paste into focused IDE window
if [[ "${AUTO_PASTE_ENABLED:-false}" == "true" ]]; then
    sleep 0.2
    if command -v wtype &>/dev/null; then
        wtype -M ctrl -k v -m ctrl
    elif command -v xdotool &>/dev/null; then
        xdotool key --clearmodifiers ctrl+v
    fi
fi
