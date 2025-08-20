# Etherverse 24/7 Orchestration Kit — v1 (2025-08-11T13:09:55)

This kit gives you:
- A **single canonical ENV schema** and generators (local/GitHub/Vercel/Doppler/Infisical).
- A **Gateway** and **Daemon** to let GPT operate *through your machine* safely.
- **Task Queue** (Supabase) + **Hub Deploy** (GitHub Actions) + **n8n** fan‑out.
- **Terraform stubs** to provision tokens/secrets and wire hubs.
- One‑liners to start services and push secrets everywhere.

> You control root secrets. The model receives only short‑lived broker tokens.

## Quick Start
1. Fill inputs (any of): `inputs/config.json`, `inputs/config.yaml`, `inputs/env.d/*.env`.
2. Generate envs: `make dev` (or `make prod`) → creates `.env.out`.
3. Start Gateway: `make run-gateway` (local) or `make install-gateway` (systemd), then start a tunnel.
4. Create Supabase tables: `make supabase-init`.
5. Launch n8n (optional): `make up-n8n`.
6. Sync secrets to providers: `make sync-github` and `make sync-vercel` (requires CLIs).
7. Commit `.github/workflows/hub-deploy.yml` to your repo and push.

## Tree
- env.schema.yaml — canonical keys
- genenv.py — builds .env.out, exports to Doppler/Infisical formats
- exporters/ — Doppler & Infisical importer JSON
- gateway/gateway.py — FastAPI broker
- daemon/daemon.py — Supabase task runner calling the gateway
- db/supabase_schema.sql — tables: tasks, agents, events
- .github/workflows/hub-deploy.yml — multi-cloud dispatch
- terraform/ — provider stubs (GitHub, Cloudflare, Vercel)
- docker-compose.yml — n8n (optional)
- scripts/ — helpers (GitHub App, Vercel hooks, Cloudflared service)

Read each file header for usage.
