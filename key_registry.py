import os, itertools

KEYS = [
    os.getenv("ETHERSCAN_KEY_1"),
    os.getenv("ETHERSCAN_KEY_2"),
    os.getenv("ETHERSCAN_KEY_3"),
]

# Filter out None or empty strings
VALID_KEYS = [k for k in KEYS if k and k.strip()]

if not VALID_KEYS:
    raise RuntimeError("❌ No valid ETHERSCAN_KEY_* found in environment/.env")

cycle = itertools.cycle(VALID_KEYS)

def get_key(i: int) -> str:
    return next(cycle)
