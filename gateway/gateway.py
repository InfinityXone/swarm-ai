#!/usr/bin/env python3
import os, time, hmac, subprocess
from typing import Optional
from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel
import jwt, uvicorn

BROKER_SECRET = os.environ.get("INFINITY_BROKER_SECRET","")
if not BROKER_SECRET:
    raise SystemExit("INFINITY_BROKER_SECRET not set")

ALLOWED_CMDS = {"git_clone","git_push","vercel_deploy","write_file","read_file","run_script"}

app = FastAPI()

def issue_token(ttl=600):
    payload = {"iat": int(time.time()), "exp": int(time.time())+ttl, "role":"fin-broker"}
    return jwt.encode(payload, BROKER_SECRET, algorithm="HS256")

def verify_bearer(token:str):
    try:
        jwt.decode(token, BROKER_SECRET, algorithms=["HS256"]); return True
    except Exception: return False

class Cmd(BaseModel):
    action: str
    args: dict = {}

@app.get("/token")
def get_token(x_handshake: Optional[str]=Header(default="")):
    if not hmac.compare_digest(x_handshake or "", "NEO-PULSE"):
        raise HTTPException(401, "bad handshake")
    return {"token": issue_token()}

@app.post("/exec")
def exec_cmd(cmd: Cmd, authorization: Optional[str]=Header(default="")):
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(401, "no token")
    token = authorization.split(" ",1)[1]
    if not verify_bearer(token):
        raise HTTPException(401, "bad token")
    if cmd.action not in ALLOWED_CMDS:
        raise HTTPException(403, "action not allowed")
    try:
        if cmd.action == "write_file":
            p = cmd.args["path"]; data = cmd.args["data"]
            os.makedirs(os.path.dirname(p), exist_ok=True)
            with open(p,"w",encoding="utf-8") as f: f.write(data)
            return {"ok": True}
        if cmd.action == "read_file":
            p = cmd.args["path"]
            with open(p,"r",encoding="utf-8") as f: return {"ok": True, "data": f.read()}
        if cmd.action == "git_clone":
            repo = cmd.args["repo"]; dest = cmd.args["dest"]
            out = subprocess.check_output(["git","clone",repo,dest], stderr=subprocess.STDOUT, text=True)
            return {"ok": True, "out": out}
        if cmd.action == "git_push":
            repo_dir = cmd.args["dir"]; branch = cmd.args.get("branch","main")
            out = subprocess.check_output(["bash","-lc", f"cd '{repo_dir}' && git add -A && git commit -m 'auto' || true && git push origin {branch}"], stderr=subprocess.STDOUT, text=True)
            return {"ok": True, "out": out}
        if cmd.action == "vercel_deploy":
            proj_dir = cmd.args["dir"]
            out = subprocess.check_output(["bash","-lc", f"cd '{proj_dir}' && npx vercel --token $VERCEL_TOKEN --yes --prod"], stderr=subprocess.STDOUT, text=True)
            return {"ok": True, "out": out}
        if cmd.action == "run_script":
            sh = cmd.args["script"]
            out = subprocess.check_output(["bash","-lc", sh], stderr=subprocess.STDOUT, text=True)
            return {"ok": True, "out": out}
    except subprocess.CalledProcessError as e:
        raise HTTPException(500, e.output)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
