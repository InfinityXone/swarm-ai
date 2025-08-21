#!/usr/bin/env python3
import os
import json
from fastapi import FastAPI, Request
import uvicorn

# Simple local webhook listener
app = FastAPI()

@app.post("/deposit")
async def deposit_webhook(request: Request):
    payload = await request.json()
    print(f"💰 Deposit webhook received: {json.dumps(payload, indent=2)}")

    # Example: trigger alert
    # You could swap this with email, Telegram, or Discord notify
    with open("logs/deposits.log", "a") as f:
        f.write(json.dumps(payload) + "\n")

    return {"status": "ok"}

if __name__ == "__main__":
    port = int(os.getenv("WEBHOOK_PORT", "8080"))
    uvicorn.run(app, host="0.0.0.0", port=port)
