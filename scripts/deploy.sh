#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONTAINERS_DIR="$PROJECT_ROOT/containers"

usage() {
  cat <<EOF
Usage: $(basename "$0") <container-name> [action]

Actions:
  deploy    Build and start the container (default)
  start     Start the container if stopped
  stop      Stop the running container
  restart   Restart the container
  logs      Show container logs
  status    Show container status

Examples:
  $(basename "$0") mcp-server deploy
  $(basename "$0") mcp-server logs
EOF
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

CONTAINER_NAME="$1"
ACTION="${2:-deploy}"

CONTAINER_FILE="$CONTAINERS_DIR/$CONTAINER_NAME.container"

if [[ ! -f "$CONTAINER_FILE" ]]; then
  echo "ERROR: Container file not found: $CONTAINER_FILE"
  exit 1
fi

case "$ACTION" in
  deploy)
    echo "[INFO] Deploying $CONTAINER_NAME..."
    podman build -f "$CONTAINER_FILE" -t "$CONTAINER_NAME:latest" .
    systemctl restart "podman-$CONTAINER_NAME.service" || systemctl start "podman-$CONTAINER_NAME.service"
    echo "[INFO] $CONTAINER_NAME deployed and started"
    ;;
  start)
    echo "[INFO] Starting $CONTAINER_NAME..."
    systemctl start "podman-$CONTAINER_NAME.service"
    ;;
  stop)
    echo "[INFO] Stopping $CONTAINER_NAME..."
    systemctl stop "podman-$CONTAINER_NAME.service"
    ;;
  restart)
    echo "[INFO] Restarting $CONTAINER_NAME..."
    systemctl restart "podman-$CONTAINER_NAME.service"
    ;;
  logs)
    echo "[INFO] Logs for $CONTAINER_NAME:"
    journalctl -u "podman-$CONTAINER_NAME.service" -f
    ;;
  status)
    echo "[INFO] Status of $CONTAINER_NAME:"
    systemctl status "podman-$CONTAINER_NAME.service"
    ;;
  *)
    echo "ERROR: Unknown action '$ACTION'"
    usage
    ;;
esac
