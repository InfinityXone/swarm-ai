#!/usr/bin/env bash
set -euo pipefail
if ! command -v psql >/dev/null; then
  echo "psql not found. Use Supabase SQL editor to run db/supabase_schema.sql"
  exit 0
fi
psql "$SUPABASE_URL" -f db/supabase_schema.sql
