import os
from dotenv import load_dotenv

load_dotenv()

GROQ_API_KEY = os.getenv("GROQ_API_KEY")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
WALLET = os.getenv("WALLET")
AGENT_NAME = os.getenv("AGENT_NAME")

