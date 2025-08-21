#!/bin/bash
set -euo pipefail
BASE=~/genesis_repo
ENV_FILE=$BASE/.env

echo "[Echo] Syncing env..."

if [ ! -f "$ENV_FILE" ]; then
  echo "❌ No .env file found at $ENV_FILE"
  exit 1
fi

# Load env keys
export $(grep -v '^#' $ENV_FILE | xargs)

# Push to GitHub + Vercel (requires gh & vercel CLIs configured)
if command -v gh >/dev/null 2>&1; then
  echo "[GitHub] Syncing secrets..."
  while IFS='=' read -r key value; do
    gh secret set "$key" -b"$value" || true
  done < <(grep -v '^#' $ENV_FILE)
fi

if command -v vercel >/dev/null 2>&1; then
  echo "[Vercel] Syncing env..."
  while IFS='=' read -r key value; do
    vercel env add "$key" <<< "$value" || true
  done < <(grep -v '^#' $ENV_FILE)
fi

echo "[Echo] Env sync complete"
