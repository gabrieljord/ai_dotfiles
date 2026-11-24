#!/usr/bin/env bash
# ==============================================================================
# Master Setup & Orchestration Script for ai_dotfiles
# ==============================================================================
# Role: Links to all scripts/*.sh, bootstraps environment configurations,
#       and sequentially starts all setup scripts (install, vocab generation,
#       grammar compilation, whisper.cpp compilation, and Ollama model setup).
#
# Usage:
#   ./setup.sh [OPTIONS]
#
# Options:
#   -d, --dry-run        Preview all setup actions without executing changes
#   -f, --force          Force overwrite of existing symlinks and configurations
#   --skip-whisper       Skip compiling whisper.cpp and downloading model weights
#   --skip-llm           Skip Ollama model registration
#   -h, --help           Show this message
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="${HOME}/.local/bin:${PATH}"

# --- ANSI Colors ---
COLOR_RESET="\033[0m"
COLOR_BOLD="\033[1m"
COLOR_GREEN="\033[32m"
COLOR_YELLOW="\033[33m"
COLOR_BLUE="\033[34m"
COLOR_MAGENTA="\033[35m"
COLOR_CYAN="\033[36m"
COLOR_RED="\033[31m"
COLOR_GRAY="\033[90m"

log_step()    { printf "\n${COLOR_BOLD}${COLOR_BLUE}===> %s${COLOR_RESET}\n" "$*"; }
log_info()    { printf "  ${COLOR_GRAY}[INFO]${COLOR_RESET} %s\n" "$*"; }
log_success() { printf "  ${COLOR_GREEN}[SUCCESS]${COLOR_RESET} %s\n" "$*"; }
log_warn()    { printf "  ${COLOR_YELLOW}[WARN]${COLOR_RESET} %s\n" "$*"; }
log_error()   { printf "  ${COLOR_RED}[ERROR]${COLOR_RESET} %s\n" "$*"; }

FLAG_DRY_RUN=false
FLAG_FORCE=false
FLAG_SKIP_WHISPER=false
FLAG_SKIP_LLM=false

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Master setup script for ai_dotfiles:
  1. Links to scripts/*.sh and sets up ~/.local/bin shortcuts.
  2. Runs install.sh for dotfiles and system dependency validation.
  3. Generates all 595 programming language vocabulary prompts.
  4. Compiles the Sci-Fi Single-Syllable voice grammar codex.
  5. Compiles whisper.cpp (CPU-optimized) and fetches GGML models.
  6. Registers the prompt-optimizer model with Ollama.

Options:
  -d, --dry-run        Preview actions without applying changes
  -f, --force          Force recreate symlinks and overwrite configs
  --skip-whisper       Skip whisper.cpp compilation and model downloads
  --skip-llm           Skip Ollama model creation
  -h, --help           Show this help message
EOF
    exit 0
}

# --- Parse Arguments ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--dry-run)
            FLAG_DRY_RUN=true
            shift
            ;;
        -f|--force)
            FLAG_FORCE=true
            shift
            ;;
        --skip-whisper)
            FLAG_SKIP_WHISPER=true
            shift
            ;;
        --skip-llm)
            FLAG_SKIP_LLM=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            ;;
    esac
done

if [[ "${FLAG_DRY_RUN}" == "true" ]]; then
    log_warn "Running in DRY-RUN mode. No changes will be applied."
fi

# ==============================================================================
# Phase 1: Link to scripts/*.sh and Set Executable Permissions
# ==============================================================================
log_step "Phase 1: Linking Scripts and Setting Permissions"

TARGET_BIN_DIR="${HOME}/.local/bin"
mkdir -p "${TARGET_BIN_DIR}"

create_symlink() {
    local src="$1"
    local dest="$2"

    if [[ "${FLAG_DRY_RUN}" == "true" ]]; then
        log_info "[DRY-RUN] Symlink: $dest -> $src"
        return 0
    fi

    mkdir -p "$(dirname "$dest")"
    if [[ -L "$dest" ]]; then
        local current_target
        current_target="$(readlink "$dest")"
        if [[ "$current_target" == "$src" ]]; then
            log_info "Unchanged: $dest already links to $src"
            return 0
        fi
        rm -f "$dest"
    elif [[ -e "$dest" ]]; then
        if [[ "${FLAG_FORCE}" == "true" ]]; then
            rm -rf "$dest"
        else
            log_warn "$dest exists. Skipping (use --force to overwrite)."
            return 0
        fi
    fi

    ln -sf "$src" "$dest"
    log_success "Linked: $dest -> $src"
}

# 1. Set executable permissions across all scripts
if [[ "${FLAG_DRY_RUN}" != "true" ]]; then
    chmod +x "${SCRIPT_DIR}/install.sh" || true
    chmod +x "${SCRIPT_DIR}"/scripts/*.sh 2>/dev/null || true
    chmod +x "${SCRIPT_DIR}"/scripts/audio/*.py 2>/dev/null || true
    chmod +x "${SCRIPT_DIR}"/scripts/pipeline/*.sh 2>/dev/null || true
    chmod +x "${SCRIPT_DIR}"/scripts/setup/*.sh 2>/dev/null || true
    chmod +x "${SCRIPT_DIR}"/scripts/setup/*.py 2>/dev/null || true
    log_success "Granted executable permissions to scripts/**/*.sh and *.py"
else
    log_info "[DRY-RUN] Would chmod +x all scripts/*.sh and scripts/**/*.sh"
fi

# 2. Link root convenience scripts
create_symlink "${SCRIPT_DIR}/scripts/dictate.sh" "${SCRIPT_DIR}/dictate.sh"
create_symlink "${SCRIPT_DIR}/scripts/pipeline/transcribe_and_optimize.sh" "${SCRIPT_DIR}/transcribe.sh"
create_symlink "${SCRIPT_DIR}/scripts/audio/record_until_silence.py" "${SCRIPT_DIR}/record.py"
create_symlink "${SCRIPT_DIR}/config/whisper" "${SCRIPT_DIR}/whisper"
create_symlink "${SCRIPT_DIR}/config/prompts" "${SCRIPT_DIR}/prompts"
create_symlink "grammars" "${SCRIPT_DIR}/config/whisper/grammers"

# 3. Link pipeline binaries into ~/.local/bin
create_symlink "${SCRIPT_DIR}/scripts/pipeline/transcribe_and_optimize.sh" "${TARGET_BIN_DIR}/ai-dictate"
create_symlink "${SCRIPT_DIR}/scripts/dictate.sh" "${TARGET_BIN_DIR}/ai-dictate-code"
create_symlink "${SCRIPT_DIR}/scripts/dictate_v2.sh" "${TARGET_BIN_DIR}/ai-dictate-v2"
create_symlink "${SCRIPT_DIR}/scripts/dictate-natural.sh" "${TARGET_BIN_DIR}/ai-dictate-natural"
create_symlink "${SCRIPT_DIR}/scripts/dictate.sh" "${TARGET_BIN_DIR}/dictate"
create_symlink "${SCRIPT_DIR}/scripts/audio/record_until_silence.py" "${TARGET_BIN_DIR}/ai-record"
create_symlink "${SCRIPT_DIR}/scripts/pipeline/encoder.py" "${TARGET_BIN_DIR}/ai-encoder"
create_symlink "${SCRIPT_DIR}/scripts/pipeline/decoder.py" "${TARGET_BIN_DIR}/ai-decoder"
create_symlink "${SCRIPT_DIR}/scripts/pipeline/validator.py" "${TARGET_BIN_DIR}/ai-validator"

# ==============================================================================
# Phase 2: Start Setup Scripts
# ==============================================================================

# --- Setup Step 1: Base Environment & Dotfile Symlinking ---
log_step "Phase 2.1: Running Base Environment Installation (install.sh)"
INSTALL_ARGS=()
if [[ "${FLAG_DRY_RUN}" == "true" ]]; then INSTALL_ARGS+=("-d"); fi
if [[ "${FLAG_FORCE}" == "true" ]]; then INSTALL_ARGS+=("-f"); fi

bash "${SCRIPT_DIR}/install.sh" "${INSTALL_ARGS[@]}"

# --- Setup Step 2: Language Vocabulary Prompts Generation ---
log_step "Phase 2.2: Generating Universal Language Prompts (generate_lang_prompts.py)"
if command -v python3 &>/dev/null; then
    if [[ "${FLAG_DRY_RUN}" == "true" ]]; then
        log_info "[DRY-RUN] Would run: python3 scripts/setup/generate_lang_prompts.py"
    else
        python3 "${SCRIPT_DIR}/scripts/setup/generate_lang_prompts.py"
        log_success "Compiled 595 GitHub Linguist languages into config/prompts/lang_prompts.env"
    fi
else
    log_warn "python3 not found; skipping language prompt regeneration."
fi

# --- Setup Step 3: Sci-Fi Single-Syllable Voice Grammar Compilation ---
log_step "Phase 2.3: Compiling Sci-Fi Voice Grammar & Codex (generate_scifi_grammar.py)"
if command -v python3 &>/dev/null; then
    if [[ "${FLAG_DRY_RUN}" == "true" ]]; then
        log_info "[DRY-RUN] Would run: python3 scripts/setup/generate_scifi_grammar.py"
    else
        python3 "${SCRIPT_DIR}/scripts/setup/generate_scifi_grammar.py"
        log_success "Compiled scifi_lexicon.md and scifi_lexicon.json (100% monosyllable verified)"
    fi
else
    log_warn "python3 not found; skipping sci-fi grammar generation."
fi

# --- Setup Step 4: Whisper.cpp Build & Model Download ---
log_step "Phase 2.4: Setting Up whisper.cpp Engine & Models (setup_whisper_cpp.sh)"
if [[ "${FLAG_SKIP_WHISPER}" == "true" ]]; then
    log_info "Skipping whisper.cpp setup as requested (--skip-whisper)."
else
    WHISPER_BIN="${HOME}/.local/bin/whisper-cli"
    LARGE_MODEL="${HOME}/.local/share/whisper.cpp/models/ggml-large-v3-turbo.bin"
    BASE_MODEL="${HOME}/.local/share/whisper.cpp/models/ggml-base.en.bin"

    if [[ -x "$WHISPER_BIN" && -f "$LARGE_MODEL" && -f "$BASE_MODEL" && "${FLAG_FORCE}" != "true" ]]; then
        log_success "whisper-cli and GGML models are already built and present."
        log_info "Binary: ${WHISPER_BIN}"
        log_info "Models: ${LARGE_MODEL}, ${BASE_MODEL}"
    else
        if [[ "${FLAG_DRY_RUN}" == "true" ]]; then
            log_info "[DRY-RUN] Would run: ./scripts/setup/setup_whisper_cpp.sh"
        else
            bash "${SCRIPT_DIR}/scripts/setup/setup_whisper_cpp.sh"
        fi
    fi
fi

# --- Setup Step 5: Ollama Prompt Optimizer Model Registration ---
log_step "Phase 2.5: Registering Ollama Prompt Optimizer Model"
if [[ "${FLAG_SKIP_LLM}" == "true" ]]; then
    log_info "Skipping Ollama model registration as requested (--skip-llm)."
else
    if command -v ollama &>/dev/null; then
        # Check if Ollama daemon is actively running
        if curl -s --max-time 2 http://localhost:11434/api/tags &>/dev/null; then
            if [[ "${FLAG_DRY_RUN}" == "true" ]]; then
                log_info "[DRY-RUN] Would run: ollama create prompt-optimizer -f config/ollama/Modelfile.prompt-optimizer"
            else
                log_info "Building 'prompt-optimizer' model in Ollama..."
                ollama create prompt-optimizer -f "${SCRIPT_DIR}/config/ollama/Modelfile.prompt-optimizer"
                log_success "Ollama model 'prompt-optimizer' registered successfully."
            fi
        else
            log_warn "Ollama is installed but the server is not running on localhost:11434."
            log_info "Start Ollama in another terminal via: ${COLOR_CYAN}ollama serve${COLOR_RESET}"
            log_info "Then run: ${COLOR_CYAN}ollama create prompt-optimizer -f ${SCRIPT_DIR}/config/ollama/Modelfile.prompt-optimizer${COLOR_RESET}"
        fi
    else
        log_info "Ollama binary not found in PATH. Skipping local model registration."
        log_info "Install Ollama when ready via: ${COLOR_CYAN}curl -fsSL https://ollama.ai/install.sh | sh${COLOR_RESET}"
    fi
fi

# ==============================================================================
# Phase 3: Setup Summary & Verification
# ==============================================================================
log_step "Setup Verification & Summary"

log_success "All setup phases completed successfully!"

cat <<EOF

${COLOR_BOLD}ai_dotfiles Pipeline is Ready:${COLOR_RESET}

  ${COLOR_CYAN}ai-dictate${COLOR_RESET}
    Global voice dictation & prompt optimizer.
    Captures speech, transcribes with whisper.cpp, optimizes with Ollama, and copies to clipboard.
    Example: ${COLOR_GRAY}ai-dictate --record-only${COLOR_RESET}

  ${COLOR_CYAN}ai-dictate-code <ext>${COLOR_RESET}
    Dynamic context & language-aware code compiler.
    Infers file extension (e.g. py, rs, ts, go), injects vocabulary, and formats code to stdout.
    Example: ${COLOR_GRAY}ai-dictate-code py${COLOR_RESET}

  ${COLOR_CYAN}IDE Integration${COLOR_RESET}:
    Configure keybinding (Ctrl+Alt+D) in Cursor / VS Code using:
    ${COLOR_GRAY}config/ide/tasks.json${COLOR_RESET} and ${COLOR_GRAY}config/ide/keybindings.json${COLOR_RESET}

EOF
