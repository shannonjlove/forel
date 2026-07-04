# VPS Deployment & Podlet Management

Modern Linux container orchestration and infrastructure-as-code for VPS deployments using Podman, Quadlet, and systemd.

## Project Structure

```
.
├── scripts/           # Deployment and management scripts
├── containers/        # Podlet (Quadlet) container definitions
├── systemd/          # Systemd unit files and overrides
├── config/           # Configuration files (env, secrets, etc.)
├── docs/             # Documentation
└── .github/          # GitHub Actions workflows
```

## Quick Start

1. **View available scripts:**
   ```bash
   ls -la scripts/
   ```

2. **Deploy a container:**
   ```bash
   scripts/deploy.sh <container-name>
   ```

3. **Check service status:**
   ```bash
   systemctl status <service-name>
   ```

## Key Scripts

- `scripts/refresh-all.sh` — Regenerate units, reload systemd, restart services
- `scripts/deploy.sh` — Deploy and manage individual containers
- `scripts/health-check.sh` — Monitor container and service health

## Quadlet Containers

Container definitions in `containers/` use `.container`, `.network`, and `.volume` files.

See [Quadlet Documentation](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html) for syntax.

## Configuration

- `config/.env` — Environment variables (not committed; use `.env.example`)
- `config/hardened-mcp-config.json` — MCP filesystem server config
- `systemd/` — Systemd drop-in overrides and custom units

## Logging

- Service logs: `journalctl -u <service-name>`
- MCP audit log: `~/.local/state/hardened-mcp-filesystem/audit.log`
- Refresh-all log: `/var/log/refresh-all.log`

## Security

- Use configuration management for secrets
- Keep audit logs for filesystem operations
- Run services under dedicated accounts where possible
- Use read/write scoping for file access

## Next Steps

1. Create `.env` from `.env.example`
2. Define containers in `containers/`
3. Run `refresh-all` to generate and load systemd units
4. Monitor with `journalctl` or health check scripts
