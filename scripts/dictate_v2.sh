#!/usr/bin/env bash
# ==============================================================================
# Deterministic Voice Autoencoder/Decoder Dictation Pipeline (v2)
# ==============================================================================
# Role: Transcribes raw speech with whisper.cpp, pipes text into a deterministic
#       Python AST Encoder (scripts/pipeline/encoder.py), passes the JSON IR to
#       an LLM Syntax Decoder (scripts/pipeline/decoder.py), validates via local
#       linters (scripts/pipeline/validator.py), and outputs clean code to stdout.
#
# Usage:
#   dictate_v2.sh <EXTENSION> [AUDIO_FILE]
#   dictate_v2.sh [OPTIONS] <EXTENSION> [AUDIO_FILE]
#
# Examples:
#   dictate_v2.sh py
#   dictate_v2.sh rs /tmp/recording.wav
#   dictate_v2.sh ts --raw-text "spark fetch user thin arrow drift"
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# 1. Environment & Configuration Loading
# ------------------------------------------------------------------------------
SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Search paths for main .env file
ENV_LOCATIONS=(
    "${XDG_CONFIG_HOME:-$HOME/.config}/ai_dotfiles/.env"
    "${REPO_ROOT}/.env"
    "${PWD}/.env"
)

for loc in "${ENV_LOCATIONS[@]}"; do
    if [[ -f "$loc" ]]; then
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

LANG_CONFIG_LOADED=false
for ploc in "${LANG_PROMPTS_LOCATIONS[@]}"; do
    if [[ -f "$ploc" ]]; then
        # shellcheck disable=SC1090
        source "$ploc"
        LANG_CONFIG_LOADED=true
        break
    fi
done

if [[ "$LANG_CONFIG_LOADED" != "true" ]]; then
    PROMPT_DEFAULT="code, programming, function, variable, parameter, return, class, method, import"
fi

# ------------------------------------------------------------------------------
# 2. Defaults and Hardware Optimization
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

WHISPER_BIN="$(resolve_whisper_bin "${WHISPER_BIN_PATH:-whisper-cli}")"
WHISPER_MODEL="${WHISPER_MODEL_PATH:-$HOME/.local/share/whisper.cpp/models/ggml-tiny.en.bin}"
WHISPER_THREADS="${WHISPER_THREADS:-4}"
WHISPER_N_GPU_LAYERS="${WHISPER_N_GPU_LAYERS:-0}"

COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"
COLOR_YELLOW="\033[1;33m"
COLOR_CYAN="\033[1;36m"
COLOR_BOLD="\033[1m"
COLOR_RESET="\033[0m"

log_err()  { printf "[dictate-v2] ERROR: %s\n" "$*" >&2; }
log_warn() { printf "[dictate-v2] WARN: %s\n" "$*" >&2; }
log_info() { printf "[dictate-v2] INFO: %s\n" "$*" >&2; }

log_wake_success() {
    printf "  ${COLOR_GREEN}✔${COLOR_RESET} ${COLOR_BOLD}[dictate-v2]${COLOR_RESET} Wake word ${COLOR_CYAN}\"%s\"${COLOR_RESET} detected — ${COLOR_GREEN}${COLOR_BOLD}LISTENING${COLOR_RESET}\n" "$*" >&2
}
log_wake_fail() {
    printf "  ${COLOR_RED}✖${COLOR_RESET} ${COLOR_BOLD}[dictate-v2]${COLOR_RESET} Wake word ${COLOR_CYAN}\"%s\"${COLOR_RESET} not detected — ${COLOR_RED}${COLOR_BOLD}NOT LISTENING${COLOR_RESET}\n" "$*" >&2
}
log_no_speech() {
    printf "  ${COLOR_RED}✖${COLOR_RESET} ${COLOR_BOLD}[dictate-v2]${COLOR_RESET} No speech detected — ${COLOR_RED}${COLOR_BOLD}NOT LISTENING${COLOR_RESET}\n" >&2
}

# ------------------------------------------------------------------------------
# Desktop Notification & Clipboard Helpers
# ------------------------------------------------------------------------------
desktop_notify() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"
    local icon="${4:-audio-input-microphone}"

    # Only notify when in continuous mode (-c) AND notifications enabled
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
            --app-name="ai-dictate-code" \
            --urgency="$urgency" \
            --expire-time="${NOTIFY_TIMEOUT_MS:-3000}" \
            --icon="$icon" \
            "$title" \
            "$message" 2>/dev/null || true
    fi
}

dispatch_clipboard() {
    local text="$1"
    if command -v wl-copy &>/dev/null && printf "%s" "$text" | wl-copy 2>/dev/null; then
        log_info "Copied code to Wayland clipboard."
        return 0
    elif command -v xclip &>/dev/null && printf "%s" "$text" | xclip -selection clipboard 2>/dev/null; then
        log_info "Copied code to X11 clipboard."
        return 0
    elif command -v pbcopy &>/dev/null && printf "%s" "$text" | pbcopy 2>/dev/null; then
        log_info "Copied code to macOS clipboard."
        return 0
    fi
    return 1
}

trigger_autopaste() {
    if [[ "${AUTO_PASTE_ENABLED:-false}" == "true" ]]; then
        sleep 0.2
        if command -v wtype &>/dev/null; then
            wtype -M ctrl -k v -m ctrl 2>/dev/null || true
        elif command -v xdotool &>/dev/null; then
            xdotool key --clearmodifiers ctrl+v 2>/dev/null || true
        fi
    fi
}

dispatch_tmux() {
    local text="$1"
    local target="${TMUX_TARGET_PANE:-}"
    if ! command -v tmux &>/dev/null; then
        log_warn "tmux not found; cannot dispatch to tmux pane."
        return 1
    fi
    if [[ -z "$target" ]]; then
        log_warn "TMUX_TARGET_PANE is not set; skipping tmux dispatch."
        return 1
    fi
    if printf "%s" "$text" | tmux load-buffer - && tmux paste-buffer -t "$target"; then
        if [[ "${TMUX_SEND_ENTER:-false}" == "true" ]]; then
            tmux send-keys -t "$target" Enter
        fi
        log_info "Dispatched output to tmux pane: ${target}"
        return 0
    fi
    log_warn "Failed to dispatch output to tmux pane: ${target}"
    return 1
}

dispatch_agent() {
    local text="$1"
    local cmd_str="${AGENT_DISPATCH_CMD:-}"
    if [[ -z "$cmd_str" ]]; then
        if command -v agy &>/dev/null; then
            cmd_str="agy -c -p"
        elif command -v claude &>/dev/null; then
            cmd_str="claude -c -p"
        else
            log_warn "AGENT_DISPATCH_CMD is not set and no supported CLI agent (agy, claude) was found."
            return 1
        fi
    fi

    local -a cmd_parts
    read -r -a cmd_parts <<< "$cmd_str"
    local last_arg="${cmd_parts[$((${#cmd_parts[@]} - 1))]}"
    log_info "Dispatching output to CLI agent: ${cmd_str}"
    if [[ "$last_arg" == "-p" || "$last_arg" == "--print" || "$last_arg" == "--prompt" || "$last_arg" == "--message" || "$last_arg" == "-m" ]]; then
        if "${cmd_parts[@]}" "$text"; then
            return 0
        fi
    elif printf "%s" "$text" | "${cmd_parts[@]}"; then
        return 0
    fi
    log_warn "CLI agent dispatch failed for command: ${cmd_str}"
    return 1
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

Arguments:
  \$1, <EXTENSION>     Target file extension (e.g. py, rs, ts, go, cpp, sh, sql, json)
  \$2, [AUDIO_FILE]    Path to pre-recorded WAV file (default: ${DEFAULT_AUDIO})

Options:
  -e, --ext EXT       Specify target file extension
  -a, --audio FILE    Specify audio WAV input file
  -c, --continuous    Run continuous dictation daemon (listen repeatedly until Ctrl+C)
  --record            Record microphone audio until silence before transcribing
  --wake-word WORD    Require spoken wake word (e.g. 'computer', 'jarvis'; overrides .env)
  --no-wake-word      Disable wake word check (even if enabled in .env)
  -r, --raw-text STR  Bypass Whisper and pipe raw text directly to AST Encoder
  --provider NAME     Override LLM provider/CLI agent (gemini, openai, anthropic, ollama, agy, claude-cli, codex-cli, gemini-cli, custom-cli)
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
            WAKE_WORD_ENABLED=true
            shift 2
            ;;
        --no-wake-word)
            WAKE_WORD_ENABLED=false
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

# Resolve positional arguments ($1 = EXTENSION, $2 = AUDIO_FILE)
if [[ -z "$TARGET_EXT" && ${#POSITIONAL_ARGS[@]} -ge 1 ]]; then
    TARGET_EXT="${POSITIONAL_ARGS[0]}"
fi

if [[ -z "$AUDIO_FILE" && ${#POSITIONAL_ARGS[@]} -ge 2 ]]; then
    AUDIO_FILE="${POSITIONAL_ARGS[1]}"
    CUSTOM_AUDIO_SPECIFIED=true
elif [[ -z "$AUDIO_FILE" ]]; then
    AUDIO_FILE="$DEFAULT_AUDIO"
fi

if [[ -z "$TARGET_EXT" ]]; then
    TARGET_EXT="${DEFAULT_LANG_EXT:-py}"
fi

# Clean and normalize extension
RAW_EXT="$(echo "$TARGET_EXT" | sed 's/^\.//')"
CLEAN_EXT="$(echo "$RAW_EXT" | tr '[:upper:]' '[:lower:]')"

# Resolve domain vocabulary biasing prompt for Whisper
SAN_EXT="$(echo "$RAW_EXT" \
    | sed -e 's/c++/cpp/g' -e 's/C++/CPP/g' \
          -e 's/c#/cs/g'   -e 's/C#/CS/g' \
          -e 's/f#/fs/g'   -e 's/F#/FS/g' \
          -e 's/q#/qs/g'   -e 's/Q#/QS/g' \
          -e 's/+/_p_/g'   -e 's/#/_s_/g' \
          -e 's/[^a-zA-Z0-9_]/_/g' \
          -e 's/__*/_/g'   -e 's/^_//' -e 's/_$//' \
    | tr '[:lower:]' '[:upper:]')"

if [[ "$SAN_EXT" =~ ^[0-9] ]]; then
    SAN_EXT="LANG_${SAN_EXT}"
fi

VOCAB_VAR_NAME="PROMPT_${SAN_EXT}"
if [[ -n "${!VOCAB_VAR_NAME:-}" ]]; then
    VOCAB_PROMPT="${!VOCAB_VAR_NAME}"
    log_info "Active context: [${CLEAN_EXT}] -> \${${VOCAB_VAR_NAME}}"
else
    VOCAB_PROMPT="${PROMPT_DEFAULT:-code, function, variable, parameter, return}"
fi

# ------------------------------------------------------------------------------
# 4. Pipeline Execution Logic (Autoencoder -> Decoder -> Validator)
# ------------------------------------------------------------------------------
run_dictate_pipeline() {
    local RAW_TRANSCRIPT=""

    if [[ -n "$RAW_TEXT_OVERRIDE" ]]; then
        # Fast path: user supplied raw text directly
        RAW_TRANSCRIPT="$RAW_TEXT_OVERRIDE"
        log_info "Using raw text override: \"${RAW_TRANSCRIPT}\""
    else
        # Record microphone audio if no custom file specified
        local RECORD_SCRIPT="${SCRIPT_DIR}/audio/record_until_silence.py"
        if [[ "$CUSTOM_AUDIO_SPECIFIED" == "false" || "$FLAG_RECORD" == "true" ]]; then
            if [[ -f "$RECORD_SCRIPT" ]] && command -v python3 &>/dev/null; then
                rm -f "$AUDIO_FILE"

                if ! python3 "$RECORD_SCRIPT" \
                    --output "$AUDIO_FILE" \
                    --silence-duration "${AUDIO_SILENCE_DURATION:-5.0}" \
                    --threshold "${AUDIO_SILENCE_THRESHOLD:-2.0%}" \
                    --sample-rate "${AUDIO_SAMPLE_RATE:-16000}" \
                    --wait-timeout "${AUDIO_LISTEN_TIMEOUT:-${LISTEN_TIMEOUT:-30.0}}" \
                    --max-duration "${AUDIO_MAX_DURATION:-120.0}" \
                    --backend "${AUDIO_RECORDER:-auto}" \
                    --device "${AUDIO_DEVICE:-default}" \
                    --prefix "[dictate-v2] " >&2; then
                    log_no_speech
                    return 0
                fi
            fi
        fi

        # Verify audio file existence and non-empty
        if [[ ! -f "$AUDIO_FILE" || ! -s "$AUDIO_FILE" ]]; then
            log_no_speech
            return 0
        fi

        # Verify whisper binary
        if ! command -v "$WHISPER_BIN" &>/dev/null && [[ ! -x "$WHISPER_BIN" ]]; then
            log_err "whisper.cpp binary not executable at: ${WHISPER_BIN}"
            exit 1
        fi

        # Verify model weights file
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
                --prompt "$VOCAB_PROMPT" \
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
    local WAKE_WORD_CHECK="${WAKE_WORD_ENABLED:-false}"

    if [[ "$WAKE_WORD_CHECK" == "true" && -n "$WAKE_WORD_SETTING" ]]; then
        local STRIPPED_PROMPT
        if STRIPPED_PROMPT="$(check_wake_word "$RAW_TRANSCRIPT" "$WAKE_WORD_SETTING" "${WAKE_WORD_STRIP:-true}")"; then
            log_wake_success "$WAKE_WORD_SETTING"
            desktop_notify "✔ Wake Word Heard" "Wake word '${WAKE_WORD_SETTING}' detected — listening (.${CLEAN_EXT})..." "normal" "audio-input-microphone"
            if [[ -z "$STRIPPED_PROMPT" ]]; then
                log_warn "Wake word detected, but no code command followed. Skipping."
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
    # Phase 1: Deterministic Encoder (Python AST State-Machine Parser)
    # --------------------------------------------------------------------------
    local ENCODER_SCRIPT="${SCRIPT_DIR}/pipeline/encoder.py"
    log_info "Phase 1: Deterministic Encoder -> Parsing speech into JSON AST..."
    local JSON_IR
    JSON_IR="$(printf "%s" "$RAW_TRANSCRIPT" | python3 "$ENCODER_SCRIPT" --compact 2>/dev/null || echo "{}")"
    log_info "Generated AST: ${JSON_IR}"

    # --------------------------------------------------------------------------
    # Phase 2: LLM Decoder (Syntax Compiler via Ollama API)
    # --------------------------------------------------------------------------
    local DECODER_SCRIPT="${SCRIPT_DIR}/pipeline/decoder.py"
    log_info "Phase 2: LLM Decoder -> Compiling AST into .${CLEAN_EXT} source code..."
    local DECODED_CODE
    DECODED_CODE="$(printf "%s" "$JSON_IR" | python3 "$DECODER_SCRIPT" --ext "$CLEAN_EXT")"

    # --------------------------------------------------------------------------
    # Phase 3: Subprocess Linter & Validation Loop (up to 2 retries)
    # --------------------------------------------------------------------------
    local VALIDATOR_SCRIPT="${SCRIPT_DIR}/pipeline/validator.py"
    log_info "Phase 3: Validation Loop -> Verifying code syntax with local linter..."
    local FINAL_CODE
    FINAL_CODE="$(printf "%s" "$DECODED_CODE" | python3 "$VALIDATOR_SCRIPT" --ext "$CLEAN_EXT" --ir "$JSON_IR")"

    # --------------------------------------------------------------------------
    # Phase 4: Emit Validated Source Code to stdout
    # --------------------------------------------------------------------------
    printf "%s\n" "$FINAL_CODE"

    # System Integration: Clipboard/Auto-Paste, tmux pane, or CLI Agent dispatch
    local active_dispatch="${DISPATCH_METHOD:-stdout}"
    if [[ "$active_dispatch" == "tmux" ]]; then
        dispatch_tmux "$FINAL_CODE" || true
    elif [[ "$active_dispatch" == "agent" ]]; then
        dispatch_agent "$FINAL_CODE" || true
    elif [[ "$CONTINUOUS_MODE" == "true" || "$active_dispatch" == "clipboard" ]]; then
        dispatch_clipboard "$FINAL_CODE" || true
        trigger_autopaste
    fi

    # Desktop notification (only fires in continuous mode -c after processing)
    local PREVIEW
    PREVIEW="$(echo "$FINAL_CODE" | head -n 3)"
    desktop_notify "✔ Code Ready (.${CLEAN_EXT})" "$PREVIEW" "normal" "accessories-text-editor"
    return 0
}

# ------------------------------------------------------------------------------
# 5. Execution Mode (Single-Shot vs Continuous Daemon)
# ------------------------------------------------------------------------------
if [[ -n "$RAW_TEXT_OVERRIDE" ]]; then
    run_dictate_pipeline
    exit 0
fi

if [[ "$CONTINUOUS_MODE" == "true" ]]; then
    printf "\n${COLOR_CYAN}===> Continuous Voice Code Daemon Active (.${CLEAN_EXT})${COLOR_RESET} (Wake word: ${COLOR_CYAN}\"%s\"${COLOR_RESET}, Press Ctrl+C to stop)\n" "${WAKE_WORD:-none}" >&2
    while true; do
        run_dictate_pipeline || true
        sleep 0.3
    done
else
    run_dictate_pipeline
fi
