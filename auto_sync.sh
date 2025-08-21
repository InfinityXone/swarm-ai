#!/bin/bash
set -euo pipefail
cd ~/genesis_repo

echo "[AutoSync] $(date) - pulling latest Genesis..."
git pull origin master || true

if [ -f sync_and_launch.sh ]; then
  echo "[AutoSync] launching swarm..."
  bash sync_and_launch.sh
fi
