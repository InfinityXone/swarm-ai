#!/bin/bash
set -euo pipefail

BASE_DIR="$HOME/genesis_repo"
mkdir -p "$BASE_DIR/logs"
cd "$BASE_DIR"

echo "=== [1] Activating venv ==="
if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi
source .venv/bin/activate

pip install --upgrade pip
pip install httpx schedule python-dotenv supabase

echo "=== [2] Writing .env inline ==="
cat > .env <<'EOF'
ETHERSCAN_KEY_1=your_key_1_here
ETHERSCAN_KEY_2=your_key_2_here
ETHERSCAN_KEY_3=your_key_3_here
SUPABASE_URL=https://your.supabase.url
SUPABASE_SERVICE_ROLE=your_service_role_key
EOF

echo "=== [3] Writing bot_worker.py ==="
cat > bot_worker.py <<'PYEOF'
import os, time, httpx, schedule, itertools
from dotenv import load_dotenv
load_dotenv()

keys = [os.getenv("ETHERSCAN_KEY_1"), os.getenv("ETHERSCAN_KEY_2"), os.getenv("ETHERSCAN_KEY_3")]
cycle = itertools.cycle([k for k in keys if k])

def run_bot(i:int):
    key = next(cycle)
    url = f"https://api.etherscan.io/api?module=account&action=balance&address=0x0000000000000000000000000000000000000000&apikey={key}"
    try:
        r = httpx.get(url, timeout=10)
        print(f"[Bot {i}] {r.status_code} {r.text[:120]}")
        with open(f"logs/bot_{i}.log","a") as f:
            f.write(r.text+"\n")
    except Exception as e:
        print(f"[Bot {i}] ERROR {e}")

for i in range(1,6):  # start with 5 bots (scale later)
    schedule.every(10).seconds.do(run_bot, i=i)

while True:
    schedule.run_pending()
    time.sleep(1)
PYEOF

echo "=== [4] Launching bots (detached) ==="
nohup python bot_worker.py >> logs/swarm.log 2>&1 &
echo "Swarm launched ✅ (check logs/swarm.log)"
