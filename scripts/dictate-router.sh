#!/usr/bin/env bash
# ==============================================================================
# Dual Wake-Word Orchestrator (scripts/dictate-router.sh)
# ==============================================================================
# Routes spoken commands based on the wake word prefix:
#   - "computer ..." -> scripts/dictate-agent.sh (Agent instruction pipeline)
#   - "syntax ..." / "code ..." -> scripts/dictate_v2.sh (Deterministic AST pipeline)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

for loc in "${XDG_CONFIG_HOME:-$HOME/.config}/ai_dotfiles/.env" "${REPO_ROOT}/.env" "${PWD}/.env"; do
    if [[ -f "$loc" ]]; then
        # shellcheck disable=SC1090
        source "$loc"
        break
    fi
done

TMP_DIR="${AI_TMP_DIR:-/tmp/ai_dotfiles}"
mkdir -p "$TMP_DIR"
AUDIO_FILE="${TMP_DIR}/router_recording.wav"

WHISPER_BIN="${WHISPER_BIN_PATH:-whisper-cli}"
if ! command -v "$WHISPER_BIN" &>/dev/null; then
    for c in "${HOME}/.local/bin/whisper-cli" "${HOME}/.local/share/whisper.cpp/src/build/bin/whisper-cli" "${HOME}/.local/share/whisper.cpp/build/bin/whisper-cli"; do
        [[ -x "$c" ]] && WHISPER_BIN="$c" && break
    done
fi
WHISPER_MODEL="${WHISPER_MODEL_PATH:-$HOME/.local/share/whisper.cpp/models/ggml-base.en.bin}"

AGENT_WAKE="${AGENT_WAKE_WORD:-computer}"
SYNTAX_WAKE="${SYNTAX_WAKE_WORD:-syntax|code}"
TARGET_EXT="${1:-${DEFAULT_LANG_EXT:-py}}"
CONTINUOUS=false
[[ "${2:-}" == "-c" || "${2:-}" == "--continuous" || "${1:-}" == "-c" ]] && CONTINUOUS=true
[[ "${1:-}" == "-c" || "${1:-}" == "--continuous" ]] && TARGET_EXT="${DEFAULT_LANG_EXT:-py}"

log_info() { printf "[dictate-router] INFO: %s\n" "$*" >&2; }

route_once() {
    local RECORDER_SCRIPT="${SCRIPT_DIR}/audio/record_until_silence.py"
    rm -f "$AUDIO_FILE"
    if ! python3 "$RECORDER_SCRIPT" \
        --output "$AUDIO_FILE" \
        --silence-duration "${AUDIO_SILENCE_DURATION:-5.0}" \
        --threshold "${AUDIO_SILENCE_THRESHOLD:-2.0%}" \
        --sample-rate "${AUDIO_SAMPLE_RATE:-16000}" \
        --wait-timeout "${AUDIO_LISTEN_TIMEOUT:-30.0}" \
        --max-duration "${AUDIO_MAX_DURATION:-120.0}" \
        --backend "${AUDIO_RECORDER:-auto}" \
        --device "${AUDIO_DEVICE:-default}" \
        --prefix "[dictate-router] " >&2; then
        return 0
    fi

    [[ ! -s "$AUDIO_FILE" ]] && return 0

    local raw
    raw="$("$WHISPER_BIN" -m "$WHISPER_MODEL" -f "$AUDIO_FILE" -t "${WHISPER_THREADS:-4}" -ng --no-timestamps 2>/dev/null | tr '\n\r\t' ' ' | sed -E 's/[[:space:]]+/ /g; s/^[[:space:]]+//; s/[[:space:]]+$//' || true)"
    [[ -z "$raw" ]] && return 0
    log_info "Heard: \"${raw}\""

    shopt -s nocasematch
    local agent_pat="^[[:space:]]*((uh|um|hey|ok|okay)[[:space:],.:;!?-]+)?(${AGENT_WAKE})[[:space:],.:;!?-]*(.*)$"
    local syntax_pat="^[[:space:]]*((uh|um|hey|ok|okay)[[:space:],.:;!?-]+)?(${SYNTAX_WAKE})[[:space:],.:;!?-]*(.*)$"

    if [[ "$raw" =~ $agent_pat ]]; then
        shopt -u nocasematch
        local body="${BASH_REMATCH[4]}"
        log_info "Wake word '${AGENT_WAKE}' -> Routing to dictate-agent.sh"
        [[ -n "$body" ]] && "${SCRIPT_DIR}/dictate-agent.sh" --no-wake-word --raw-text "$body"
    elif [[ "$raw" =~ $syntax_pat ]]; then
        shopt -u nocasematch
        local body="${BASH_REMATCH[4]}"
        log_info "Wake word '${SYNTAX_WAKE}' -> Routing to dictate_v2.sh (.${TARGET_EXT})"
        [[ -n "$body" ]] && "${SCRIPT_DIR}/dictate_v2.sh" --no-wake-word --ext "$TARGET_EXT" --raw-text "$body"
    else
        shopt -u nocasematch
        log_info "No matching wake word (${AGENT_WAKE} | ${SYNTAX_WAKE}); ignoring."
    fi
}

if [[ "$CONTINUOUS" == "true" ]]; then
    log_info "Router active (.${TARGET_EXT}) | '${AGENT_WAKE}' -> agent | '${SYNTAX_WAKE}' -> syntax AST"
    trap 'echo "" >&2; exit 0' INT TERM
    while true; do
        route_once || true
        sleep 0.3
    done
else
    route_once
fi
