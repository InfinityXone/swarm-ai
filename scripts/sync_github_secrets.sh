#!/usr/bin/env bash
set -euo pipefail
if ! command -v gh >/dev/null; then
  echo "Install GitHub CLI: https://cli.github.com/"; exit 1
fi
REPO="${GITHUB_REPO:-}"
if [[ -z "$REPO" ]]; then
  echo "Set GITHUB_REPO (e.g., owner/name)"; exit 1
fi
while IFS='=' read -r k v; do
  [[ -z "$k" || "$k" == \#* ]] && continue
  gh secret set "$k" -R "$REPO" -b"$v"
done < .env.out
echo "✅ Synced .env.out to GitHub secrets for $REPO"
