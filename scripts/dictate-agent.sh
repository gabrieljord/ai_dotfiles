#!/usr/bin/env bash
# ==============================================================================
# Dedicated Agent Voice Pipeline (scripts/dictate-agent.sh)
# ==============================================================================
# Role: Transcribes voice via whisper.cpp, compresses rambling speech into a
#       concise, actionable instruction via an LLM prompt optimizer (bypassing
#       the v2 AST pipeline), and dispatches it directly to your CLI agent (agy).
#
# Usage:
#   dictate-agent.sh [OPTIONS] [AUDIO_FILE]
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Load .env
for loc in "${XDG_CONFIG_HOME:-$HOME/.config}/ai_dotfiles/.env" "${REPO_ROOT}/.env" "${PWD}/.env"; do
    if [[ -f "$loc" ]]; then
        # shellcheck disable=SC1090
        source "$loc"
        break
    fi
done

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
WHISPER_MODEL="${WHISPER_MODEL_PATH:-$HOME/.local/share/whisper.cpp/models/ggml-base.en.bin}"
WHISPER_THREADS="${WHISPER_THREADS:-4}"
WHISPER_N_GPU_LAYERS="${WHISPER_N_GPU_LAYERS:-0}"

COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"
COLOR_CYAN="\033[1;36m"
COLOR_BOLD="\033[1m"
COLOR_RESET="\033[0m"

log_err()  { printf "[dictate-agent] ERROR: %s\n" "$*" >&2; }
log_warn() { printf "[dictate-agent] WARN: %s\n" "$*" >&2; }
log_info() { printf "[dictate-agent] INFO: %s\n" "$*" >&2; }
log_wake_success() {
    printf "  ${COLOR_GREEN}✔${COLOR_RESET} ${COLOR_BOLD}[dictate-agent]${COLOR_RESET} Wake word ${COLOR_CYAN}\"%s\"${COLOR_RESET} detected — ${COLOR_GREEN}${COLOR_BOLD}LISTENING${COLOR_RESET}\n" "$*" >&2
}
log_wake_fail() {
    printf "  ${COLOR_RED}✖${COLOR_RESET} ${COLOR_BOLD}[dictate-agent]${COLOR_RESET} Wake word ${COLOR_CYAN}\"%s\"${COLOR_RESET} not detected — ${COLOR_RED}${COLOR_BOLD}NOT LISTENING${COLOR_RESET}\n" "$*" >&2
}
log_no_speech() {
    printf "  ${COLOR_RED}✖${COLOR_RESET} ${COLOR_BOLD}[dictate-agent]${COLOR_RESET} No speech detected — ${COLOR_RED}${COLOR_BOLD}NOT LISTENING${COLOR_RESET}\n" >&2
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
    fi
    shopt -u nocasematch
    return 1
}

dispatch_to_agent() {
    local text="$1"
    local method="${DISPATCH_METHOD_OVERRIDE:-agent}"

    if [[ "$method" == "stdout" ]]; then
        printf "%s\n" "$text"
        return 0
    elif [[ "$method" == "clipboard" ]]; then
        if command -v wl-copy &>/dev/null; then
            printf "%s" "$text" | wl-copy
        elif command -v xclip &>/dev/null; then
            printf "%s" "$text" | xclip -selection clipboard
        elif command -v pbcopy &>/dev/null; then
            printf "%s" "$text" | pbcopy
        fi
        printf "%s\n" "$text"
        return 0
    elif [[ "$method" == "tmux" ]]; then
        local target="${TMUX_TARGET_PANE:-}"
        if [[ -z "$target" ]] || ! command -v tmux &>/dev/null; then
            log_err "tmux or TMUX_TARGET_PANE unavailable."
            return 1
        fi
        printf "%s" "$text" | tmux load-buffer - && tmux paste-buffer -t "$target"
        [[ "${TMUX_SEND_ENTER:-false}" == "true" ]] && tmux send-keys -t "$target" Enter
        log_info "Dispatched prompt to tmux pane: ${target}"
        return 0
    fi

    # Default: dispatch directly to CLI agent (e.g. agy -c -p)
    local cmd_str="${AGENT_DISPATCH_CMD:-}"
    if [[ -z "$cmd_str" ]]; then
        if command -v agy &>/dev/null; then
            cmd_str="agy -c -p"
        elif command -v claude &>/dev/null; then
            cmd_str="claude -c -p"
        else
            log_err "AGENT_DISPATCH_CMD is not set and no supported CLI agent (agy, claude) was found."
            return 1
        fi
    fi

    local -a cmd_parts
    read -r -a cmd_parts <<< "$cmd_str"
    local last_arg="${cmd_parts[$((${#cmd_parts[@]} - 1))]}"
    log_info "Dispatching to CLI agent: ${cmd_str}"
    if [[ "$last_arg" == "-p" || "$last_arg" == "--print" || "$last_arg" == "--prompt" || "$last_arg" == "--message" || "$last_arg" == "-m" ]]; then
        "${cmd_parts[@]}" "$text"
    else
        printf "%s" "$text" | "${cmd_parts[@]}"
    fi
}

usage() {
    cat >&2 <<EOF
Usage: $(basename "$0") [OPTIONS] [AUDIO_FILE]

Options:
  -a, --audio FILE    Specify audio WAV input file
  -c, --continuous    Run continuous agent voice daemon until Ctrl+C
  --record            Force microphone recording
  --wake-word WORD    Require spoken wake word (e.g. 'computer')
  --no-wake-word      Disable wake word check
  -r, --raw-text STR  Bypass Whisper and optimize/dispatch raw text directly
  --provider NAME     Override optimizer LLM provider (default: .env LLM_PROVIDER)
  --model NAME        Override optimizer LLM model
  --dispatch METHOD   Override dispatch target (agent, stdout, clipboard, tmux; default: agent)
  --no-optimize       Skip LLM prompt optimization and send transcript directly
  -h, --help          Show this help message
EOF
    exit "${1:-0}"
}

AUDIO_FILE=""
RAW_TEXT_OVERRIDE=""
CONTINUOUS_MODE="${CONTINUOUS_MODE:-false}"
FLAG_RECORD=false
CUSTOM_AUDIO_SPECIFIED=false
DISPATCH_METHOD_OVERRIDE="agent"
NO_OPTIMIZE=false
WAKE_WORD_OVERRIDE=""
WAKE_WORD_FORCED_OFF=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -a|--audio) AUDIO_FILE="$2"; CUSTOM_AUDIO_SPECIFIED=true; shift 2 ;;
        -c|--continuous) CONTINUOUS_MODE=true; shift ;;
        --record) FLAG_RECORD=true; shift ;;
        --wake-word) WAKE_WORD_OVERRIDE="$2"; WAKE_WORD_ENABLED=true; shift 2 ;;
        --no-wake-word) WAKE_WORD_FORCED_OFF=true; WAKE_WORD_ENABLED=false; shift ;;
        -r|--raw-text) RAW_TEXT_OVERRIDE="$2"; shift 2 ;;
        --provider) export LLM_PROVIDER="$2"; shift 2 ;;
        --model) export LLM_MODEL_NAME="$2"; export AGENT_CLI_MODEL="$2"; shift 2 ;;
        --dispatch) DISPATCH_METHOD_OVERRIDE="$2"; shift 2 ;;
        --no-optimize) NO_OPTIMIZE=true; shift ;;
        -h|--help) usage 0 ;;
        -*) log_err "Unknown option: $1"; usage 1 ;;
        *)
            if [[ -z "$AUDIO_FILE" ]]; then
                AUDIO_FILE="$1"
                CUSTOM_AUDIO_SPECIFIED=true
            fi
            shift
            ;;
    esac
done

[[ -z "$AUDIO_FILE" ]] && AUDIO_FILE="$DEFAULT_AUDIO"

run_agent_pipeline() {
    local RAW_TRANSCRIPT=""

    if [[ -n "$RAW_TEXT_OVERRIDE" ]]; then
        RAW_TRANSCRIPT="$RAW_TEXT_OVERRIDE"
        log_info "Using raw text input: \"${RAW_TRANSCRIPT}\""
    else
        if [[ "$CUSTOM_AUDIO_SPECIFIED" == "false" || "$FLAG_RECORD" == "true" ]]; then
            local RECORDER_SCRIPT="${SCRIPT_DIR}/audio/record_until_silence.py"
            if [[ -f "$RECORDER_SCRIPT" ]] && command -v python3 &>/dev/null; then
                rm -f "$AUDIO_FILE"
                if ! python3 "$RECORDER_SCRIPT" \
                    --output "$AUDIO_FILE" \
                    --silence-duration "${AUDIO_SILENCE_DURATION:-5.0}" \
                    --threshold "${AUDIO_SILENCE_THRESHOLD:-2.0%}" \
                    --sample-rate "${AUDIO_SAMPLE_RATE:-16000}" \
                    --wait-timeout "${AUDIO_LISTEN_TIMEOUT:-${LISTEN_TIMEOUT:-30.0}}" \
                    --max-duration "${AUDIO_MAX_DURATION:-120.0}" \
                    --backend "${AUDIO_RECORDER:-auto}" \
                    --device "${AUDIO_DEVICE:-default}" \
                    --prefix "[dictate-agent] " >&2; then
                    log_no_speech
                    return 0
                fi
            else
                log_err "Recorder script not found at ${RECORDER_SCRIPT}"
                return 1
            fi
        fi

        if [[ ! -f "$AUDIO_FILE" || ! -s "$AUDIO_FILE" ]]; then
            log_no_speech
            return 0
        fi

        log_info "Transcribing via whisper.cpp (${WHISPER_MODEL})..."
        local WHISPER_GPU_ARGS=()
        [[ "${WHISPER_N_GPU_LAYERS:-0}" == "0" ]] && WHISPER_GPU_ARGS+=("-ng")

        local WHISPER_OUTPUT
        WHISPER_OUTPUT="$(
            "$WHISPER_BIN" \
                -m "$WHISPER_MODEL" \
                -f "$AUDIO_FILE" \
                -t "$WHISPER_THREADS" \
                "${WHISPER_GPU_ARGS[@]}" \
                --no-timestamps 2>/dev/null || true
        )"
        RAW_TRANSCRIPT="$(echo "$WHISPER_OUTPUT" | tr '\n\r\t' ' ' | sed -E 's/[[:space:]]+/ /g; s/^[[:space:]]+//; s/[[:space:]]+$//')"
        if [[ -z "$RAW_TRANSCRIPT" ]]; then
            log_no_speech
            return 0
        fi
        log_info "Whisper Raw Transcript: \"${RAW_TRANSCRIPT}\""
    fi

    # Wake-word check
    local active_wake="${WAKE_WORD_OVERRIDE:-${WAKE_WORD:-}}"
    if [[ "$WAKE_WORD_FORCED_OFF" != "true" && "${WAKE_WORD_ENABLED:-false}" == "true" && -n "$active_wake" ]]; then
        local stripped
        if stripped="$(check_wake_word "$RAW_TRANSCRIPT" "$active_wake" "${WAKE_WORD_STRIP:-true}")"; then
            log_wake_success "$active_wake"
            [[ -z "$stripped" ]] && return 0
            RAW_TRANSCRIPT="$stripped"
        else
            log_wake_fail "$active_wake"
            return 0
        fi
    fi

    # Step 2: Optimize prompt (no AST, direct intent extraction)
    local OPTIMIZED_PROMPT="$RAW_TRANSCRIPT"
    if [[ "$NO_OPTIMIZE" != "true" ]]; then
        local OPT_SYS_FILE="${TMP_DIR}/agent_opt_sys_$$.txt"
        cat > "$OPT_SYS_FILE" <<'EOF'
You are a prompt engineer. The user is dictating instructions for an autonomous coding agent. Strip all conversational filler, umms, and ahs. Output ONLY a concise, direct instruction set that another AI can immediately execute.
EOF
        local OPT_PROVIDER="${AGENT_OPTIMIZER_PROVIDER:-${LLM_PROVIDER:-ollama}}"
        log_info "Optimizing prompt via ${OPT_PROVIDER}..."
        local DECODER_SCRIPT="${SCRIPT_DIR}/pipeline/decoder.py"
        local DECODED_OPT=""
        DECODED_OPT="$(
            printf "%s" "$RAW_TRANSCRIPT" | python3 "$DECODER_SCRIPT" \
                --raw-prompt \
                --provider "$OPT_PROVIDER" \
                --system-prompt-file "$OPT_SYS_FILE" 2>/dev/null || true
        )"
        rm -f "$OPT_SYS_FILE"
        if [[ -n "$DECODED_OPT" ]]; then
            OPTIMIZED_PROMPT="$DECODED_OPT"
        else
            log_warn "Optimizer unavailable; forwarding raw transcript directly."
        fi
    fi

    log_info "Optimized Prompt: \"${OPTIMIZED_PROMPT}\""

    # Step 3: Dispatch directly to CLI agent
    dispatch_to_agent "$OPTIMIZED_PROMPT"
}

if [[ -n "$RAW_TEXT_OVERRIDE" ]]; then
    run_agent_pipeline
    exit 0
fi

if [[ "$CONTINUOUS_MODE" == "true" ]]; then
    printf "\n${COLOR_CYAN}===> Continuous Agent Voice Daemon Active${COLOR_RESET} (Wake word: ${COLOR_CYAN}\"%s\"${COLOR_RESET}, Press Ctrl+C to stop)\n" "${WAKE_WORD_OVERRIDE:-${WAKE_WORD:-none}}" >&2
    trap 'echo "" >&2; exit 0' INT TERM
    while true; do
        run_agent_pipeline || true
        sleep 0.3
    done
else
    run_agent_pipeline
fi
