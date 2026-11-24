#!/usr/bin/env bash
# ==============================================================================
# Transcribe and Optimize Dictation Pipeline
# ==============================================================================
# Records audio from microphone until silence, transcribes with whisper.cpp,
# filters and optimizes prompt using local LLM (Ollama), and dispatches to IDE.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
REPO_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Find and source environment
ENV_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/ai_dotfiles/.env"
if [[ ! -f "$ENV_FILE" ]]; then
    ENV_FILE="${REPO_ROOT}/.env"
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
WHISPER_MODEL="${WHISPER_MODEL_PATH:-$HOME/.local/share/whisper.cpp/models/ggml-large-v3-turbo.bin}"
OLLAMA_URL="${LOCAL_LLM_ENDPOINT:-http://localhost:11434}"
LLM_MODEL="${LLM_MODEL_NAME:-prompt-optimizer:latest}"

mkdir -p "$TMP_DIR"

COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"
COLOR_YELLOW="\033[1;33m"
COLOR_CYAN="\033[1;36m"
COLOR_BOLD="\033[1m"
COLOR_RESET="\033[0m"

log() { printf "[ai-dictate] %s\n" "$*"; }
log_wake_success() {
    printf "  ${COLOR_GREEN}✔${COLOR_RESET} ${COLOR_BOLD}[ai-dictate]${COLOR_RESET} Wake word ${COLOR_CYAN}\"%s\"${COLOR_RESET} detected — ${COLOR_GREEN}${COLOR_BOLD}LISTENING${COLOR_RESET}\n" "$*"
}
log_wake_fail() {
    printf "  ${COLOR_RED}✖${COLOR_RESET} ${COLOR_BOLD}[ai-dictate]${COLOR_RESET} Wake word ${COLOR_CYAN}\"%s\"${COLOR_RESET} not detected — ${COLOR_RED}${COLOR_BOLD}NOT LISTENING${COLOR_RESET}\n" "$*"
}
log_no_speech() {
    printf "  ${COLOR_RED}✖${COLOR_RESET} ${COLOR_BOLD}[ai-dictate]${COLOR_RESET} No speech detected — ${COLOR_RED}${COLOR_BOLD}NOT LISTENING${COLOR_RESET}\n"
}

resolve_whisper_bin() {
    local target="${1:-whisper-cli}"
    if [[ -x "$target" ]]; then
        echo "$target"
        return 0
    fi
    if command -v "$target" &>/dev/null; then
        command -v "$target"
        return 0
    fi
    local candidates=(
        "${HOME}/.local/bin/whisper-cli"
        "${HOME}/.local/share/whisper.cpp/src/build/bin/whisper-cli"
        "${HOME}/.local/share/whisper.cpp/build/bin/whisper-cli"
        "${HOME}/.local/share/whisper.cpp/src/build/bin/main"
        "${HOME}/.local/share/whisper.cpp/src/main"
        "/usr/local/bin/whisper-cli"
        "/usr/bin/whisper-cli"
    )
    for c in "${candidates[@]}"; do
        if [[ -x "$c" ]]; then
            echo "$c"
            return 0
        fi
    done
    echo "$target"
}

WHISPER_BIN="$(resolve_whisper_bin "${WHISPER_BIN_PATH:-whisper-cli}")"

check_wake_word() {
    local text="$1"
    local wake_word="$2"
    local strip="${3:-true}"

    if [[ -z "$wake_word" ]]; then
        echo "$text"
        return 0
    fi

    # Support optional conversational fillers (uh, um, hey, ok, okay) before wake word
    local pattern="^[[:space:]]*((uh|um|hey|ok|okay)[[:space:],.:;!?-]+)?(${wake_word})[[:space:],.:;!?-]*(.*)$"
    shopt -s nocasematch
    if [[ "$text" =~ $pattern ]]; then
        shopt -u nocasematch
        if [[ "$strip" == "true" ]]; then
            local trimmed="${BASH_REMATCH[4]}"
            trimmed="${trimmed#"${trimmed%%[![:space:]]*}"}"
            trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
            echo "$trimmed"
        else
            echo "$text"
        fi
        return 0
    else
        shopt -u nocasematch
        return 1
    fi
}

usage() {
    cat <<EOF
ai-dictate: Record audio, transcribe via Whisper, optimize prompt via LLM, and paste to IDE.

Usage: $(basename "$0") [OPTIONS]

Options:
  --wake-word WORD    Require spoken wake word (e.g. 'computer', 'jarvis'; overrides .env)
  --no-wake-word      Disable wake word check (even if enabled in .env)
  -c, --continuous    Run continuous dictation daemon (listen repeatedly until Ctrl+C)
  --record-only       Record microphone audio to WAV file and exit (skip transcription/LLM).
  --transcribe-only   Record audio and transcribe to raw text (skip LLM optimization).
  --skip-record FILE  Use existing WAV audio file instead of recording.
  --raw-text TEXT     Skip audio recording/transcription; run LLM prompt optimization on TEXT.
  -h, --help          Show this message.
EOF
    exit 0
}

RECORD_ONLY=false
TRANSCRIBE_ONLY=false
SKIP_RECORD=false
CONTINUOUS_MODE=false
INPUT_AUDIO=""
INPUT_TEXT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --wake-word)
            WAKE_WORD="$2"
            WAKE_WORD_ENABLED=true
            shift 2
            ;;
        --no-wake-word)
            WAKE_WORD_ENABLED=false
            shift
            ;;
        -c|--continuous)
            CONTINUOUS_MODE=true
            shift
            ;;
        --record-only)
            RECORD_ONLY=true
            shift
            ;;
        --transcribe-only)
            TRANSCRIBE_ONLY=true
            shift
            ;;
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
run_pipeline() {
    local AUDIO_FILE="${TMP_DIR}/input_recording.wav"
    local TXT_RAW_FILE="${TMP_DIR}/raw_transcript.txt"
    local RAW_TRANSCRIPT=""

    if [[ -z "$INPUT_TEXT" ]]; then
        if [[ "$SKIP_RECORD" == "true" ]]; then
            AUDIO_FILE="$INPUT_AUDIO"
        else
            local RECORD_SCRIPT="${REPO_ROOT}/scripts/audio/record_until_silence.py"
            local RECORDED=false

            # Clean up stale audio file before recording
            rm -f "$AUDIO_FILE"

            # 1. Primary: Intelligent Python silence-detection recorder
            if [[ -f "$RECORD_SCRIPT" ]] && command -v python3 &>/dev/null; then
                if ! python3 "$RECORD_SCRIPT" \
                    --output "$AUDIO_FILE" \
                    --silence-duration "${AUDIO_SILENCE_DURATION:-5.0}" \
                    --threshold "${AUDIO_SILENCE_THRESHOLD:-2.0%}" \
                    --sample-rate "${AUDIO_SAMPLE_RATE:-16000}" \
                    --wait-timeout "${AUDIO_LISTEN_TIMEOUT:-${LISTEN_TIMEOUT:-${AUDIO_WAIT_TIMEOUT:-30.0}}}" \
                    --max-duration "${AUDIO_MAX_DURATION:-120.0}" \
                    --backend "${AUDIO_RECORDER:-auto}" \
                    --device "${AUDIO_DEVICE:-default}" \
                    --prefix "[ai-dictate] "; then
                    log_no_speech
                    return 0
                fi
                RECORDED=true
            # 2. Sox fallback (if explicitly available)
            elif command -v sox &>/dev/null; then
                log "Listening... (Speak now; recording stops after silence)"
                sox -d -r "${AUDIO_SAMPLE_RATE:-16000}" -c 1 -b 16 "$AUDIO_FILE" \
                    silence 1 0.1 "${AUDIO_SILENCE_THRESHOLD:-2%}" 1 "${AUDIO_SILENCE_DURATION:-5.0}" "${AUDIO_SILENCE_THRESHOLD:-2%}" 2>/dev/null
                RECORDED=true
            # 3. arecord fallback
            elif command -v arecord &>/dev/null; then
                log "Listening via arecord (Speak now; press Enter or Ctrl+C to stop)..."
                arecord -q -r "${AUDIO_SAMPLE_RATE:-16000}" -c 1 -f S16_LE "$AUDIO_FILE" &
                local REC_PID=$!
                read -r -t "${AUDIO_MAX_DURATION:-30}" _ || true
                kill "$REC_PID" 2>/dev/null || true
                RECORDED=true
            # 4. ffmpeg fallback
            elif command -v ffmpeg &>/dev/null; then
                log "Listening via ffmpeg (Speak now; press Enter or Ctrl+C to stop)..."
                ffmpeg -y -f alsa -i "${AUDIO_DEVICE:-default}" -t "${AUDIO_MAX_DURATION:-30}" -ar "${AUDIO_SAMPLE_RATE:-16000}" -ac 1 "$AUDIO_FILE" -loglevel quiet &
                local REC_PID=$!
                read -r -t "${AUDIO_MAX_DURATION:-30}" _ || true
                kill "$REC_PID" 2>/dev/null || true
                RECORDED=true
            else
                log "Error: No suitable audio recorder found (python3, sox, arecord, ffmpeg)."
                exit 1
            fi
            log "Audio capture finished."
        fi

        # Verify audio file exists and is non-empty
        if [[ ! -f "$AUDIO_FILE" || ! -s "$AUDIO_FILE" ]]; then
            log_no_speech
            return 0
        fi

        # If user only wanted to record audio, exit early without calling Whisper
        if [[ "$RECORD_ONLY" == "true" ]]; then
            log "Audio recording saved: $AUDIO_FILE"
            printf "%s\n" "$AUDIO_FILE"
            exit 0
        fi

        # Step 2: Transcription with whisper.cpp
        log "Transcribing audio with whisper ($WHISPER_MODEL)..."
        if ! command -v "$WHISPER_BIN" &>/dev/null && [[ ! -x "$WHISPER_BIN" ]]; then
            log "Error: Whisper binary not found at '$WHISPER_BIN'."
            log "Hint: Compile whisper.cpp via './scripts/setup/setup_whisper_cpp.sh' or set WHISPER_BIN_PATH in .env."
            exit 1
        fi

        if [[ ! -f "$WHISPER_MODEL" ]]; then
            log "Error: Whisper model not found at '$WHISPER_MODEL'."
            log "Hint: Download models via './scripts/setup/setup_whisper_cpp.sh' or set WHISPER_MODEL_PATH in .env."
            exit 1
        fi

        local WHISPER_GPU_ARGS=()
        if [[ "${WHISPER_N_GPU_LAYERS:-0}" == "0" ]]; then
            WHISPER_GPU_ARGS+=("-ng")
        fi

        "$WHISPER_BIN" -m "$WHISPER_MODEL" \
                       -f "$AUDIO_FILE" \
                       --no-timestamps \
                       -nt \
                       -np \
                       "${WHISPER_GPU_ARGS[@]}" \
                       --threads "${WHISPER_THREADS:-4}" \
                       > "$TXT_RAW_FILE" 2>/dev/null || true

        # Clean up blank lines or carriage returns
        RAW_TRANSCRIPT="$(tr -d '\r' < "$TXT_RAW_FILE" | sed '/^[[:space:]]*$/d' | paste -sd " " -)"
    else
        RAW_TRANSCRIPT="$INPUT_TEXT"
    fi

    if [[ -z "${RAW_TRANSCRIPT// }" ]]; then
        log_no_speech
        return 0
    fi

    log "Raw speech: \"${RAW_TRANSCRIPT}\""

    # Step 2.5: Wake Word Verification & Stripping
    local ww_active="${WAKE_WORD_ENABLED:-false}"
    local ww_target="${WAKE_WORD:-}"

    if [[ "$ww_active" == "true" && -n "$ww_target" ]]; then
        local stripped_prompt
        if stripped_prompt="$(check_wake_word "$RAW_TRANSCRIPT" "$ww_target" "${WAKE_WORD_STRIP:-true}")"; then
            log_wake_success "$ww_target"
            if [[ -z "$stripped_prompt" ]]; then
                log "Wake word detected, but no command followed. Skipping."
                return 0
            fi
            RAW_TRANSCRIPT="$stripped_prompt"
            log "Cleaned prompt (wake word stripped): \"${RAW_TRANSCRIPT}\""
        else
            log_wake_fail "$ww_target"
            return 0
        fi
    fi

    # If user requested transcribe-only, emit raw text and exit without calling LLM
    if [[ "$TRANSCRIBE_ONLY" == "true" ]]; then
        log "Raw transcription completed."
        if command -v wl-copy &>/dev/null && printf "%s" "$RAW_TRANSCRIPT" | wl-copy 2>/dev/null; then
            log "Copied to Wayland clipboard."
        elif command -v xclip &>/dev/null && printf "%s" "$RAW_TRANSCRIPT" | xclip -selection clipboard 2>/dev/null; then
            log "Copied to X11 clipboard."
        elif command -v pbcopy &>/dev/null && printf "%s" "$RAW_TRANSCRIPT" | pbcopy 2>/dev/null; then
            log "Copied to macOS clipboard."
        fi
        printf "%s\n" "$RAW_TRANSCRIPT"
        if [[ "$CONTINUOUS_MODE" != "true" ]]; then
            exit 0
        fi
        return 0
    fi

    # Step 3: LLM Prompt Optimization via Ollama API
    log "Optimizing prompt via LLM (${LLM_MODEL})..."

    local SYSTEM_PROMPT="You are an expert developer assistant. Rewrite the following spoken speech into a clean, concise, unambiguous engineering prompt or code instruction. Strip verbal filler. Normalize code syntax. Output ONLY the resulting prompt."
    if [[ -n "${LLM_SYSTEM_PROMPT_FILE:-}" && -f "${LLM_SYSTEM_PROMPT_FILE}" ]]; then
        SYSTEM_PROMPT="$(cat "${LLM_SYSTEM_PROMPT_FILE}")"
    fi

    local PAYLOAD
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

    local RESPONSE
    RESPONSE="$(curl -s -X POST "${OLLAMA_URL}/api/generate" \
        -H "Content-Type: application/json" \
        -d "$PAYLOAD" 2>/dev/null || echo "")"

    local OPTIMIZED_PROMPT=""
    if [[ -n "$RESPONSE" ]]; then
        OPTIMIZED_PROMPT="$(echo "$RESPONSE" | grep -o '"response":"[^"]*' | sed 's/"response":"//' | sed 's/\\n/\n/g' | sed 's/\\"/"/g' || true)"
    fi

    local FINAL_OUTPUT=""
    if [[ -z "$OPTIMIZED_PROMPT" ]]; then
        log "Warning: LLM transformation returned empty. Falling back to raw transcript."
        FINAL_OUTPUT="$RAW_TRANSCRIPT"
    else
        FINAL_OUTPUT="$OPTIMIZED_PROMPT"
    fi

    log "Final prompt:"
    printf "\033[1;32m%s\033[0m\n" "$FINAL_OUTPUT"

    # Step 4: Dispatch to Clipboard / IDE
    if command -v wl-copy &>/dev/null && printf "%s" "$FINAL_OUTPUT" | wl-copy 2>/dev/null; then
        log "Copied to Wayland clipboard."
    elif command -v xclip &>/dev/null && printf "%s" "$FINAL_OUTPUT" | xclip -selection clipboard 2>/dev/null; then
        log "Copied to X11 clipboard."
    elif command -v pbcopy &>/dev/null && printf "%s" "$FINAL_OUTPUT" | pbcopy 2>/dev/null; then
        log "Copied to macOS clipboard."
    fi

    # Optional: Auto-paste into focused IDE window
    if [[ "${AUTO_PASTE_ENABLED:-false}" == "true" ]]; then
        sleep 0.2
        if command -v wtype &>/dev/null; then
            wtype -M ctrl -k v -m ctrl 2>/dev/null || true
        elif command -v xdotool &>/dev/null; then
            xdotool key --clearmodifiers ctrl+v 2>/dev/null || true
        fi
    fi
}

if [[ "$CONTINUOUS_MODE" == "true" ]]; then
    printf "\n${COLOR_CYAN}===> Continuous Voice Daemon Active${COLOR_RESET} (Wake word: ${COLOR_CYAN}\"%s\"${COLOR_RESET}, Press Ctrl+C to stop)\n" "${WAKE_WORD:-none}"
    while true; do
        run_pipeline || true
        sleep 0.3
    done
else
    run_pipeline
fi
