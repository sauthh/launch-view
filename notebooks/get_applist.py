import requests
import pandas as pd
import os
from dotenv import load_dotenv

# API Key stored in .env to avoid exposing credentials in the repo
load_dotenv()
api_key = os.getenv("STEAM_API_KEY")

def get_all_apps(appid):
    """
    Fetches and stores app ID and name from the Steam store API

    Args:
        appid (int): Steam app ID of the last game
    Returns:
        have_more_results(bool), last_appid(int): whether more results exist, last returned app ID
    """
    # Include last_appid only when paginating, omit for first request
    if appid:
        steam_url = f"https://api.steampowered.com/IStoreService/GetAppList/v1/?key={api_key}&have_description_language=english&include_dlc=false&include_software=false&include_videos=false&include_hardware=false&last_appid={appid}&max_results=50000"
    else:
        steam_url = f"https://api.steampowered.com/IStoreService/GetAppList/v1/?key={api_key}&have_description_language=english&include_dlc=false&include_software=false&include_videos=false&include_hardware=false&max_results=50000"
    steam_response = requests.get(steam_url)
    data = steam_response.json()

    print(f"Completed: {len(data["response"]["apps"])} apps were retrieved")

    # Saves to csv to avoid re-fetching later
    df = pd.DataFrame(data["response"]["apps"])
    if os.path.exists("data/raw/app_list.csv"):
        df[["appid", "name"]].to_csv("data/raw/app_list.csv", mode="a", index=False, header=False)
    else:
        df[["appid", "name"]].to_csv("data/raw/app_list.csv", mode="a", index=False)

    return (data["response"].get("have_more_results", False), data["response"].get("last_appid", False))