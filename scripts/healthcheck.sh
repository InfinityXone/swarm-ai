#!/bin/bash
set -euo pipefail
cd ~/genesis_repo

RUNNING=$(ps -ef | grep bot_worker.py | grep -v grep | wc -l)
MAX_BOTS=120    # hard ceiling
TARGET_BOTS=100 # normal operation
KEY_FILE="$HOME/genesis_repo/logs/key_usage.log"

# Initialize key usage file if missing
if [ ! -f "$KEY_FILE" ]; then
  echo "0 0 0" > "$KEY_FILE"
fi

read K1 K2 K3 < "$KEY_FILE"

# Rotate keys daily at midnight (reset counters)
if [ "$(date +%H%M)" == "0000" ]; then
  echo "0 0 0" > "$KEY_FILE"
  K1=0; K2=0; K3=0
fi

LIMIT=45000

# Function: log to Supabase
supabase_log() {
  MSG=$1
  TIMESTAMP=$(date -Iseconds)
  curl -s -X POST "$SUPABASE_URL/rest/v1/swarm_logs" \
    -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
    -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"timestamp\":\"$TIMESTAMP\",\"event\":\"$MSG\",\"running_bots\":$RUNNING,\"keys_used\":[ $K1, $K2, $K3 ]}" >/dev/null
}

# Check key exhaustion
if [ "$K1" -ge "$LIMIT" ] && [ "$K2" -ge "$LIMIT" ] && [ "$K3" -ge "$LIMIT" ]; then
  echo "[Healthcheck] $(date) - All keys exhausted, pausing swarm."
  pkill -f bot_worker.py
  supabase_log "All keys exhausted — swarm paused"
  exit 0
fi

# Bot population management
if [ "$RUNNING" -gt "$MAX_BOTS" ]; then
  echo "[Healthcheck] $(date) - Too many bots ($RUNNING) — killing swarm..."
  pkill -f bot_worker.py
  bash sync_and_launch.sh
  supabase_log "Bot overload ($RUNNING) — swarm reset"
elif [ "$RUNNING" -lt "$TARGET_BOTS" ]; then
  echo "[Healthcheck] $(date) - Only $RUNNING bots — topping back to $TARGET_BOTS..."
  bash sync_and_launch.sh
  supabase_log "Bot shortfall ($RUNNING) — topped up to $TARGET_BOTS"
else
  echo "[Healthcheck] $(date) - $RUNNING bots alive ✅"
  supabase_log "Swarm healthy"
fi

