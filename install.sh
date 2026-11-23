#!/usr/bin/env bash
# ==============================================================================
# ai_dotfiles bootstrap & installation script
# ==============================================================================
# Automates dependency verification, environment initialization, and modular
# symlinking from repository configs to standard user directories (~/.config/).
# ==============================================================================

set -euo pipefail

# --- Color & Formatting Definitions ---
readonly COLOR_RESET=$'\033[0m'
readonly COLOR_BOLD=$'\033[1m'
readonly COLOR_GREEN=$'\033[32m'
readonly COLOR_YELLOW=$'\033[33m'
readonly COLOR_RED=$'\033[31m'
readonly COLOR_CYAN=$'\033[36m'
readonly COLOR_GRAY=$'\033[90m'

log_info()    { printf "${COLOR_CYAN}[INFO]${COLOR_RESET} %s\n" "$*"; }
log_success() { printf "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} %s\n" "$*"; }
log_warn()    { printf "${COLOR_YELLOW}[WARN]${COLOR_RESET} %s\n" "$*"; }
log_error()   { printf "${COLOR_RED}[ERROR]${COLOR_RESET} %s\n" "$*"; }
log_step()    { printf "\n${COLOR_BOLD}===> %s${COLOR_RESET}\n" "$*"; }

# --- Runtime Directory Resolution ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SOURCE_DIR="${SCRIPT_DIR}/config"
TARGET_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ai_dotfiles"
TARGET_BIN_DIR="${HOME}/.local/bin"

# Script Flags
FLAG_DRY_RUN=false
FLAG_FORCE=false

usage() {
    cat <<EOF
${COLOR_BOLD}ai_dotfiles Bootstrap Installer${COLOR_RESET}

Usage: $(basename "$0") [OPTIONS]

Options:
  -d, --dry-run     Display actions without modifying the filesystem.
  -f, --force       Overwrite existing files and symlinks without prompting.
  -h, --help        Show this help message.

Description:
  1. Verifies prerequisites (git, curl, whisper.cpp, ollama, audio tools).
  2. Ensures environment file (.env) is present.
  3. Symlinks configurations into ~/.config/ai_dotfiles/ and scripts into ~/.local/bin/.
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
# Step 1: Tool Dependency Check
# ==============================================================================
log_step "Checking System Dependencies"

check_command() {
    local cmd="$1"
    local required="$2"
    local hint="$3"

    if command -v "$cmd" &>/dev/null; then
        printf "  %-18s ${COLOR_GREEN}✓ Found${COLOR_RESET} (${COLOR_GRAY}%s${COLOR_RESET})\n" "$cmd" "$(command -v "$cmd")"
        return 0
    else
        if [[ "$required" == "true" ]]; then
            printf "  %-18s ${COLOR_RED}✗ Missing (Required)${COLOR_RESET}\n" "$cmd"
            log_warn "  Hint: $hint"
            return 1
        else
            printf "  %-18s ${COLOR_YELLOW}⚠ Missing (Optional)${COLOR_RESET}\n" "$cmd"
            log_info "  Hint: $hint"
            return 0
        fi
    fi
}

MISSING_REQUIRED=0

# Core utilities
check_command "git"  "true"  "Install via system package manager (e.g. apt install git, pacman -S git)" || MISSING_REQUIRED=$((MISSING_REQUIRED + 1))
check_command "curl" "true"  "Install via system package manager (e.g. apt install curl, pacman -S curl)" || MISSING_REQUIRED=$((MISSING_REQUIRED + 1))
check_command "jq"   "true"  "Install via system package manager (e.g. apt install jq, pacman -S jq)" || MISSING_REQUIRED=$((MISSING_REQUIRED + 1))

# Audio recording backend
check_command "sox"     "false" "Recommended for silence detection. (e.g. apt install sox libsox-fmt-all)"
check_command "ffmpeg"  "false" "Alternative audio backend. (e.g. apt install ffmpeg)"
check_command "arecord" "false" "Standard ALSA audio recording tool (usually in alsa-utils)"

# AI inference runtimes
check_command "whisper-cli" "false" "Compile whisper.cpp or run scripts/setup/setup_whisper_cpp.sh"
check_command "ollama"      "false" "Install via: curl -fsSL https://ollama.ai/install.sh | sh"

# GUI / Clipboard utilities
if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    check_command "wl-copy" "false" "Wayland clipboard utility (e.g. apt install wl-clipboard)"
    check_command "wtype"   "false" "Wayland keystroke synthesizer"
elif [[ -n "${DISPLAY:-}" ]]; then
    check_command "xclip"   "false" "X11 clipboard utility (e.g. apt install xclip)"
    check_command "xdotool" "false" "X11 keystroke synthesizer (e.g. apt install xdotool)"
fi

if [[ $MISSING_REQUIRED -gt 0 ]]; then
    log_error "Missing required core dependencies ($MISSING_REQUIRED). Please install them and re-run."
    exit 1
fi

# ==============================================================================
# Step 2: Environment File Verification
# ==============================================================================
log_step "Verifying Environment Configuration"

ENV_SOURCE="${SCRIPT_DIR}/.env.example"
ENV_TARGET="${SCRIPT_DIR}/.env"

if [[ ! -f "$ENV_TARGET" ]]; then
    log_warn ".env file does not exist."
    if [[ "${FLAG_DRY_RUN}" == "true" ]]; then
        log_info "[DRY-RUN] Would copy ${ENV_SOURCE} to ${ENV_TARGET}"
    else
        cp "$ENV_SOURCE" "$ENV_TARGET"
        log_success "Created .env from .env.example. Please review and customize your settings."
    fi
else
    log_success ".env file already exists."
fi

# ==============================================================================
# Step 3: Symlink Configurations & Pipeline Scripts
# ==============================================================================
log_step "Symlinking Modular Configurations"

create_symlink() {
    local src="$1"
    local dest="$2"

    if [[ "${FLAG_DRY_RUN}" == "true" ]]; then
        log_info "[DRY-RUN] Symlink: $dest -> $src"
        return 0
    fi

    # Ensure parent directory exists
    mkdir -p "$(dirname "$dest")"

    # Handle existing target
    if [[ -L "$dest" ]]; then
        local current_target
        current_target="$(readlink "$dest")"
        if [[ "$current_target" == "$src" ]]; then
            log_info "Unchanged: $dest already links to $src"
            return 0
        fi
        log_warn "Updating symlink: $dest"
        rm -f "$dest"
    elif [[ -e "$dest" ]]; then
        if [[ "${FLAG_FORCE}" == "true" ]]; then
            local backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
            log_warn "Target exists. Backing up to $backup"
            mv "$dest" "$backup"
        else
            log_error "File exists at $dest. Use --force to backup and overwrite."
            return 1
        fi
    fi

    ln -s "$src" "$dest"
    log_success "Linked: $dest -> $src"
}

# 1. Link modular config directory
create_symlink "${CONFIG_SOURCE_DIR}" "${TARGET_CONFIG_DIR}"

# 2. Link root .env to config directory for easy discovery by daemon/scripts
create_symlink "${ENV_TARGET}" "${TARGET_CONFIG_DIR}/.env"

# 3. Symlink pipeline runner scripts to ~/.local/bin
mkdir -p "${TARGET_BIN_DIR}"
chmod +x "${SCRIPT_DIR}/scripts/pipeline/transcribe_and_optimize.sh" || true
chmod +x "${SCRIPT_DIR}/scripts/dictate.sh" || true
create_symlink "${SCRIPT_DIR}/scripts/pipeline/transcribe_and_optimize.sh" "${TARGET_BIN_DIR}/ai-dictate"
create_symlink "${SCRIPT_DIR}/scripts/dictate.sh" "${TARGET_BIN_DIR}/ai-dictate-code"

# Verify ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$TARGET_BIN_DIR:"* ]]; then
    log_warn "$TARGET_BIN_DIR is not in your current PATH. Add it to your ~/.bashrc or ~/.zshrc:"
    printf "  ${COLOR_GRAY}export PATH=\"\$HOME/.local/bin:\$PATH\"${COLOR_RESET}\n"
fi

# ==============================================================================
# Step 4: Summary & Next Steps
# ==============================================================================
log_step "Installation Summary"

log_success "ai_dotfiles scaffolding and linking completed successfully!"
cat <<EOF

Quick Start:
  1. Inspect and adjust environment parameters:
     ${COLOR_CYAN}vim ${SCRIPT_DIR}/.env${COLOR_RESET}

  2. Download whisper models or build whisper.cpp:
     ${COLOR_CYAN}${SCRIPT_DIR}/scripts/setup/setup_whisper_cpp.sh${COLOR_RESET}

  3. Import the prompt optimizer into Ollama:
     ${COLOR_CYAN}ollama create prompt-optimizer -f ${SCRIPT_DIR}/config/ollama/Modelfile.prompt-optimizer${COLOR_RESET}

  4. Test the pipelines:
     ${COLOR_CYAN}ai-dictate --help${COLOR_RESET}         # Global voice dictation & prompt optimizer
     ${COLOR_CYAN}ai-dictate-code --help${COLOR_RESET}    # Dynamic context & language-aware code compiler

EOF
