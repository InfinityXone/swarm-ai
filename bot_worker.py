import os, time, schedule
from key_registry import get_key

def run_bot(i):
    key = get_key(i)
    print(f"[Bot {i}] Using key: {key[:6]}... hitting API")
    # TODO: replace with httpx call
    time.sleep(0.2)

for i in range(100):  # 100 bots
    schedule.every(10).seconds.do(run_bot, i)

while True:
    schedule.run_pending()
    time.sleep(1)
