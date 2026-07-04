# Hardened MCP Filesystem Server Setup

This document covers installation and configuration of the scoped MCP filesystem server for system automation.

## Overview

The MCP (Model Context Protocol) filesystem server provides sandboxed read/write access to configured directories via a stdio interface. It includes:

- Path validation and canonicalization
- Read/write root enforcement
- File size limits
- Audit logging
- Optional delete/move controls

## Installation

### 1. Create MCP Server Directory

```bash
mkdir -p /srv/sjl/hardened-mcp-filesystem
cd /srv/sjl/hardened-mcp-filesystem
```

### 2. Initialize Node.js Project

```bash
npm init -y
npm install @modelcontextprotocol/sdk
```

### 3. Copy Server Files

Copy the following files to `/srv/sjl/hardened-mcp-filesystem/`:
- `hardened-mcp-filesystem-server.js`
- `hardened-mcp-config.json`

### 4. Set Permissions

```bash
chmod 755 hardened-mcp-filesystem-server.js
chown root:root hardened-mcp-filesystem-server.json
chmod 600 hardened-mcp-config.json
```

## Configuration

Edit `/srv/sjl/hardened-mcp-filesystem/hardened-mcp-config.json`:

```json
{
  "readRoots": [
    "/srv/sjl",
    "/home/sjl",
    "/etc/containers/systemd"
  ],
  "writeRoots": [
    "/srv/sjl",
    "/home/sjl",
    "/etc/containers/systemd"
  ],
  "auditLog": "/home/sjl/.local/state/hardened-mcp-filesystem/audit.log",
  "maxReadBytes": 1048576,
  "maxWriteBytes": 1048576,
  "allowDelete": false,
  "allowMove": true,
  "allowedExtensions": [
    ".txt", ".md", ".json", ".yaml", ".yml",
    ".container", ".network", ".volume", ".service",
    ".conf", ".env", ".py", ".js", ".ts", ".sh"
  ]
}
```

## Systemd Service

Create `/etc/systemd/system/hardened-mcp-filesystem.service`:

```ini
[Unit]
Description=Hardened MCP Filesystem Server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=mcp-svc
Group=mcp-svc
ExecStart=/usr/bin/node /srv/sjl/hardened-mcp-filesystem/hardened-mcp-filesystem-server.js
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal
Environment=HARDENED_MCP_CONFIG=/srv/sjl/hardened-mcp-filesystem/hardened-mcp-config.json

[Install]
WantedBy=multi-user.target
```

### Load and Start Service

```bash
sudo systemctl daemon-reload
sudo systemctl enable hardened-mcp-filesystem
sudo systemctl start hardened-mcp-filesystem
sudo systemctl status hardened-mcp-filesystem
```

### View Logs

```bash
sudo journalctl -u hardened-mcp-filesystem -f
```

## MCP Client Configuration

In your Claude client configuration (e.g., `~/.claude/mcp.json`), add:

```json
{
  "mcpServers": {
    "hardened-filesystem": {
      "command": "node",
      "args": ["/srv/sjl/hardened-mcp-filesystem/hardened-mcp-filesystem-server.js"],
      "env": {
        "HARDENED_MCP_CONFIG": "/srv/sjl/hardened-mcp-filesystem/hardened-mcp-config.json"
      }
    }
  }
}
```

## Audit Logging

All operations are logged to the configured audit log path. Example:

```bash
tail -f /home/sjl/.local/state/hardened-mcp-filesystem/audit.log
```

Log format (JSONL):
```json
{"timestamp":"2025-01-15T10:30:45Z","action":"read_file","target":"/srv/sjl/config/app.json","status":"success"}
{"timestamp":"2025-01-15T10:31:02Z","action":"write_file","target":"/srv/sjl/data/state.json","status":"success"}
```

## Security Best Practices

1. **Keep delete disabled** unless absolutely necessary
2. **Separate read/write roots** from sensitive system areas
3. **Use a dedicated service account** (don't run as root)
4. **Restrict writable extensions** to known-safe types
5. **Monitor audit logs** for suspicious patterns
6. **Rotate audit logs** to prevent unbounded growth
7. **Limit file sizes** to prevent DoS attacks

## Troubleshooting

### MCP Server Not Responding

```bash
# Check if process is running
ps aux | grep hardened-mcp-filesystem

# Check for errors in logs
sudo journalctl -u hardened-mcp-filesystem -n 50

# Test manually
node /srv/sjl/hardened-mcp-filesystem/hardened-mcp-filesystem-server.js
```

### Permission Denied Errors

Verify:
- Service account has read/write access to configured roots
- Configured roots are correct in the config file
- File ownership and permissions are correct

```bash
# Check service user
id mcp-svc

# Check directory permissions
ls -ld /srv/sjl /home/sjl /etc/containers/systemd
```

### Audit Log Not Created

```bash
# Create directory if missing
mkdir -p /home/sjl/.local/state/hardened-mcp-filesystem
chown mcp-svc:mcp-svc /home/sjl/.local/state/hardened-mcp-filesystem
chmod 750 /home/sjl/.local/state/hardened-mcp-filesystem
```

## Next Steps

1. Review the audit log format and monitoring strategy
2. Set up log rotation for audit logs (logrotate)
3. Consider creating a read-only variant for sensitive paths
4. Test with your MCP client to verify connectivity
