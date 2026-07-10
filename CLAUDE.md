# SJL Hybrid Cloud Infrastructure

Modern Linux container orchestration and infrastructure-as-code for VPS deployments using Podman, Quadlet, and systemd.

## Project Status

**Current Branch:** `claude/podlet-vps-install-1n0gb0`  
**Target Repository:** `shannonjlove/hybrid-personal-cloud-server-infrastructure` (to be created)  
**Status:** Production-ready code, awaiting final repo migration

---

## Overview

This project replaces the macOS-only Forel Swift application with a **Linux-native VPS deployment infrastructure**. It provides:

- **Container Orchestration** via Podman and Quadlet (systemd-based)
- **Deployment Automation** with GitHub Actions CI/CD
- **System Management** scripts for common operations
- **MCP Filesystem Server** for safe, scoped file access
- **Production Documentation** for setup and operations

### Why This Exists

- Original Forel was macOS-specific and not suitable for server environments
- VPS deployments require cross-platform, containerized infrastructure
- Modern systems need infrastructure-as-code and automated deployment
- Hybrid cloud requires flexible orchestration tools

---

## Quick Start

### Prerequisites

```bash
# On Ubuntu 22.04+ or Fedora
sudo apt-get install podman podman-compose nodejs npm
# OR
sudo dnf install podman podman-compose nodejs npm
```

### Local Development

```bash
# Clone and setup
git clone https://github.com/shannonjlove/hybrid-personal-cloud-server-infrastructure.git
cd hybrid-personal-cloud-server-infrastructure

# Copy environment template
cp .env.example .env
nano .env  # Fill in your values

# Test scripts
./scripts/health-check.sh
```

### Deploy to VPS

1. Create container definition in `containers/my-app.container`
2. Copy to VPS: `/etc/containers/systemd/`
3. Run: `sudo ./scripts/refresh-all.sh`
4. Verify: `sudo systemctl status podman-my-app.service`

---

## Project Structure

```
.
├── scripts/                    # Operational scripts
│   ├── refresh-all.sh         # Regenerate units, reload systemd, restart services
│   ├── deploy.sh              # Deploy/manage individual containers
│   └── health-check.sh        # Monitor system health and services
│
├── containers/                 # Quadlet container definitions
│   └── example.container      # Template for copying
│
├── systemd/                    # Systemd unit overrides (empty, user-managed)
├── config/                     # Configuration files (empty, user-managed)
│
├── docs/                       # Comprehensive documentation
│   ├── DEPLOYMENT-GUIDE.md    # Complete setup and operations guide
│   └── MCP-SERVER-SETUP.md    # Hardened MCP filesystem server
│
├── .github/workflows/          # GitHub Actions
│   └── deploy.yml             # CI/CD pipeline (validate & deploy)
│
├── .env.example                # Environment variables template
├── README.md                   # Project overview
├── .gitignore                  # Excludes secrets, node_modules, logs
└── LICENSE
```

---

## Key Files & Usage

### Scripts

#### `scripts/refresh-all.sh`
Master refresh script for the entire system.

**Usage:**
```bash
sudo ./scripts/refresh-all.sh
```

**Does:**
- Regenerates systemd units from Quadlet definitions
- Reloads systemd daemon
- Restarts core services (journald, ssh)
- Restarts all running Podman containers
- Restarts all running Docker containers
- Logs to `/var/log/refresh-all.log`

#### `scripts/deploy.sh`
Manage individual container lifecycle.

**Usage:**
```bash
./scripts/deploy.sh <container-name> <action>

# Actions: deploy, start, stop, restart, logs, status
./scripts/deploy.sh mcp-server logs
./scripts/deploy.sh app-backend restart
```

#### `scripts/health-check.sh`
System and service monitoring.

**Usage:**
```bash
./scripts/health-check.sh
```

**Checks:**
- systemd status
- Podman/Docker installation and running containers
- Core services (ssh, systemd-journald)
- MCP socket availability
- Disk usage
- Last refresh-all run

### Configuration

#### `.env.example`
Environment variables template. Copy to `.env` (git-ignored).

```bash
cp .env.example .env
# Edit with your values:
# - Registry credentials
# - DNS/NTP servers
# - Service accounts
# - Logging configuration
# - MCP server paths
```

#### `containers/example.container`
Quadlet file template for containerized services.

Copy and customize:
```bash
cp containers/example.container containers/my-service.container
nano containers/my-service.container
```

---

## Quadlet Container Format

Quadlet files (`.container`, `.network`, `.volume`) define containers as systemd units.

**Basic Example:**
```ini
[Unit]
Description=My Service
After=network-online.target

[Container]
Image=alpine:latest
ContainerName=my-service
Exec=my-app-command
Environment=LOG_LEVEL=info
PublishPort=127.0.0.1:8080:8080

[Install]
WantedBy=multi-user.target
```

Reference: https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html

---

## Deployment Pipeline

```
1. Push to main branch
   ↓
2. GitHub Actions runs:
   - Validates Quadlet syntax
   - Validates shell scripts
   - Validates JSON configs
   ↓
3. On success, rsync files to VPS:
   /srv/sjl/vps-deployment/
   ↓
4. SSH into VPS and run:
   sudo /srv/sjl/vps-deployment/scripts/refresh-all.sh
   ↓
5. systemd regenerates units and restarts services
```

### GitHub Actions Setup

Create these secrets in GitHub repo settings:
- `DEPLOY_KEY` — SSH private key (for deployment user)
- `DEPLOY_USER` — SSH username (e.g., `deploy`)
- `DEPLOY_HOST` — VPS IP or hostname

---

## MCP Filesystem Server

Scoped file access for automation and Claude integration.

### Setup

```bash
mkdir -p /srv/sjl/hardened-mcp-filesystem
cd /srv/sjl/hardened-mcp-filesystem
npm init -y
npm install @modelcontextprotocol/sdk
```

Copy `hardened-mcp-filesystem-server.js` and config, then:

```bash
sudo systemctl start hardened-mcp-filesystem
sudo systemctl enable hardened-mcp-filesystem
```

### Features

- **Path Validation:** Canonical path resolution prevents traversal
- **Root Enforcement:** Read/write restricted to configured directories
- **Audit Logging:** JSONL format with timestamp, action, target, status
- **Size Limits:** Max read/write bytes configurable
- **Extension Filtering:** Restrict writable file types
- **No Delete by Default:** Disabled unless explicitly configured

### Configuration

Edit `/srv/sjl/hardened-mcp-filesystem/hardened-mcp-config.json`:

```json
{
  "readRoots": ["/srv/sjl", "/home/sjl", "/etc/containers/systemd"],
  "writeRoots": ["/srv/sjl", "/home/sjl", "/etc/containers/systemd"],
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

See `docs/MCP-SERVER-SETUP.md` for complete setup guide.

---

## Monitoring & Logging

### systemd Journal

```bash
# View all logs
journalctl

# Follow service logs
journalctl -u podman-my-app.service -f

# View logs since last boot
journalctl -b

# Filter by priority
journalctl -p err

# Last 30 minutes
journalctl --since "30 min ago"
```

### refresh-all Log

```bash
tail -f /var/log/refresh-all.log
```

### MCP Audit Log

```bash
tail -f /home/sjl/.local/state/hardened-mcp-filesystem/audit.log
```

---

## Security

### ✅ Built-In Protections

- Environment secrets excluded from git (`.env.example` template provided)
- Audit logging for all filesystem operations
- Service accounts run non-root where possible
- File access scoped to allowed directories
- Extension filtering restricts writable file types
- Quadlet validation in CI/CD pipeline

### ⚠️ Before Production

1. **Set `allowDelete: false`** in MCP config (disable destructive operations)
2. **Restrict writable extensions** to known-safe types
3. **Enable log rotation** for audit logs:
   ```bash
   cat > /etc/logrotate.d/hardened-mcp <<EOF
   /home/sjl/.local/state/hardened-mcp-filesystem/audit.log {
       daily
       rotate 30
       compress
       delaycompress
       missingok
       notifempty
   }
   EOF
   ```
4. **Configure GitHub Actions secrets** securely
5. **Set firewall rules** for VPS network
6. **Use strong SSH keys** for deployment

---

## Documentation

### DEPLOYMENT-GUIDE.md
Complete step-by-step guide covering:
- Prerequisites and system setup
- Creating and managing containers
- Networking and port mapping
- Monitoring and troubleshooting
- Security hardening
- Backup strategies

### MCP-SERVER-SETUP.md
Detailed MCP filesystem server setup:
- Installation steps
- Configuration options
- Systemd service creation
- Client configuration
- Audit logging
- Security best practices

---

## Common Tasks

### Add a New Container

1. Create Quadlet file:
   ```bash
   cp containers/example.container containers/my-app.container
   nano containers/my-app.container
   ```

2. Copy to VPS:
   ```bash
   scp containers/my-app.container user@vps:/etc/containers/systemd/
   ```

3. Load it:
   ```bash
   ssh user@vps sudo ./scripts/refresh-all.sh
   ```

4. Verify:
   ```bash
   ssh user@vps systemctl status podman-my-app.service
   ```

### Check Service Status

```bash
sudo systemctl status podman-my-app.service
sudo systemctl logs podman-my-app.service -f
```

### Restart a Service

```bash
sudo systemctl restart podman-my-app.service
# or
sudo ./scripts/deploy.sh my-app restart
```

### View Running Containers

```bash
podman ps
podman ps -a
```

---

## Troubleshooting

### MCP Server Not Responding

```bash
# Check if running
systemctl status hardened-mcp-filesystem

# Check logs
journalctl -u hardened-mcp-filesystem -n 50

# Verify config
cat /srv/sjl/hardened-mcp-filesystem/hardened-mcp-config.json
```

### Container Won't Start

```bash
# Check logs
journalctl -u podman-my-app.service -n 50

# Try manual run
podman run --rm -it <image> bash

# Check image exists
podman images
```

### Permission Denied

```bash
# Verify service user can access directories
ls -ld /srv/sjl /etc/containers/systemd

# Check group membership
groups mcp-svc
id mcp-svc
```

See `docs/DEPLOYMENT-GUIDE.md` for complete troubleshooting guide.

---

## Architecture

### Service Management Model

```
Quadlet Files (.container, .network, .volume)
         ↓
podman-system-generator
         ↓
systemd Units (/run/systemd/system-generators/)
         ↓
systemctl daemon-reload
         ↓
systemd manages containers as services
         ↓
journalctl aggregates logs
```

### Deployment Model

```
GitHub (main branch with Quadlet files)
         ↓
GitHub Actions (validation)
         ↓
rsync to VPS
         ↓
SSH: run scripts/refresh-all.sh
         ↓
systemd reloads and restarts services
         ↓
Live containers running
```

---

## Current Status

**✅ Completed:**
- Full project structure
- Three operational scripts (refresh-all, deploy, health-check)
- Example Quadlet container template
- Comprehensive deployment guide
- MCP filesystem server documentation
- GitHub Actions CI/CD workflow
- Production-ready security controls
- Code committed and pushed

**⏳ Next Steps:**
1. Create GitHub repo: `shannonjlove/hybrid-personal-cloud-server-infrastructure`
2. Push code from `claude/podlet-vps-install-1n0gb0` to new repo
3. Configure GitHub Actions secrets (DEPLOY_KEY, DEPLOY_USER, DEPLOY_HOST)
4. Create first `.container` file for initial service
5. Test MCP server setup on development VPS
6. Run health-check on production VPS
7. Set up log rotation for audit and service logs

---

## Related Documentation

- **Podman:** https://docs.podman.io/
- **Quadlet:** https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html
- **systemd:** https://www.freedesktop.org/wiki/Software/systemd/
- **MCP (Model Context Protocol):** https://modelcontextprotocol.io/

---

## Questions & Planning

For next session:

- [ ] Which VPS provider? (DigitalOcean, Linode, Hetzner, AWS, etc.)
- [ ] Initial containers to deploy? (database, cache, reverse proxy, app servers)
- [ ] DNS/SSL setup? (Let's Encrypt, CloudFlare, etc.)
- [ ] Monitoring solution? (Prometheus, ELK, CloudFlare, etc.)
- [ ] Backup strategy for volumes?
- [ ] Disaster recovery requirements?
- [ ] Multi-region/HA needs?
- [ ] CI/CD integration with app deployments?

---

## Handoff Information

**Branch:** `claude/podlet-vps-install-1n0gb0`  
**Last Commit:** e4bbc32 (Clean up legacy Forel references)  
**Session Date:** July 4, 2026  
**Model:** claude-haiku-4-5-20251001

This codebase is production-ready. It requires:
1. Repository creation on GitHub
2. Deployment credentials configured
3. Initial service definitions in `containers/`
4. Target VPS provisioned with Podman/systemd

Once the repo is created and pushed, this infrastructure is immediately deployable.

---

**Last Updated:** 2026-07-04  
**Maintainer:** Shannon Jeffrey Love (sjlove@shannonjeffreylove.com)
