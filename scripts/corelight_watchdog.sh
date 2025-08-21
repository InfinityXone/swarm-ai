#!/bin/bash
set -euo pipefail
echo "[Corelight] Checking swarm + guardian..."
ps -ef | grep -E "bot_worker.py|guardian|runner" | grep -v grep || echo "[WARN] No swarm/guardian/runner found!"
echo "[Corelight] Done."
