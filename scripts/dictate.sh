#!/usr/bin/env bash
# ==============================================================================
# Dynamic Whisper Context & LLM Piping Pipeline
# ==============================================================================
# Role: Transcribes pre-recorded speech using whisper.cpp with dynamic language-
#       specific vocabulary biasing (--prompt), then pipes raw text into a local
#       LLM (Ollama or LM Studio) to strictly format and emit clean code to stdout.
#
# Usage:
#   dictate.sh [OPTIONS] <FILE_EXTENSION> [AUDIO_WAV_FILE]
#
# Examples:
#   dictate.sh py
#   dictate.sh rs /tmp/ai_dotfiles/input_recording.wav
#   dictate.sh ts --audio /tmp/speech.wav
#   dictate.sh --ext py --raw-text "def snake case get user by id open paren close paren"
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# 1. Environment & Configuration Loading
# ------------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
    # Diagnostic logs go strictly to stderr so stdout remains clean for IDE capture
    printf "[WARN] lang_prompts.env not found. Defining fallback vocabulary.\n" >&2
    PROMPT_DEFAULT="code, programming, function, variable, parameter, return, class, method, import, async, await"
fi

# ------------------------------------------------------------------------------
# 2. Defaults and Hardware Optimization
# ------------------------------------------------------------------------------
TMP_DIR="${AI_TMP_DIR:-/tmp/ai_dotfiles}"
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
WHISPER_MODEL="${WHISPER_MODEL_PATH:-$HOME/.local/share/whisper.cpp/models/ggml-large-v3-turbo.bin}"
WHISPER_THREADS="${WHISPER_THREADS:-4}"
# CPU-only constraint: 0 GPU layers offloaded
WHISPER_N_GPU_LAYERS="${WHISPER_N_GPU_LAYERS:-0}"

LLM_ENDPOINT="${LOCAL_LLM_ENDPOINT:-http://localhost:11434}"
LLM_MODEL="${LLM_MODEL_NAME:-prompt-optimizer:latest}"
LLM_TIMEOUT="${LLM_TIMEOUT_SECONDS:-15}"

COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"
COLOR_YELLOW="\033[1;33m"
COLOR_CYAN="\033[1;36m"
COLOR_BOLD="\033[1m"
COLOR_RESET="\033[0m"

# Diagnostic helper: all status/errors written to stderr
log_err()  { printf "[dictate] ERROR: %s\n" "$*" >&2; }
log_warn() { printf "[dictate] WARN: %s\n" "$*" >&2; }
log_info() { printf "[dictate] INFO: %s\n" "$*" >&2; }
log_wake_success() {
    printf "  ${COLOR_GREEN}✔${COLOR_RESET} ${COLOR_BOLD}[dictate]${COLOR_RESET} Wake word ${COLOR_CYAN}\"%s\"${COLOR_RESET} detected — ${COLOR_GREEN}${COLOR_BOLD}LISTENING${COLOR_RESET}\n" "$*" >&2
}
log_wake_fail() {
    printf "  ${COLOR_RED}✖${COLOR_RESET} ${COLOR_BOLD}[dictate]${COLOR_RESET} Wake word ${COLOR_CYAN}\"%s\"${COLOR_RESET} not detected — ${COLOR_RED}${COLOR_BOLD}NOT LISTENING${COLOR_RESET}\n" "$*" >&2
}
log_no_speech() {
    printf "  ${COLOR_RED}✖${COLOR_RESET} ${COLOR_BOLD}[dictate]${COLOR_RESET} No speech detected — ${COLOR_RED}${COLOR_BOLD}NOT LISTENING${COLOR_RESET}\n" >&2
}

# ------------------------------------------------------------------------------
# 3. CLI Argument Parsing
# ------------------------------------------------------------------------------
TARGET_EXT=""
AUDIO_FILE=""
RAW_TEXT_OVERRIDE=""

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
    local exit_code="${1:-0}"
    cat >&2 <<EOF
Usage: $(basename "$0") [OPTIONS] <EXTENSION> [AUDIO_FILE]

Arguments:
  <EXTENSION>         Target file extension (e.g. py, rs, ts, go, cpp, sh, sql, json)
  [AUDIO_FILE]        Path to pre-recorded WAV file (default: ${DEFAULT_AUDIO})

Options:
  -e, --ext EXT       Specify target file extension
  -a, --audio FILE    Specify audio WAV input file
  --record            Record microphone audio until silence before transcribing
  --wake-word WORD    Require spoken wake word (e.g. 'computer', 'jarvis'; overrides .env)
  --no-wake-word      Disable wake word check (even if enabled in .env)
  -r, --raw-text STR  Bypass Whisper and pipe raw text directly to LLM formatter
  -m, --model MODEL   Override Ollama/LM Studio model name
  -h, --help          Show this help message
EOF
    exit "$exit_code"
}

# Parse options
POSITIONAL_ARGS=()
FLAG_RECORD=false
CUSTOM_AUDIO_SPECIFIED=false
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
        -m|--model)
            LLM_MODEL="$2"
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

# Resolve positional parameters if flags weren't used
if [[ -z "$TARGET_EXT" && ${#POSITIONAL_ARGS[@]} -ge 1 ]]; then
    TARGET_EXT="${POSITIONAL_ARGS[0]}"
fi

if [[ -z "$AUDIO_FILE" && ${#POSITIONAL_ARGS[@]} -ge 2 ]]; then
    AUDIO_FILE="${POSITIONAL_ARGS[1]}"
    CUSTOM_AUDIO_SPECIFIED=true
elif [[ -z "$AUDIO_FILE" ]]; then
    AUDIO_FILE="$DEFAULT_AUDIO"
fi

# Fallback extension if none provided
if [[ -z "$TARGET_EXT" ]]; then
    log_warn "No file extension specified. Falling back to 'default'."
    TARGET_EXT="default"
fi

# ------------------------------------------------------------------------------
# 4. Context Resolution & Vocabulary Mapping
# ------------------------------------------------------------------------------
# Normalize extension / language string: strip leading dot
RAW_EXT="$(echo "$TARGET_EXT" | sed 's/^\.//')"
CLEAN_EXT="$(echo "$RAW_EXT" | tr '[:upper:]' '[:lower:]')"

# Sanitize into standard uppercase POSIX identifier consistent with lang_prompts.env
SAN_EXT="$(echo "$RAW_EXT" \
    | sed -e 's/c++/cpp/g' -e 's/C++/CPP/g' \
          -e 's/c#/cs/g'   -e 's/C#/CS/g' \
          -e 's/f#/fs/g'   -e 's/F#/FS/g' \
          -e 's/q#/qs/g'   -e 's/Q#/QS/g' \
          -e 's/1c/one_c/g' -e 's/1C/ONE_C/g' \
          -e 's/4d/four_d/g' -e 's/4D/FOUR_D/g' \
          -e 's/+/_p_/g'   -e 's/#/_s_/g' \
          -e 's/[^a-zA-Z0-9_]/_/g' \
          -e 's/__*/_/g'   -e 's/^_//' -e 's/_$//' \
    | tr '[:lower:]' '[:upper:]')"

if [[ "$SAN_EXT" =~ ^[0-9] ]]; then
    SAN_EXT="LANG_${SAN_EXT}"
fi

VOCAB_VAR_NAME="PROMPT_${SAN_EXT}"

# Dynamic variable lookup: ${!VAR} resolves the value of PROMPT_<EXT_OR_LANG>
if [[ -n "${!VOCAB_VAR_NAME:-}" ]]; then
    VOCAB_PROMPT="${!VOCAB_VAR_NAME}"
    log_info "Active context: [${CLEAN_EXT}] -> \${${VOCAB_VAR_NAME}} (Injected ${#VOCAB_PROMPT} chars of domain vocabulary)"
else
    VOCAB_PROMPT="${PROMPT_DEFAULT:-code, function, variable, parameter, return}"
    log_warn "No prompt mapping found for extension '${CLEAN_EXT}' (\${${VOCAB_VAR_NAME}}). Using generic default vocabulary."
fi

# ------------------------------------------------------------------------------
# 5. Whisper Audio Transcription (whisper.cpp)
# ------------------------------------------------------------------------------
RAW_TRANSCRIPT=""

if [[ -n "$RAW_TEXT_OVERRIDE" ]]; then
    # Fast path: user supplied raw text directly (skips whisper execution)
    RAW_TRANSCRIPT="$RAW_TEXT_OVERRIDE"
    log_info "Using raw text override: \"${RAW_TRANSCRIPT}\""
else
    # If no custom audio file was passed, record fresh audio from microphone
    RECORD_SCRIPT="${SCRIPT_DIR}/audio/record_until_silence.py"
    if [[ "$CUSTOM_AUDIO_SPECIFIED" == "false" || "$FLAG_RECORD" == "true" ]]; then
        if [[ -f "$RECORD_SCRIPT" ]] && command -v python3 &>/dev/null; then
            # Clean up stale audio file before recording
            rm -f "$AUDIO_FILE"

            if ! python3 "$RECORD_SCRIPT" \
                --output "$AUDIO_FILE" \
                --silence-duration "${AUDIO_SILENCE_DURATION:-5.0}" \
                --threshold "${AUDIO_SILENCE_THRESHOLD:-2.0%}" \
                --sample-rate "${AUDIO_SAMPLE_RATE:-16000}" \
                --wait-timeout "${AUDIO_LISTEN_TIMEOUT:-${LISTEN_TIMEOUT:-${AUDIO_WAIT_TIMEOUT:-30.0}}}" \
                --max-duration "${AUDIO_MAX_DURATION:-120.0}" \
                --backend "${AUDIO_RECORDER:-auto}" \
                --device "${AUDIO_DEVICE:-default}" \
                --prefix "[dictate] " >&2; then
                log_no_speech
                exit 0
            fi
        fi
    fi

    # Verify audio file existence and non-empty
    if [[ ! -f "$AUDIO_FILE" || ! -s "$AUDIO_FILE" ]]; then
        log_no_speech
        exit 0
    fi

    # Verify whisper binary
    if ! command -v "$WHISPER_BIN" &>/dev/null && [[ ! -x "$WHISPER_BIN" ]]; then
        log_err "whisper.cpp binary not executable at: ${WHISPER_BIN}"
        log_err "Compile it via 'scripts/setup/setup_whisper_cpp.sh' or set WHISPER_BIN_PATH."
        exit 1
    fi

    # Verify model weights file
    if [[ ! -f "$WHISPER_MODEL" ]]; then
        log_err "Whisper model not found at: ${WHISPER_MODEL}"
        exit 1
    fi

    log_info "Transcribing ${AUDIO_FILE} via whisper.cpp (CPU threads: ${WHISPER_THREADS}, GPU layers: ${WHISPER_N_GPU_LAYERS})..."

    # Execute whisper-cli:
    #   --prompt      : Injects the language-specific vocabulary to prime the acoustic decoder.
    #   -ng           : Enforces CPU-only execution (disables GPU offloading).
    #   -nt           : Suppresses timestamp markers from stdout.
    #   -np           : Suppresses info/banner prints, leaving clean transcript output.
    #   stderr is redirected to /dev/null so timing/loading stats do not corrupt stdout.
    WHISPER_GPU_ARGS=()
    if [[ "${WHISPER_N_GPU_LAYERS:-0}" == "0" ]]; then
        WHISPER_GPU_ARGS+=("-ng")
    fi

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

    # Clean whitespace and strip empty lines
    RAW_TRANSCRIPT="$(echo "$WHISPER_OUTPUT" | tr -d '\r' | sed '/^[[:space:]]*$/d' | paste -sd " " - || true)"
fi

if [[ -z "${RAW_TRANSCRIPT// }" ]]; then
    log_no_speech
    exit 0
fi

log_info "Whisper Raw Transcript: \"${RAW_TRANSCRIPT}\""

# Wake Word Verification & Stripping
WAKE_WORD_SETTING="${WAKE_WORD:-}"
WAKE_WORD_CHECK="${WAKE_WORD_ENABLED:-false}"

if [[ "$WAKE_WORD_CHECK" == "true" && -n "$WAKE_WORD_SETTING" ]]; then
    if STRIPPED_PROMPT="$(check_wake_word "$RAW_TRANSCRIPT" "$WAKE_WORD_SETTING" "${WAKE_WORD_STRIP:-true}")"; then
        log_wake_success "$WAKE_WORD_SETTING"
        if [[ -z "$STRIPPED_PROMPT" ]]; then
            log_warn "Wake word detected, but no code command followed. Exiting."
            exit 0
        fi
        RAW_TRANSCRIPT="$STRIPPED_PROMPT"
        log_info "Cleaned speech (wake word stripped): \"${RAW_TRANSCRIPT}\""
    else
        log_wake_fail "$WAKE_WORD_SETTING"
        exit 0
    fi
fi

# ------------------------------------------------------------------------------
# 6. LLM Code Formatting & Structural Normalization (Ollama / LM Studio)
# ------------------------------------------------------------------------------
# Piping Logic:
# 1. Provide current system date/time so temporal grammar rules expand accurately:
#    - "american date today" -> MM/DD/YYYY
#    - "iso date today"      -> YYYY-MM-DD
# 2. Instruct the LLM to format exclusively in the requested file extension/syntax.
# 3. Apply grammar rules (snake_case, camelCase, arrow functions, operators).
# 4. Enforce STRICT code output: no conversational commentary, no markdown fences.

DATE_AMERICAN="$(date +%m/%d/%Y)"
DATE_ISO="$(date +%Y-%m-%d)"

SYSTEM_PROMPT=$(cat <<EOF
You are a precise, deterministic code compiler and spoken-grammar formatter for developers.
The user dictated code and commands meant for a file with extension: .${CLEAN_EXT}

Current System Dates for temporal macro expansion:
- American Date Today: ${DATE_AMERICAN}
- ISO Date Today: ${DATE_ISO}

Grammar Rules & Transformations:
1. Spoken symbols & casing:
   - "snake case <X>" -> snake_case_x
   - "camel case <X>" -> camelCaseX
   - "pascal case <X>" -> PascalCaseX
   - "constant case <X>" / "screaming snake <X>" -> CONSTANT_CASE_X
   - "kebab case <X>" -> kebab-case-x
   - "arrow func" / "fat arrow" -> =>
   - "thin arrow" / "returns" -> ->
   - "equals equals" / "is equal to" -> == (or === in JS/TS)
   - "not equals" -> != (or !== in JS/TS)
   - "and and" -> &&
   - "or or" -> ||
   - "bang" -> !

2. Sci-Fi & Spoken Monosyllabic Keywords:
   - "core <X>" / "fn <X>" / "def <X>" / "spark <X>" -> function definition <X>
   - "strand" / "wire" -> string / str / String
   - "count" -> int / integer / i32 / i64
   - "drift" -> float / double / f64
   - "bit" -> bool / boolean
   - "void" -> void / None / nil / ()
   - "pulse" -> true / True
   - "dead" -> false / False
   - "hull <X>" -> struct <X>
   - "clan <X>" -> class <X>
   - "port <X>" -> interface <X>
   - "dock <X>" -> import <X>
   - "ship <X>" -> export <X>
   - "lock <X>" -> const <X>
   - "flux <X>" -> var <X> / let mut <X>
   - "bind <X>" -> let <X>
   - "sync <X>" -> async <X>
   - "hold <X>" -> await <X> / while <X>
   - "yield <X>" -> return <X>

3. Chained Intent & Compound Constructs (Continuous Single-Breath Dictation):
   - The user may dictate an entire multi-statement function in a single sentence. Format it into an idiomatic, indented function block for .${CLEAN_EXT}.
   - Function Signatures:
     "[fn|def|core] <name> with <param1> <type1> <param2> <type2> [to|yields|returns] <ret_type>"
     -> Format into a clean, typed signature in .${CLEAN_EXT}.
   - Guard Clauses:
     "guard <var> [fail|breach|raise] <message>"
     -> Expand into early return or exception:
        - Python (.py): if not <var>:\n    raise ValueError("<message>")
        - Rust (.rs): if <var> == 0 { return Err(anyhow!("<message>")); } (or if !<var>)
        - TypeScript (.ts/.js): if (!<var>) {\n    throw new Error("<message>");\n}
        - Go (.go): if <var> == nil { return nil, errors.New("<message>") }
     "guard <var>" alone:
        - Python (.py): if not <var>:\n    raise ValueError("<var> is required")
        - TypeScript (.ts/.js): if (!<var>) throw new Error("<var> is required");
   - Formatted Returns & String Interpolation:
     "return format <text and vars>" / "yield strand <text and vars>" / "return <vars> formatted"
     -> Language-idiomatic string interpolation:
        - Python (.py): return f"<text> {<var>}"
        - Rust (.rs): Ok(format!("<text> {}", <var>)) (or format!("<text> {}", <var>))
        - TypeScript (.ts/.js): return \`<text> \${<var>}\`;
        - Go (.go): return fmt.Sprintf("<text> %v", <var>)

4. Temporal & Boilerplate macros:
   - "american date today" -> ${DATE_AMERICAN}
   - "iso date today" / "date today" -> ${DATE_ISO}

5. Output Constraints:
   - Convert spoken code keywords, variable names, and logic into valid, idiomatic .${CLEAN_EXT} code.
   - Output ONLY the final source code or expression.
   - Do NOT wrap the output in markdown code fences (\`\`\`) unless explicitly asked.
   - Do NOT output any introductory text, apologies, pleasantries, or explanations.
EOF
)

# Verify jq is installed for clean JSON encoding and decoding
if ! command -v jq &>/dev/null; then
    log_err "jq is required for API piping. Please install jq."
    # Output raw transcript as emergency fallback
    printf "%s\n" "$RAW_TRANSCRIPT"
    exit 0
fi

# Detect whether endpoint is Ollama (/api/generate) or OpenAI/LM Studio compatible (/v1)
IS_OPENAI_COMPATIBLE=false
if [[ "$LLM_ENDPOINT" =~ /v1(/.*)?$ ]]; then
    IS_OPENAI_COMPATIBLE=true
fi

# Construct API Payload safely using jq
if [[ "$IS_OPENAI_COMPATIBLE" == "true" ]]; then
    API_URL="${LLM_ENDPOINT%/}/chat/completions"
    # OpenAI/LM Studio payload structure:
    # {
    #   "model": "model_name",
    #   "messages": [
    #     {"role": "system", "content": "..."},
    #     {"role": "user", "content": "..."}
    #   ],
    #   "temperature": 0.1,
    #   "stream": false
    # }
    PAYLOAD="$(jq -n \
        --arg model "$LLM_MODEL" \
        --arg system "$SYSTEM_PROMPT" \
        --arg user "$RAW_TRANSCRIPT" \
        '{
            model: $model,
            messages: [
                {role: "system", content: $system},
                {role: "user", content: $user}
            ],
            temperature: 0.1,
            stream: false
        }')"
else
    API_URL="${LLM_ENDPOINT%/}/api/generate"
    # Ollama payload structure:
    # {
    #   "model": "model_name",
    #   "prompt": "raw speech",
    #   "system": "system prompt",
    #   "stream": false,
    #   "options": {"temperature": 0.1, "num_predict": 512}
    # }
    PAYLOAD="$(jq -n \
        --arg model "$LLM_MODEL" \
        --arg system "$SYSTEM_PROMPT" \
        --arg prompt "$RAW_TRANSCRIPT" \
        '{
            model: $model,
            prompt: $prompt,
            system: $system,
            stream: false,
            options: {
                temperature: 0.1,
                num_predict: 512
            }
        }')"
fi

log_info "Piping raw text to LLM (${LLM_MODEL} @ ${API_URL})..."

HTTP_RESPONSE="$(curl -sS --max-time "$LLM_TIMEOUT" \
    -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD" 2>/dev/null || true)"

FORMATTED_CODE=""

if [[ -n "$HTTP_RESPONSE" ]]; then
    if [[ "$IS_OPENAI_COMPATIBLE" == "true" ]]; then
        FORMATTED_CODE="$(echo "$HTTP_RESPONSE" | jq -re '.choices[0].message.content // empty' 2>/dev/null || true)"
    else
        FORMATTED_CODE="$(echo "$HTTP_RESPONSE" | jq -re '.response // empty' 2>/dev/null || true)"
    fi
fi

# If LLM returned empty or failed to respond, fallback to raw transcript
if [[ -z "${FORMATTED_CODE// }" ]]; then
    log_warn "LLM optimization returned empty or failed. Falling back to raw transcript."
    FORMATTED_CODE="$RAW_TRANSCRIPT"
fi

# ------------------------------------------------------------------------------
# 7. Emit Formatted Output to stdout
# ------------------------------------------------------------------------------
# stdout is captured by Cursor, VS Code, or shell redirection
printf "%s\n" "$FORMATTED_CODE"
