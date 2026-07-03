#!/bin/bash
# Quick Claude Code installer - simplified version

set -e

echo "=== Claude Code CLI Quick Installer ==="
echo ""

# Step 1: Install Node.js if needed
echo "[1/3] Checking Node.js..."
if ! command -v node &> /dev/null; then
    echo "Installing Node.js and npm..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y nodejs npm
    elif command -v yum &> /dev/null; then
        sudo yum install -y nodejs npm
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y nodejs npm
    else
        echo "ERROR: Could not install Node.js. Please install manually."
        exit 1
    fi
else
    echo "✓ Node.js found: $(node --version)"
fi

# Step 2: Verify npm
echo ""
echo "[2/3] Checking npm..."
if ! command -v npm &> /dev/null; then
    echo "ERROR: npm not found"
    exit 1
fi
echo "✓ npm found: $(npm --version)"

# Step 3: Install Claude Code
echo ""
echo "[3/3] Installing Claude Code CLI..."
sudo npm install -g @anthropic-ai/claude-code

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Next steps:"
echo "1. Reload your shell: source ~/.bashrc"
echo "2. Verify: claude --version"
echo "3. Get help: claude --help"
