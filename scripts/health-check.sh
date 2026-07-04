#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=== Health Check: $(date -Iseconds) ==="
echo

# Check systemd
echo "--- Systemd Status ---"
if systemctl is-system-running >/dev/null 2>&1; then
  echo "✓ systemd is running"
else
  echo "✗ systemd not fully operational"
fi
echo

# Check Podman
echo "--- Podman Status ---"
if command -v podman >/dev/null 2>&1; then
  PODMAN_VERSION=$(podman --version)
  echo "✓ Podman installed: $PODMAN_VERSION"

  RUNNING=$(podman ps -q | wc -l)
  TOTAL=$(podman ps -a -q | wc -l)
  echo "  Running: $RUNNING / Total: $TOTAL"
else
  echo "✗ Podman not installed"
fi
echo

# Check Docker
echo "--- Docker Status ---"
if command -v docker >/dev/null 2>&1; then
  DOCKER_VERSION=$(docker --version)
  echo "✓ Docker installed: $DOCKER_VERSION"

  RUNNING=$(docker ps -q | wc -l)
  TOTAL=$(docker ps -a -q | wc -l)
  echo "  Running: $RUNNING / Total: $TOTAL"
else
  echo "ℹ Docker not installed (optional)"
fi
echo

# Check key services
echo "--- Key Services ---"
for svc in ssh systemd-journald; do
  if systemctl is-active --quiet "$svc"; then
    echo "✓ $svc is active"
  else
    echo "✗ $svc is NOT active"
  fi
done
echo

# Check MCP socket
echo "--- MCP Filesystem Server ---"
if [[ -S /run/mcp-filesystem.sock ]]; then
  echo "✓ MCP socket found at /run/mcp-filesystem.sock"
else
  echo "ℹ MCP socket not found (may not be running)"
fi
echo

# Check log files
echo "--- Log Files ---"
if [[ -f /var/log/refresh-all.log ]]; then
  LAST_RUN=$(tail -1 /var/log/refresh-all.log)
  echo "✓ refresh-all log exists"
  echo "  Last entry: $LAST_RUN"
else
  echo "ℹ refresh-all log not found"
fi
echo

# Disk usage
echo "--- Disk Usage ---"
df -h / | tail -1

echo
echo "=== Health Check Complete ==="
