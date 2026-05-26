import requests
import time
import pandas
import os
from dotenv import load_dotenv

def get_games_list():
    """
    Fetches games from Steam 
    Args:

    Returns:
        : list of games with details
    """
    # Loads variables from .env into the environment and retrieves the API Key
    load_dotenv()
    api_key = os.getenv("STEAM_API_KEY")

    steam_url = f"https://api.steampowered.com/IStoreService/GetAppList/v1/?key={api_key}&max_results=10"
    steam_response = requests.get(steam_url)
    data = steam_response.json()
    
    print(data["response"]["apps"])

get_games_list()