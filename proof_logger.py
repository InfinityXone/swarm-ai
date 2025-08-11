import json
import time
from datetime import datetime
import os

PROOF_LOG_FILE = "proof_log.json"

def load_proof_log():
    """Load existing proof log or initialize a new list."""
    if os.path.exists(PROOF_LOG_FILE):
        try:
            with open(PROOF_LOG_FILE, "r") as f:
                return json.load(f)
        except json.JSONDecodeError:
            return []
    else:
        return []

def save_proof_log(logs):
    """Save proof log to file with timestamp."""
    with open(PROOF_LOG_FILE, "w") as f:
        json.dump(logs, f, indent=4)

def log_proof(event: str, agent: str = "AgentZero", status: str = "success", metadata: dict = None):
    """Log proof entry with timestamp, agent name, and status."""
    logs = load_proof_log()
    
    entry = {
        "timestamp": datetime.utcnow().isoformat(),
        "agent": agent,
        "event": event,
        "status": status,
        "metadata": metadata or {}
    }

    logs.append(entry)
    save_proof_log(logs)
    print(f"[📜] Proof logged: {entry['event']} by {entry['agent']}")

# Example use:
if __name__ == "__main__":
    log_proof("Swarm launched", "ClaimBotX", "success", {"wallet": "BYRXex..."})
