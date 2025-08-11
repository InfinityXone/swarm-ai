SHELL := /bin/bash
ROOT := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: dev prod clean run-gateway install-gateway supabase-init up-n8n down-n8n sync-github sync-vercel

dev:
	@mkdir -p $(ROOT)/inputs/env.d
	@python3 $(ROOT)/genenv.py

prod:
	@ENV=prod python3 $(ROOT)/genenv.py

clean:
	@rm -f $(ROOT)/.env.out exporters/*.json

run-gateway:
	@echo "Starting gateway on :8000"
	@INFINITY_BROKER_SECRET=$$(grep INFINITY_BROKER_SECRET .env.out | cut -d= -f2) \
		python3 gateway/gateway.py

install-gateway:
	@bash scripts/install_gateway_service.sh

supabase-init:
	@bash scripts/supabase_init.sh

up-n8n:
	@docker compose up -d

down-n8n:
	@docker compose down

sync-github:
	@bash scripts/sync_github_secrets.sh

sync-vercel:
	@bash scripts/sync_vercel_env.sh
