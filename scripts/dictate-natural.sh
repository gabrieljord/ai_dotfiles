#!/usr/bin/env bash
# ==============================================================================
# Two-Stage Hybrid Voice-to-Code Pipeline Orchestrator (Natural Language Mode)
# ==============================================================================
# Role: Ingests natural spoken developer English, transcribes via whisper.cpp,
#       translates conversational intents into strict sci-fi triggers via Ollama,
#       and hands off the trigger tokens to the deterministic v2 AST pipeline
#       (scripts/dictate_v2.sh) for validation and output.
#
# Usage:
#   dictate-natural.sh <EXTENSION> [AUDIO_FILE]
#   dictate-natural.sh [OPTIONS] <EXTENSION> [AUDIO_FILE]
#
# Examples:
#   dictate-natural.sh py
#   dictate-natural.sh rs /tmp/recording.wav
#   dictate-natural.sh --ext ts --raw-text "Write a function called fetch user that returns a float."
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# 1. Environment & Configuration Loading
# ------------------------------------------------------------------------------
SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Search paths for main .env file
ENV_LOCATIONS=(
    "${AI_DOTFILES_ENV:-}"
    "${XDG_CONFIG_HOME:-$HOME/.config}/ai_dotfiles/.env"
    "${REPO_ROOT}/.env"
    "${PWD}/.env"
)

for loc in "${ENV_LOCATIONS[@]}"; do
    if [[ -n "$loc" && -f "$loc" ]]; then
        # shellcheck disable=SC1090
        source "$loc"
        break
    fi
done

# Search paths for language vocabulary prompts configuration
LANG_PROMPTS_LOCATIONS=(
    "${REPO_ROOT}/config/prompts/lang_prompts.env"
    "${XDG_CONFIG_HOME:-$HOME/.config}/ai_dotfiles/prompts/lang_prompts.env"
    "${SCRIPT_DIR}/../config/prompts/lang_prompts.env"
)

for ploc in "${LANG_PROMPTS_LOCATIONS[@]}"; do
    if [[ -f "$ploc" ]]; then
        # shellcheck disable=SC1090
        source "$ploc"
        break
    fi
done

# ------------------------------------------------------------------------------
# 2. Defaults, Hardware Optimization & Path Resolution
# ------------------------------------------------------------------------------
TMP_DIR="${AI_TMP_DIR:-/tmp/ai_dotfiles}"
mkdir -p "$TMP_DIR"
DEFAULT_AUDIO="${TMP_DIR}/input_recording.wav"

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

resolve_file() {
    for candidate in "$@"; do
        if [[ -n "$candidate" && -f "$candidate" ]]; then
            echo "$candidate"
            return 0
        fi
    done
    return 1
}

WHISPER_BIN="$(resolve_whisper_bin "${WHISPER_BIN_PATH:-whisper-cli}")"
WHISPER_MODEL="${WHISPER_MODEL_PATH:-$HOME/.local/share/whisper.cpp/models/ggml-tiny.en.bin}"
WHISPER_THREADS="${WHISPER_THREADS:-4}"
WHISPER_N_GPU_LAYERS="${WHISPER_N_GPU_LAYERS:-0}"

# Resolve system prompt template and sci-fi lexicon mapping
SYSTEM_PROMPT_FILE="$(resolve_file \
    "${REPO_ROOT}/config/ollama/system-prompts/lexicon-translator.txt" \
    "${XDG_CONFIG_HOME:-$HOME/.config}/ai_dotfiles/ollama/system-prompts/lexicon-translator.txt" \
    "${SCRIPT_DIR}/../config/ollama/system-prompts/lexicon-translator.txt" \
    "${SCRIPT_DIR}/pipeline/lexicon-translator.txt"
)" || {
    printf "[dictate-natural] ERROR: Prompt template 'lexicon-translator.txt' not found.\n" >&2
    exit 1
}

LEXICON_FILE="$(resolve_file \
    "${REPO_ROOT}/whisper/grammars/scifi_lexicon.json" \
    "${REPO_ROOT}/config/whisper/grammars/scifi_lexicon.json" \
    "${XDG_CONFIG_HOME:-$HOME/.config}/ai_dotfiles/whisper/grammars/scifi_lexicon.json" \
    "${SCRIPT_DIR}/../whisper/grammars/scifi_lexicon.json" \
    "${SCRIPT_DIR}/../config/whisper/grammars/scifi_lexicon.json"
)" || {
    printf "[dictate-natural] ERROR: Lexicon file 'scifi_lexicon.json' not found.\n" >&2
    exit 1
}

# Resolve downstream deterministic v2 orchestrator
DICTATE_V2_SCRIPT="$(resolve_file \
    "${SCRIPT_DIR}/dictate_v2.sh" \
    "${REPO_ROOT}/scripts/dictate_v2.sh"
)" || {
    if command -v ai-dictate-v2 &>/dev/null; then
        DICTATE_V2_SCRIPT="$(command -v ai-dictate-v2)"
    else
        printf "[dictate-natural] ERROR: Deterministic orchestrator 'dictate_v2.sh' not found.\n" >&2
        exit 1
    fi
}

# Resolve Ollama API endpoint
OLLAMA_ENDPOINT="${LOCAL_LLM_ENDPOINT:-}"
if [[ -z "$OLLAMA_ENDPOINT" ]]; then
    SERVER_HOST="${AI_SERVER_HOST:-localhost}"
    SERVER_PORT="${OLLAMA_SERVER_PORT:-11434}"
    OLLAMA_ENDPOINT="http://${SERVER_HOST}:${SERVER_PORT}"
fi
OLLAMA_ENDPOINT="${OLLAMA_ENDPOINT%/}"

MODEL_NAME="${LLM_MODEL_NAME:-llama3:8b-instruct-q8_0}"
TIMEOUT_SEC="${LLM_TIMEOUT_SECONDS:-15}"

# Formatting & Colors (strict output to stderr)
COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"
COLOR_YELLOW="\033[1;33m"
COLOR_CYAN="\033[1;36m"
COLOR_BOLD="\033[1m"
COLOR_RESET="\033[0m"

log_err()  { printf "[dictate-natural] ERROR: %s\n" "$*" >&2; }
log_warn() { printf "[dictate-natural] WARN: %s\n" "$*" >&2; }
log_info() { printf "[dictate-natural] INFO: %s\n" "$*" >&2; }

log_wake_success() {
    printf "  ${COLOR_GREEN}✔${COLOR_RESET} ${COLOR_BOLD}[dictate-natural]${COLOR_RESET} Wake word ${COLOR_CYAN}\"%s\"${COLOR_RESET} detected — ${COLOR_GREEN}${COLOR_BOLD}LISTENING${COLOR_RESET}\n" "$*" >&2
}
log_wake_fail() {
    printf "  ${COLOR_RED}✖${COLOR_RESET} ${COLOR_BOLD}[dictate-natural]${COLOR_RESET} Wake word ${COLOR_CYAN}\"%s\"${COLOR_RESET} not detected — ${COLOR_RED}${COLOR_BOLD}NOT LISTENING${COLOR_RESET}\n" "$*" >&2
}
log_no_speech() {
    printf "  ${COLOR_RED}✖${COLOR_RESET} ${COLOR_BOLD}[dictate-natural]${COLOR_RESET} No speech detected — ${COLOR_RED}${COLOR_BOLD}NOT LISTENING${COLOR_RESET}\n" >&2
}

# ------------------------------------------------------------------------------
# Desktop Notification Helper
# ------------------------------------------------------------------------------
desktop_notify() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"
    local icon="${4:-audio-input-microphone}"

    if [[ "${CONTINUOUS_MODE:-false}" != "true" || "${NOTIFY_ON_CONTINUOUS:-true}" != "true" ]]; then
        return 0
    fi

    if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" && -S "/run/user/$(id -u)/bus" ]]; then
        export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
    fi
    if [[ -z "${XDG_RUNTIME_DIR:-}" && -d "/run/user/$(id -u)" ]]; then
        export XDG_RUNTIME_DIR="/run/user/$(id -u)"
    fi

    if command -v notify-send &>/dev/null; then
        notify-send \
            --app-name="ai-dictate-natural" \
            --urgency="$urgency" \
            --expire-time="${NOTIFY_TIMEOUT_MS:-3000}" \
            --icon="$icon" \
            "$title" \
            "$message" 2>/dev/null || true
    fi
}

check_wake_word() {
    local text="$1"
    local wake_word="$2"
    local strip="${3:-true}"

    if [[ -z "$wake_word" ]]; then
        echo "$text"
        return 0
    fi

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
    local exit_code="${1:-0}"
    cat >&2 <<EOF
Usage: $(basename "$0") <EXTENSION> [AUDIO_FILE]
       $(basename "$0") [OPTIONS] <EXTENSION> [AUDIO_FILE]

Two-Stage Voice-to-Code Pipeline:
  Stage 1: Whisper speech transcription -> Ollama NLP Lexicon Translation
  Stage 2: Deterministic AST Encoder -> LLM Decoder -> Linter Validation Loop

Arguments:
  \$1, <EXTENSION>     Target file extension (e.g. py, rs, ts, go, cpp, sh, sql)
  \$2, [AUDIO_FILE]    Path to audio WAV file (default: ${DEFAULT_AUDIO})

Options:
  -e, --ext EXT       Specify target file extension
  -a, --audio FILE    Specify audio WAV input file
  -c, --continuous    Run continuous dictation daemon (listen repeatedly until Ctrl+C)
  --record            Record microphone audio until silence before transcribing
  --wake-word WORD    Require spoken wake word (e.g. 'computer', 'jarvis')
  --no-wake-word      Disable wake word check (even if enabled in .env)
  -r, --raw-text STR  Bypass Whisper and pipe raw speech text directly to translator
  --provider NAME     Override LLM provider or CLI agent (e.g. gemini, agy, claude-cli, openai, ollama)
  --model NAME        Override LLM model name
  --dispatch METHOD   Override output dispatch (stdout, clipboard, tmux, agent)
  -h, --help          Show this help message
EOF
    exit "$exit_code"
}

# ------------------------------------------------------------------------------
# 3. CLI Argument Parsing
# ------------------------------------------------------------------------------
TARGET_EXT=""
AUDIO_FILE=""
RAW_TEXT_OVERRIDE=""
CONTINUOUS_MODE="${CONTINUOUS_MODE:-false}"
FLAG_RECORD=false
CUSTOM_AUDIO_SPECIFIED=false

POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -e|--ext)
            TARGET_EXT="$2"
            shift 2
            ;;
        -a|--audio)
            AUDIO_FILE="$2"
            CUSTOM_AUDIO_SPECIFIED=true
            shift 2
            ;;
        -c|--continuous)
            CONTINUOUS_MODE=true
            shift
            ;;
        --record)
            FLAG_RECORD=true
            shift
            ;;
        --wake-word)
            WAKE_WORD="$2"
            WAKE_WORD_CHECK=true
            shift 2
            ;;
        --no-wake-word)
            WAKE_WORD_CHECK=false
            WAKE_WORD_SETTING=""
            shift
            ;;
        -r|--raw-text)
            RAW_TEXT_OVERRIDE="$2"
            shift 2
            ;;
        --provider)
            export LLM_PROVIDER="$2"
            shift 2
            ;;
        --model)
            export LLM_MODEL_NAME="$2"
            export AGENT_CLI_MODEL="$2"
            MODEL_NAME="$2"
            shift 2
            ;;
        --dispatch)
            export DISPATCH_METHOD="$2"
            shift 2
            ;;
        -h|--help)
            usage 0
            ;;
        -*)
            log_err "Unknown option: $1"
            usage 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

if [[ ${#POSITIONAL_ARGS[@]} -ge 1 && -z "$TARGET_EXT" ]]; then
    TARGET_EXT="${POSITIONAL_ARGS[0]}"
fi

if [[ ${#POSITIONAL_ARGS[@]} -ge 2 && "$CUSTOM_AUDIO_SPECIFIED" == "false" ]]; then
    AUDIO_FILE="${POSITIONAL_ARGS[1]}"
    CUSTOM_AUDIO_SPECIFIED=true
fi

if [[ -z "$TARGET_EXT" ]]; then
    TARGET_EXT="${DEFAULT_LANG_EXT:-py}"
fi

CLEAN_EXT="$(echo "${TARGET_EXT}" | tr -d '.' | tr '[:upper:]' '[:lower:]')"

if [[ "$CUSTOM_AUDIO_SPECIFIED" == "false" && -z "$AUDIO_FILE" ]]; then
    AUDIO_FILE="$DEFAULT_AUDIO"
fi

# ------------------------------------------------------------------------------
# 4. Core Pipeline Execution
# ------------------------------------------------------------------------------
run_natural_pipeline() {
    local RAW_TRANSCRIPT=""

    if [[ -n "$RAW_TEXT_OVERRIDE" ]]; then
        RAW_TRANSCRIPT="$RAW_TEXT_OVERRIDE"
        log_info "Using raw text input: \"${RAW_TRANSCRIPT}\""
    else
        # Recording check
        if [[ "$FLAG_RECORD" == "true" || ( "$CUSTOM_AUDIO_SPECIFIED" == "false" && ! -f "$AUDIO_FILE" ) ]]; then
            log_info "Recording audio from microphone until silence..."
            local RECORDER_SCRIPT="${SCRIPT_DIR}/audio/record_until_silence.py"
            if [[ -x "$RECORDER_SCRIPT" ]]; then
                python3 "$RECORDER_SCRIPT" --output "$AUDIO_FILE" >&2
            else
                log_err "Recorder script not found or executable at ${RECORDER_SCRIPT}"
                exit 1
            fi
        fi

        if [[ ! -f "$AUDIO_FILE" ]]; then
            log_err "Audio input file not found: ${AUDIO_FILE}"
            exit 1
        fi

        if [[ ! -x "$WHISPER_BIN" ]]; then
            log_err "Whisper binary not executable at: ${WHISPER_BIN}"
            exit 1
        fi

        if [[ ! -f "$WHISPER_MODEL" ]]; then
            log_err "Whisper model not found at: ${WHISPER_MODEL}"
            exit 1
        fi

        log_info "Transcribing ${AUDIO_FILE} via whisper.cpp (${WHISPER_MODEL})..."

        local WHISPER_GPU_ARGS=()
        if [[ "${WHISPER_N_GPU_LAYERS:-0}" == "0" ]]; then
            WHISPER_GPU_ARGS+=("-ng")
        fi

        local WHISPER_OUTPUT
        WHISPER_OUTPUT="$(
            "$WHISPER_BIN" \
                -m "$WHISPER_MODEL" \
                -f "$AUDIO_FILE" \
                -nt \
                -np \
                "${WHISPER_GPU_ARGS[@]}" \
                --threads "$WHISPER_THREADS" \
                --language "${WHISPER_LANGUAGE:-en}" \
                2>/dev/null || true
        )"

        RAW_TRANSCRIPT="$(echo "$WHISPER_OUTPUT" | tr -d '\r' | sed '/^[[:space:]]*$/d' | paste -sd " " - || true)"
    fi

    local CHECK_WORDS
    CHECK_WORDS="$(echo "$RAW_TRANSCRIPT" | tr -d '[:space:][:punct:]')"
    if [[ -z "$CHECK_WORDS" ]]; then
        log_no_speech
        return 0
    fi

    log_info "Whisper Raw Transcript: \"${RAW_TRANSCRIPT}\""

    # Wake Word Verification & Stripping
    local WAKE_WORD_SETTING="${WAKE_WORD:-}"
    local WAKE_WORD_CHECK_ACTIVE="${WAKE_WORD_CHECK:-${WAKE_WORD_ENABLED:-false}}"

    if [[ "$WAKE_WORD_CHECK_ACTIVE" == "true" && -n "$WAKE_WORD_SETTING" ]]; then
        local STRIPPED_PROMPT
        if STRIPPED_PROMPT="$(check_wake_word "$RAW_TRANSCRIPT" "$WAKE_WORD_SETTING" "${WAKE_WORD_STRIP:-true}")"; then
            log_wake_success "$WAKE_WORD_SETTING"
            desktop_notify "✔ Wake Word Heard" "Wake word '${WAKE_WORD_SETTING}' detected — listening (.${CLEAN_EXT})..." "normal" "audio-input-microphone"
            if [[ -z "$STRIPPED_PROMPT" ]]; then
                log_warn "Wake word detected, but no voice command followed. Skipping."
                return 0
            fi
            RAW_TRANSCRIPT="$STRIPPED_PROMPT"
            log_info "Cleaned speech (wake word stripped): \"${RAW_TRANSCRIPT}\""
        else
            log_wake_fail "$WAKE_WORD_SETTING"
            return 0
        fi
    fi

    # --------------------------------------------------------------------------
    # Stage 1: Lexicon Translation via configured LLM provider / CLI agent
    # --------------------------------------------------------------------------
    local ACTIVE_PROVIDER="${LLM_PROVIDER:-ollama}"
    log_info "Translating natural speech to sci-fi triggers via ${ACTIVE_PROVIDER} (${MODEL_NAME})..."

    local RENDERED_SYS_PROMPT="${TMP_DIR}/natural_sys_prompt_$$.txt"
    if ! jq -rn \
        --rawfile tmpl "$SYSTEM_PROMPT_FILE" \
        --rawfile lex "$LEXICON_FILE" \
        '$tmpl | sub("\\{\\{LEXICON_JSON\\}\\}"; $lex)' > "$RENDERED_SYS_PROMPT" 2>/dev/null; then
        log_err "Failed to assemble lexicon system prompt using jq."
        rm -f "$RENDERED_SYS_PROMPT"
        exit 1
    fi

    local DECODER_SCRIPT="${SCRIPT_DIR}/pipeline/decoder.py"
    local TRANSLATED_RAW=""
    local DECODER_EXIT=0
    TRANSLATED_RAW="$(
        printf "%s" "$RAW_TRANSCRIPT" | python3 "$DECODER_SCRIPT" \
            --raw-prompt \
            --system-prompt-file "$RENDERED_SYS_PROMPT"
    )" || DECODER_EXIT=$?
    rm -f "$RENDERED_SYS_PROMPT"

    if [[ $DECODER_EXIT -ne 0 || -z "$TRANSLATED_RAW" ]]; then
        log_err "Lexicon translation failed via provider '${ACTIVE_PROVIDER}'."
        return 1
    fi

    # Clean translated output: strip markdown code blocks, trim quotes and excess whitespace
    local TRANSLATED_SYLLABLES
    TRANSLATED_SYLLABLES="$(printf "%s" "$TRANSLATED_RAW" | sed -E 's/^```[a-zA-Z0-9_-]*//g; s/```$//g')"
    TRANSLATED_SYLLABLES="$(printf "%s" "$TRANSLATED_SYLLABLES" | tr '\n\r\t' ' ' | sed -E 's/[[:space:]]+/ /g; s/^[[:space:]]+//; s/[[:space:]]+$//; s/^["'"'"']+//; s/["'"'"']+$//')"

    if [[ -z "$TRANSLATED_SYLLABLES" ]]; then
        log_err "Translated sci-fi triggers string is empty after cleaning."
        return 1
    fi

    log_info "Translated sci-fi triggers: \"${TRANSLATED_SYLLABLES}\""

    # --------------------------------------------------------------------------
    # Stage 2: Deterministic Handoff to dictate_v2.sh
    # --------------------------------------------------------------------------
    log_info "Handoff -> Invoking deterministic pipeline: ${DICTATE_V2_SCRIPT} --ext ${CLEAN_EXT} --raw-text ..."
    "$DICTATE_V2_SCRIPT" --ext "$CLEAN_EXT" --raw-text "$TRANSLATED_SYLLABLES" --no-wake-word
}

# ------------------------------------------------------------------------------
# 5. Execution Mode (Single-Shot vs Continuous Daemon)
# ------------------------------------------------------------------------------
if [[ -n "$RAW_TEXT_OVERRIDE" ]]; then
    run_natural_pipeline
    exit 0
fi

if [[ "$CONTINUOUS_MODE" == "true" ]]; then
    printf "\n${COLOR_CYAN}===> Continuous Natural Voice Code Daemon Active (.${CLEAN_EXT})${COLOR_RESET} (Wake word: ${COLOR_CYAN}\"%s\"${COLOR_RESET}, Press Ctrl+C to stop)\n" "${WAKE_WORD:-none}" >&2
    while true; do
        run_natural_pipeline || true
        sleep 0.3
    done
else
    run_natural_pipeline
fi
