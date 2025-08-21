#!/bin/bash
set -euo pipefail

BASE_DIR="$HOME/genesis_repo"
cd "$BASE_DIR"

echo "=== [1] Ensure venv ==="
python3 -m venv .venv || true
source .venv/bin/activate
pip install --upgrade pip supabase-py httpx schedule python-dotenv

echo "=== [2] Create webhook_listener.py ==="
cat > "$BASE_DIR/webhook_listener.py" <<'EOF'
import os, asyncio, httpx
from supabase import create_client, Client

url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_KEY")
discord_webhook = os.getenv("DISCORD_WEBHOOK")

supabase: Client = create_client(url, key)

async def poll_deposits():
    print("[Webhook] Listening for new deposits...")
    last_id = None
    while True:
        try:
            query = supabase.table("deposits").select("*").order("id", desc=True).limit(1).execute()
            if query.data:
                latest = query.data[0]
                if last_id != latest["id"]:
                    last_id = latest["id"]
                    msg = f"💰 Deposit Alert: {latest}"
                    print(msg)
                    if discord_webhook:
                        async with httpx.AsyncClient() as client:
                            await client.post(discord_webhook, json={"content": msg})
        except Exception as e:
            print("Error:", e)
        await asyncio.sleep(15)

if __name__ == "__main__":
    asyncio.run(poll_deposits())
EOF

echo "=== [3] Create systemd service ==="
SERVICE_FILE="/etc/systemd/system/genesis-webhook.service"
sudo bash -c "cat > $SERVICE_FILE" <<'EOF'
[Unit]
Description=Genesis Supabase Webhook Listener
After=network.target

[Service]
User=infinity-x-one
WorkingDirectory=/home/infinity-x-one/genesis_repo
Environment="PATH=/home/infinity-x-one/genesis_repo/.venv/bin"
ExecStart=/home/infinity-x-one/genesis_repo/.venv/bin/python3 webhook_listener.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "=== [4] Enable + start service ==="
sudo systemctl daemon-reload
sudo systemctl enable genesis-webhook
sudo systemctl restart genesis-webhook

echo "=== [5] Status ==="
systemctl status genesis-webhook --no-pager
