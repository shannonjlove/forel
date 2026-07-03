#!/bin/bash

###############################################################################
# Claude Code CLI Installation Script for Oracle VM
#
# This script installs Claude Code (Anthropic's official CLI) on Linux systems.
# Supports: Ubuntu, Debian, CentOS, RHEL, Amazon Linux, and other Linux distros.
#
# Usage: ./install-claude-code.sh [options]
# Options:
#   --verbose     Enable verbose output
#   --help        Show this help message
#   --uninstall   Uninstall Claude Code
###############################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VERBOSE=${VERBOSE:-0}
INSTALL_DIR="${INSTALL_DIR:-${HOME}/.local/bin}"
LOG_FILE="${LOG_FILE:-/tmp/claude-code-install.log}"
MIN_NODE_VERSION="18.0.0"
MIN_NPM_VERSION="9.0.0"

###############################################################################
# Utility Functions
###############################################################################

log() {
    echo -e "${BLUE}[INFO]${NC} $*" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" | tee -a "$LOG_FILE"
    return 1
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*" | tee -a "$LOG_FILE"
}

verbose() {
    if [[ $VERBOSE -eq 1 ]]; then
        echo -e "${BLUE}[DEBUG]${NC} $*" | tee -a "$LOG_FILE"
    else
        echo "$*" >> "$LOG_FILE"
    fi
}

###############################################################################
# Platform Detection
###############################################################################

detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS="$ID"
        OS_VERSION="$VERSION_ID"
    elif [[ -f /etc/lsb-release ]]; then
        . /etc/lsb-release
        OS=$(echo "$DISTRIB_ID" | tr '[:upper:]' '[:lower:]')
        OS_VERSION="$DISTRIB_RELEASE"
    elif [[ -f /etc/redhat-release ]]; then
        OS="rhel"
        OS_VERSION=$(grep -oE '[0-9]+' /etc/redhat-release | head -1)
    else
        error "Unable to detect OS. Please install manually."
        return 1
    fi

    verbose "Detected OS: $OS $OS_VERSION"
    log "Operating System: $OS $OS_VERSION"
}

###############################################################################
# Dependency Checks
###############################################################################

check_command() {
    if ! command -v "$1" &> /dev/null; then
        return 1
    fi
    return 0
}

get_version() {
    "$1" --version 2>/dev/null | head -1 || echo "unknown"
}

compare_versions() {
    # Compare semantic versions: returns 0 if first >= second
    local ver1=$1
    local ver2=$2

    if [[ "$ver1" == "$ver2" ]]; then
        return 0
    fi

    local IFS=.
    local i ver1arr=($ver1) ver2arr=($ver2)

    for ((i=0; i<${#ver1arr[@]}; i++)); do
        local v1=${ver1arr[i]:-0}
        local v2=${ver2arr[i]:-0}
        if ((10#$v1 > 10#$v2)); then
            return 0
        elif ((10#$v1 < 10#$v2)); then
            return 1
        fi
    done
    return 0
}

check_node_npm() {
    log "Checking Node.js and npm..."

    if ! check_command node; then
        warning "Node.js not found. Installing Node.js..."
        install_nodejs
    else
        local node_version=$(node --version | sed 's/^v//')
        if compare_versions "$node_version" "$MIN_NODE_VERSION"; then
            success "Node.js $node_version found"
        else
            error "Node.js version $node_version is below minimum required $MIN_NODE_VERSION"
            return 1
        fi
    fi

    if ! check_command npm; then
        error "npm not found. Please install Node.js with npm."
        return 1
    else
        local npm_version=$(npm --version)
        if compare_versions "$npm_version" "$MIN_NPM_VERSION"; then
            success "npm $npm_version found"
        else
            warning "npm version $npm_version is below recommended $MIN_NPM_VERSION. Upgrading..."
            npm install -g npm@latest || warning "Could not upgrade npm"
        fi
    fi
}

###############################################################################
# Node.js Installation
###############################################################################

install_nodejs() {
    log "Installing Node.js and npm..."

    case "$OS" in
        ubuntu|debian)
            verbose "Using apt package manager"
            sudo apt-get update || warning "apt-get update failed"
            sudo apt-get install -y nodejs npm || error "Failed to install Node.js via apt"
            ;;
        rhel|centos|fedora|amzn)
            verbose "Using yum/dnf package manager"
            if command -v dnf &> /dev/null; then
                sudo dnf install -y nodejs npm || error "Failed to install Node.js via dnf"
            else
                sudo yum install -y nodejs npm || error "Failed to install Node.js via yum"
            fi
            ;;
        *)
            warning "Unsupported package manager for $OS. Attempting with curl..."
            install_nodejs_nvm
            ;;
    esac
}

install_nodejs_nvm() {
    log "Installing Node.js using nvm (Node Version Manager)..."

    local nvm_dir="${HOME}/.nvm"

    if [[ -d "$nvm_dir" ]]; then
        verbose "nvm already installed"
        . "$nvm_dir/nvm.sh"
    else
        verbose "Downloading and installing nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash || \
            error "Failed to install nvm"
        . "$nvm_dir/nvm.sh"
    fi

    nvm install node || error "Failed to install Node.js via nvm"
}

###############################################################################
# Claude Code Installation
###############################################################################

install_claude_code() {
    log "Installing Claude Code CLI..."

    # Ensure install directory exists
    mkdir -p "$INSTALL_DIR"

    # Install via npm
    log "Installing via npm..."
    npm install -g @anthropic-ai/claude-code || {
        error "Failed to install Claude Code via npm"
        return 1
    }

    success "Claude Code CLI installed successfully"
}

###############################################################################
# Post-Installation Setup
###############################################################################

setup_shell_env() {
    log "Setting up shell environment..."

    # Add install directory to PATH if not already there
    if ! grep -q "$INSTALL_DIR" ~/.bashrc 2>/dev/null; then
        echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> ~/.bashrc
        verbose "Added $INSTALL_DIR to ~/.bashrc"
    fi

    if ! grep -q "$INSTALL_DIR" ~/.zshrc 2>/dev/null; then
        echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> ~/.zshrc
        verbose "Added $INSTALL_DIR to ~/.zshrc"
    fi
}

verify_installation() {
    log "Verifying installation..."

    # Refresh PATH
    export PATH="$INSTALL_DIR:$PATH"

    if command -v claude &> /dev/null; then
        local version=$(claude --version 2>/dev/null || echo "unknown")
        success "Claude Code CLI verified: $version"
        return 0
    else
        warning "Claude Code CLI not found in PATH"
        verbose "Checking npm global packages..."
        npm list -g @anthropic-ai/claude-code || warning "Could not verify installation"
        return 1
    fi
}

print_post_install() {
    cat << EOF

${GREEN}╔════════════════════════════════════════════════════════════╗${NC}
${GREEN}║${NC}   Claude Code CLI Installation Complete!                ${GREEN}║${NC}
${GREEN}╚════════════════════════════════════════════════════════════╝${NC}

${BLUE}Next Steps:${NC}

1. Reload your shell configuration:
   ${YELLOW}source ~/.bashrc${NC}   # for Bash
   ${YELLOW}source ~/.zshrc${NC}    # for Zsh

2. Verify the installation:
   ${YELLOW}claude --version${NC}

3. Get started:
   ${YELLOW}claude --help${NC}

${BLUE}Documentation:${NC}
   https://claude.ai/code

${BLUE}Log file:${NC}
   $LOG_FILE

EOF
}

###############################################################################
# Uninstall
###############################################################################

uninstall_claude_code() {
    log "Uninstalling Claude Code CLI..."

    npm uninstall -g @anthropic-ai/claude-code || \
        error "Failed to uninstall Claude Code"

    success "Claude Code CLI uninstalled"
}

###############################################################################
# Main
###############################################################################

show_help() {
    head -20 "$0" | tail -12
}

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --verbose)
                VERBOSE=1
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            --uninstall)
                uninstall_claude_code
                exit $?
                ;;
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    log "Starting Claude Code CLI installation..."
    log "Installation directory: $INSTALL_DIR"

    # System checks
    detect_os || exit 1
    check_node_npm || exit 1

    # Installation
    install_claude_code || exit 1
    setup_shell_env

    # Verification
    if verify_installation; then
        print_post_install
        success "Installation completed successfully!"
        exit 0
    else
        warning "Installation may have completed, but verification failed."
        warning "Please check the log file: $LOG_FILE"
        exit 1
    fi
}

# Trap errors
trap 'error "Installation failed. See log: $LOG_FILE"' ERR

# Run main function
main "$@"
