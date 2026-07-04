# VPS Deployment Guide

Step-by-step guide for deploying containers and services on a Linux VPS.

## Prerequisites

- Linux VPS (Ubuntu 22.04+ or similar)
- Podman or Docker installed
- SSH access to the VPS
- Sudo privileges or root access

## Initial Setup

### 1. Clone Repository

```bash
git clone https://github.com/shannonjlove/forel.git /srv/sjl/vps-deployment
cd /srv/sjl/vps-deployment
```

### 2. Install System Dependencies

```bash
sudo apt-get update
sudo apt-get install -y podman podman-compose nodejs npm

# Or for Fedora/RHEL:
# sudo dnf install -y podman podman-compose nodejs npm
```

### 3. Create Service Accounts

```bash
# MCP server account
sudo useradd -r -s /bin/false mcp-svc

# Container runtime account (optional)
sudo useradd -r -s /bin/false podlet-svc
```

### 4. Initialize Environment

```bash
cp .env.example .env
# Edit .env with your values
nano .env
```

## Deploying Containers

### 1. Create Container Definition

Copy and modify a container file:

```bash
cp containers/example.container containers/my-app.container
nano containers/my-app.container
```

### 2. Enable Quadlet

For Podman to automatically generate systemd units from Quadlet files, ensure your containers are in the correct location:

```bash
# For system-wide containers:
sudo mkdir -p /etc/containers/systemd/
sudo cp containers/*.container /etc/containers/systemd/

# For user containers (less common):
mkdir -p ~/.config/containers/systemd/
cp containers/*.container ~/.config/containers/systemd/
```

### 3. Reload and Start

```bash
# Regenerate systemd units
sudo systemctl daemon-reload

# Verify the new units
sudo systemctl list-unit-files | grep podman

# Start a specific container service
sudo systemctl start podman-my-app.service

# Enable at boot (optional)
sudo systemctl enable podman-my-app.service
```

### 4. Monitor

```bash
# View logs
sudo journalctl -u podman-my-app.service -f

# Check status
sudo systemctl status podman-my-app.service

# Run health check
./scripts/health-check.sh
```

## Managing Services

### Refresh All Services

```bash
# Regenerate, reload, and restart all services
sudo ./scripts/refresh-all.sh

# Check the log
tail -f /var/log/refresh-all.log
```

### Deploy Individual Container

```bash
./scripts/deploy.sh my-app deploy
./scripts/deploy.sh my-app logs
./scripts/deploy.sh my-app status
```

### Common Commands

```bash
# List all containers
podman ps -a

# List systemd units
systemctl list-units --type=service | grep podman

# View container details
podman inspect <container-id>

# Execute command in container
podman exec <container-id> <command>

# Stop and remove container
podman stop <container-id>
podman rm <container-id>

# View resource usage
podman stats
```

## Setting Up MCP Server

See [MCP-SERVER-SETUP.md](./MCP-SERVER-SETUP.md) for detailed instructions.

Quick start:

```bash
mkdir -p /srv/sjl/hardened-mcp-filesystem
cd /srv/sjl/hardened-mcp-filesystem
npm init -y
npm install @modelcontextprotocol/sdk

# Copy server files and config, then:
sudo systemctl start hardened-mcp-filesystem
```

## Monitoring & Logging

### Systemd Journal

```bash
# View all logs
journalctl

# Follow logs for a service
journalctl -u podman-my-app.service -f

# View logs since last boot
journalctl -b

# View logs from last 30 minutes
journalctl --since "30 min ago"

# Filter by priority
journalctl -p err
```

### Log Rotation

Systemd journal logs automatically rotate. To configure:

```bash
sudo nano /etc/systemd/journald.conf

# Key settings:
# Storage=persistent              # Keep logs across reboots
# RuntimeMaxUse=4G               # Max size of runtime journal
# MaxRetentionSec=30day          # Keep logs for 30 days
```

### Health Monitoring

```bash
# Run health check
./scripts/health-check.sh

# Set up periodic health checks (cron)
(crontab -l 2>/dev/null; echo "*/5 * * * * /srv/sjl/vps-deployment/scripts/health-check.sh >> /var/log/health-check.log") | crontab -
```

## Networking

### Port Mapping

In Quadlet files:

```ini
[Container]
PublishPort=127.0.0.1:8080:8080      # localhost only
PublishPort=0.0.0.0:8080:8080        # all interfaces
```

### Networks

Create custom networks:

```bash
podman network create my-network
```

Use in containers:

```ini
[Container]
Network=my-network
```

## Troubleshooting

### Container Won't Start

```bash
# Check logs
journalctl -u podman-my-app.service -n 50

# Try running manually
podman run --rm -it <image> bash

# Check image exists
podman images
```

### Permission Denied

```bash
# Verify user can access Podman socket
groups $USER
sudo usermod -aG podman $USER
newgrp podman
```

### Out of Disk Space

```bash
# Check usage
df -h

# Clean up unused images/containers
podman system prune -a

# View disk usage
podman system df
```

## Security Hardening

1. **Keep images updated:** `podman pull <image>` regularly
2. **Use read-only filesystems:** Add `ReadOnly=true` in Quadlet
3. **Limit resources:** Add memory/CPU limits in Quadlet
4. **Run as non-root:** `User=app-user` in container
5. **Use secrets management:** Don't embed credentials in images
6. **Network policies:** Use firewall rules and network scoping
7. **Audit logging:** Monitor MCP server and service logs

## Backup Strategy

Backup important data:

```bash
# Backup volumes
podman volume ls
podman volume inspect <volume-name>

# Backup configuration
tar -czf config-backup.tar.gz /srv/sjl/config

# Backup systemd units
tar -czf systemd-backup.tar.gz /etc/containers/systemd/
```

## Further Reading

- [Podman Documentation](https://docs.podman.io/)
- [Quadlet Documentation](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
- [Systemd Documentation](https://www.freedesktop.org/wiki/Software/systemd/)
