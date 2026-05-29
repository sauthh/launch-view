import requests
import pandas as pd
import os
from dotenv import load_dotenv

# API Key stored in .env to avoid exposing credentials in the repo
load_dotenv()
API_KEY = os.getenv("STEAM_API_KEY")

APP_LIST_PATH = "data/raw/app_list.csv"

def get_all_apps(appid):
    """
    Fetches and stores app ID and name from the Steam store API

    Args:
        appid (int): Steam app ID of the last game
    Returns:
        have_more_results (bool): whether more results exist
        last_appid (int): last returned app ID
    """

    # Using params dict instead of URL string to avoid repetition and improve readability
    params = {
        "key" : API_KEY,
        "include_dlc" : "false",
        "include_software" : "false",
        "include_videos" : "false",
        "include_hardware" : "false",
        "max_results" : 50000
    }

    steam_url = "https://api.steampowered.com/IStoreService/GetAppList/v1/"

    # Include last_appid only when paginating, omit for first request
    if appid:
        params["last_appid"] = appid
    steam_response = requests.get(steam_url, params=params)
    data = steam_response.json()

    print(f"Completed: {len(data["response"]["apps"])} apps were retrieved")

    # Saves to csv to avoid re-fetching later
    df = pd.DataFrame(data["response"]["apps"])
    df[["appid", "name"]].to_csv(APP_LIST_PATH, mode="a", index=False, header=(not os.path.exists(APP_LIST_PATH)))

    return (data["response"].get("have_more_results", False), data["response"].get("last_appid", False))