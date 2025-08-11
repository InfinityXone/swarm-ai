#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME"
UNIT=/etc/systemd/system/infinity-gateway.service
if [[ ! -f "$ROOT/etherverse_orchestration_kit/gateway/gateway.py" ]]; then
  echo "Gateway not found in $ROOT/etherverse_orchestration_kit/gateway/gateway.py"
  exit 1
fi
sudo tee "$UNIT" >/dev/null <<'UNIT'
[Unit]
Description=Infinity Gateway
After=network-online.target
Wants=network-online.target

[Service]
EnvironmentFile=/home/%i/etherverse_orchestration_kit/.env.out
WorkingDirectory=/home/%i/etherverse_orchestration_kit
ExecStart=/usr/bin/python3 /home/%i/etherverse_orchestration_kit/gateway/gateway.py
Restart=always
RestartSec=2
User=%i

[Install]
WantedBy=multi-user.target
UNIT
sudo systemctl daemon-reload
sudo systemctl enable --now infinity-gateway@$USER.service
echo "✅ Gateway installed and started as infinity-gateway@$USER"
