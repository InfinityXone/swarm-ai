# Infinity Genesis System Manifest

## Core Strategy
- **Infinity Agent One** = Master orchestrator (API AI, execution).
- **FinSynapse** = General strategist, financial reasoning.
- **Echo** = Truth keeper. Logs, mirrors, ensures env + state alignment.
- **Corelight** = Overwatch. Keeps Guardian + runners alive, prevents drift.
- **Guardian** = Security & API gateway (auth, watch endpoints).
- **Runner** = GitHub Actions + local executor bridge.

## Environment Strategy
- Single source: `~/genesis_repo/.env`
- Mirrors: GitHub Secrets + Vercel env vars
- Sync cadence: daily at 02:00 via `env_sync.sh`
- Supabase: validated nightly, must have `SUPABASE_URL` + `SUPABASE_SERVICE_ROLE_KEY`

## Daily Catchup Flow
1. Supabase schema init (`supabase_init.sh`)
2. Echo log + env drift check (`echo_logger.py`)
3. Env sync → GitHub + Vercel (`env_sync.sh`)
4. Corelight watchdog (`corelight_watchdog.sh`)
5. Swarm healthcheck (`healthcheck.sh`)
6. Payout validator (`payout_validator.py`)

