#!/usr/bin/env bash
set -euo pipefail
if ! command -v vercel >/dev/null; then
  npm i -g vercel
fi
while IFS='=' read -r k v; do
  [[ -z "$k" || "$k" == \#* ]] && continue
  # Skip non-app secrets as needed
  vercel env add "$k" <<< "$v"
done < .env.out
echo "✅ Attempted to add vars to Vercel (verify per project)"
