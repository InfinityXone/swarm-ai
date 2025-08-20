import os
import json
import random
import time
from supabase import create_client

# Supabase logging
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

MASTER_WALLET = os.getenv("MASTER_WALLET", "0x000...")

def create_wallet():
    return {
        "address": f"0x{random.getrandbits(160):040x}",
        "private_key": f"0x{random.getrandbits(256):064x}"
    }

def spawn_satellite(n=1):
    sats = []
    for i in range(n):
        w = create_wallet()
        sats.append(w)
        # log to Supabase
        supabase.table("satellites").insert({
            "wallet": w["address"],
            "status": "active",
            "forward_to": MASTER_WALLET,
            "timestamp": int(time.time())
        }).execute()
    return sats

if __name__ == "__main__":
    max_sats = int(os.getenv("MAX_SATS", 25))
    sats = spawn_satellite(max_sats)
    print(json.dumps(sats, indent=2))
