#!/bin/bash
set -euo pipefail

BASE_DIR="$HOME/genesis_repo"
cd "$BASE_DIR"

echo "=== [1] Install GitHub CLI if missing ==="
if ! command -v gh &> /dev/null; then
  sudo apt-get update -y && sudo apt-get install -y gh
  gh auth login
fi

echo "=== [2] Download .env from GitHub Actions artifact ==="
rm -f .env
gh run download --repo InfinityXone/Genesis --name env-file --dir .

if [ ! -f ".env" ]; then
  echo "❌ Failed to download .env artifact"
  exit 1
fi
echo "✅ .env ready"
head -n 10 .env

echo "=== [3] Setup Python venv ==="
python3 -m venv .venv || true
source .venv/bin/activate
pip install --upgrade pip httpx schedule python-dotenv

echo "=== [4] Launch swarm bots ==="
mkdir -p logs
pkill -f "bot_worker.py" || true

BOT_COUNT=100
for i in $(seq 1 $BOT_COUNT); do
  nohup python3 bot_worker.py --id $i >> logs/bot_$i.log 2>&1 &
  sleep 2
done

echo "=== [5] Status ==="
ps -ef | grep bot_worker.py | grep -v grep | wc -l


