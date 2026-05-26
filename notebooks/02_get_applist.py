import requests
import time
import pandas as pd
import os
from dotenv import load_dotenv

# API Key stored in .env to avoid exposing credentials in the repo
load_dotenv()
api_key = os.getenv("STEAM_API_KEY")

# Retrieves a max of 100 games at a time from Steam
steam_url = f"https://api.steampowered.com/IStoreService/GetAppList/v1/?key={api_key}&max_results=100"
steam_response = requests.get(steam_url)
data = steam_response.json()["response"]["apps"]
print(f"Retrieved {len(data)} games")

# Saves to csv so no refetching later
df = pd.DataFrame(data)
df.to_csv("data/raw/app_list.csv", index=False)