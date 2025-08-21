#!/usr/bin/env python3
import os, datetime

logdir = os.path.expanduser("~/logs")
os.makedirs(logdir, exist_ok=True)
logfile = os.path.join(logdir, "echo.log")

with open(logfile, "a") as f:
    f.write(f"[{datetime.datetime.utcnow()}] Echo heartbeat\n")
    for key in ["SUPABASE_URL", "SUPABASE_SERVICE_ROLE_KEY"]:
        val = os.getenv(key, "NOT SET")
        f.write(f"{key}={val}\n")
print("✅ Echo logger complete")
