import os, itertools
from dotenv import load_dotenv

# Load .env file into environment
load_dotenv()

KEYS = [
    os.getenv("ETHERSCAN_KEY_1"),
    os.getenv("ETHERSCAN_KEY_2"),
    os.getenv("ETHERSCAN_KEY_3"),
]

# Keep only non-empty values
KEYS = [k for k in KEYS if k]

# Cycle through available keys forever
cycle = itertools.cycle(KEYS)

def get_key(i: int) -> str:
    return next(cycle)
