#!/bin/bash
cd ~/genesis_repo
echo "[Cleanup] $(date)"
# Rotate logs
find logs/ -type f -name "*.log" -mtime +7 -exec gzip {} \;
find logs/ -type f -name "*.log.gz" -mtime +30 -delete
# Kill zombie processes
pkill -f defunct || true
