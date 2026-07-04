#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="/var/log/refresh-all.log"
TIMESTAMP="$(date -Iseconds)"

echo "==== refresh-all run at $TIMESTAMP ====" | tee -a "$LOG_FILE"

# 1. Regenerate Quadlet units and reload systemd
if command -v podman-system-generator >/dev/null 2>&1; then
  echo "[INFO] Running podman-system-generator..." | tee -a "$LOG_FILE"
  sudo podman-system-generator 2>&1 | tee -a "$LOG_FILE"
else
  echo "[WARN] podman-system-generator not found; skipping Quadlet generation." | tee -a "$LOG_FILE"
fi

echo "[INFO] Reloading systemd daemon..." | tee -a "$LOG_FILE"
sudo systemctl daemon-reload 2>&1 | tee -a "$LOG_FILE"

# 2. Restart key system services (safe ones)
for svc in systemd-journald ssh; do
  echo "[INFO] Restarting service: $svc" | tee -a "$LOG_FILE"
  sudo systemctl restart "$svc" 2>&1 | tee -a "$LOG_FILE" || \
    echo "[ERROR] Failed to restart $svc" | tee -a "$LOG_FILE"
done

# 3. Restart running Podman containers
if command -v podman >/dev/null 2>&1; then
  PODMAN_IDS="$(podman ps -q || true)"
  if [ -n "$PODMAN_IDS" ]; then
    echo "[INFO] Restarting Podman containers: $PODMAN_IDS" | tee -a "$LOG_FILE"
    echo "$PODMAN_IDS" | xargs -r podman restart 2>&1 | tee -a "$LOG_FILE"
  else
    echo "[INFO] No running Podman containers to restart." | tee -a "$LOG_FILE"
  fi
else
  echo "[WARN] podman not found; skipping Podman container restart." | tee -a "$LOG_FILE"
fi

# 4. Restart running Docker containers
if command -v docker >/dev/null 2>&1; then
  DOCKER_IDS="$(docker ps -q || true)"
  if [ -n "$DOCKER_IDS" ]; then
    echo "[INFO] Restarting Docker containers: $DOCKER_IDS" | tee -a "$LOG_FILE"
    echo "$DOCKER_IDS" | xargs -r docker restart 2>&1 | tee -a "$LOG_FILE"
  else
    echo "[INFO] No running Docker containers to restart." | tee -a "$LOG_FILE"
  fi
else
  echo "[WARN] docker not found; skipping Docker container restart." | tee -a "$LOG_FILE"
fi

echo "[INFO] refresh-all completed at $(date -Iseconds)" | tee -a "$LOG_FILE"
