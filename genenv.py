#!/usr/bin/env python3

import os, sys, json, re, pathlib, subprocess
from typing import Dict, Any

try:
    import yaml  # type: ignore
except Exception:
    print("Install pyyaml: pip install pyyaml", file=sys.stderr); sys.exit(1)

ROOT = pathlib.Path(__file__).resolve().parent
SCHEMA_FILE = ROOT / "env.schema.yaml"
INPUTS_DIR = ROOT / "inputs"
OUTPUT_FILE = ROOT / ".env.out"
EXPORT_DIR = ROOT / "exporters"
EXPORT_DIR.mkdir(exist_ok=True)

def load_schema() -> Dict[str, Any]:
    with open(SCHEMA_FILE, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f)
    return data["vars"]

def load_inputs() -> Dict[str, str]:
    merged: Dict[str,str] = {}
    jf = INPUTS_DIR / "config.json"
    if jf.exists():
        merged.update(json.loads(jf.read_text(encoding="utf-8")))
    yf = INPUTS_DIR / "config.yaml"
    if yf.exists():
        merged.update(yaml.safe_load(yf.read_text(encoding="utf-8")) or {})
    envd = INPUTS_DIR / "env.d"
    if envd.exists():
        for p in sorted(envd.glob("*.env")):
            for line in p.read_text(encoding="utf-8").splitlines():
                line=line.strip()
                if not line or line.startswith("#"): continue
                if "=" in line:
                    k,v = line.split("=",1)
                    merged[k.strip()] = v.strip()
    for k,v in os.environ.items():
        if k.isupper(): merged[k] = v
    return merged

def validate(schema: Dict[str,Any], envs: Dict[str,str]) -> None:
    problems = []
    url_re = re.compile(r"^https?://")
    for k, meta in schema.items():
        if meta.get("required") and not envs.get(k):
            problems.append(f"missing required: {k}")
        if k in envs:
            if meta.get("type") == "url" and envs[k] and not url_re.match(envs[k]):
                problems.append(f"bad url format: {k}")
            if meta.get("type") == "path" and envs[k] and not envs[k].startswith("/"):
                problems.append(f"bad path (absolute expected): {k}")
    if problems:
        print("\n".join(problems), file=sys.stderr); sys.exit(2)

def write_env(envs: Dict[str,str]) -> None:
    lines = [f"{k}={v}" for k,v in sorted(envs.items()) if v is not None]
    OUTPUT_FILE.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {OUTPUT_FILE} ({len(lines)} vars)")

def export_doppler(envs: Dict[str,str]) -> None:
    data = [{"name": k, "value": v, "type": "config"} for k,v in envs.items()]
    (EXPORT_DIR / "doppler_import.json").write_text(json.dumps(data, indent=2), encoding="utf-8")
    print("Wrote exporters/doppler_import.json")

def export_infisical(envs: Dict[str,str]) -> None:
    data = [{"key": k, "value": v, "type": "shared"} for k,v in envs.items()]
    (EXPORT_DIR / "infisical_import.json").write_text(json.dumps(data, indent=2), encoding="utf-8")
    print("Wrote exporters/infisical_import.json")

def main():
    schema = load_schema()
    envs = load_inputs()
    envs = {k:v for k,v in envs.items() if k in schema}
    validate(schema, envs)
    write_env(envs)
    export_doppler(envs)
    export_infisical(envs)

if __name__ == "__main__":
    main()
