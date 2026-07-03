# Claude Code CLI Installation for Oracle VM

This directory contains an automated installation script for **Claude Code CLI** on Linux-based Oracle VMs and other Linux systems.

## What is Claude Code?

Claude Code is Anthropic's official command-line interface for interacting with Claude, the AI assistant. It enables developers to use Claude from the terminal for code analysis, generation, and various development tasks.

## System Requirements

- **OS**: Linux (Ubuntu, Debian, CentOS, RHEL, Amazon Linux, or similar)
- **Node.js**: 18.0.0 or higher
- **npm**: 9.0.0 or higher
- **Internet**: Required for downloading dependencies
- **Permissions**: Sudo access recommended (for package manager operations)

## Quick Start

### Option 1: Automated Installation

```bash
# Download and run the installer
curl -fsSL https://raw.githubusercontent.com/shannonjlove/forel/claude/oracle-vm-install-script-8hczoa/install-claude-code.sh | bash

# Or, if you have the file locally:
./install-claude-code.sh
```

### Option 2: With Verbose Output (Debugging)

```bash
./install-claude-code.sh --verbose
```

## Usage

### Display Help
```bash
./install-claude-code.sh --help
```

### Uninstall Claude Code
```bash
./install-claude-code.sh --uninstall
```

### Custom Installation Directory
```bash
INSTALL_DIR=/opt/claude/bin ./install-claude-code.sh
```

### Custom Log File Location
```bash
LOG_FILE=/var/log/claude-install.log ./install-claude-code.sh
```

## What the Script Does

1. **OS Detection**: Identifies the Linux distribution
2. **Dependency Check**: Verifies Node.js and npm are installed
3. **Node.js Installation** (if needed): Uses the appropriate package manager or nvm
4. **npm Update** (if needed): Ensures npm meets minimum version
5. **Claude Code Installation**: Installs via npm
6. **Environment Setup**: Updates shell configuration (.bashrc, .zshrc)
7. **Verification**: Confirms successful installation

## Manual Installation (If Script Fails)

If the automated script encounters issues, you can install manually:

### 1. Install Node.js and npm

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y nodejs npm
```

**CentOS/RHEL 8+:**
```bash
sudo dnf install -y nodejs npm
```

**CentOS/RHEL 7:**
```bash
sudo yum install -y nodejs npm
```

**Amazon Linux:**
```bash
sudo yum install -y nodejs npm
```

### 2. Install Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

### 3. Verify Installation

```bash
claude --version
claude --help
```

## Troubleshooting

### "Node.js not found"
Install Node.js using your system's package manager (see Manual Installation above).

### "Permission denied" when running script
Make the script executable:
```bash
chmod +x install-claude-code.sh
```

### Installation fails with npm errors
Try clearing the npm cache:
```bash
npm cache clean --force
npm install -g @anthropic-ai/claude-code
```

### `claude` command not found after installation
Reload your shell configuration:
```bash
source ~/.bashrc    # For Bash
source ~/.zshrc     # For Zsh
```

Or start a new terminal session.

### Check installation logs
The script logs to `/tmp/claude-code-install.log`:
```bash
cat /tmp/claude-code-install.log
```

Or specify a custom log file:
```bash
LOG_FILE=/path/to/logfile ./install-claude-code.sh
```

## Post-Installation

### First Use
```bash
# View help and available commands
claude --help

# Check version
claude --version
```

### Configure Authentication
Follow the prompts to configure your Anthropic API credentials:
```bash
claude login
# or set the ANTHROPIC_API_KEY environment variable
export ANTHROPIC_API_KEY="your-api-key-here"
```

### Documentation
For comprehensive documentation and usage examples, visit:
- **Official Docs**: https://claude.ai/code
- **GitHub**: https://github.com/anthropics/claude-code

## Environment Variables

The installation script respects these environment variables:

| Variable | Default | Purpose |
|----------|---------|---------|
| `INSTALL_DIR` | `~/.local/bin` | Installation directory for Claude Code |
| `LOG_FILE` | `/tmp/claude-code-install.log` | Log file location |
| `VERBOSE` | `0` | Set to `1` for verbose output |

Example:
```bash
INSTALL_DIR=/usr/local/bin LOG_FILE=/var/log/install.log VERBOSE=1 ./install-claude-code.sh
```

## Uninstallation

To remove Claude Code:

```bash
./install-claude-code.sh --uninstall
```

Or manually:
```bash
npm uninstall -g @anthropic-ai/claude-code
```

## Platform-Specific Notes

### Oracle Linux
```bash
sudo yum install -y nodejs npm
./install-claude-code.sh
```

### Amazon Linux 2
```bash
sudo amazon-linux-extras install -y nodejs18
./install-claude-code.sh
```

### CentOS Stream
```bash
sudo dnf install -y nodejs npm
./install-claude-code.sh
```

## Security Considerations

- **API Key Storage**: Keep your `ANTHROPIC_API_KEY` secure; store it in a `.env` file or environment variable, never in version control
- **Script Verification**: Inspect the script before running it in production environments
- **Permissions**: The script uses `sudo` only for package manager operations; inspect the code to verify this
- **Log Files**: The installation log may contain sensitive information; review and secure accordingly

## Support

If you encounter issues:

1. Check the log file: `cat /tmp/claude-code-install.log`
2. Run with verbose output: `./install-claude-code.sh --verbose`
3. Review the troubleshooting section above
4. Visit https://claude.ai/code/help for additional support

## Version History

- **v1.0** (2025-07-03): Initial release
  - Support for Ubuntu, Debian, CentOS, RHEL, Amazon Linux
  - Automated Node.js detection and installation
  - Shell environment setup
  - Comprehensive error handling and logging

## License

This installation script is provided as-is for use with Claude Code. See the main repository's LICENSE file for details.

---

**Last Updated**: 2025-07-03  
**Maintained By**: Forel Project Contributors
