import requests
import time

def get_Steam(appid):
    """
    Fetches game details from the Steam store API for a given app ID

    Args:
        appid (int): the steam app ID of the game
    Returns:
        (dict): game details if sucessfull, else none if invalid
    """
    steam_url = f"https://store.steampowered.com/api/appdetails?appids={appid}"
    steam_reponse = requests.get(steam_url)
    data = steam_reponse.json()

    # Steam API returns JSON as strings not int
    return data[str(appid)]["data"] if data[str(appid)]["success"] else None

# Pause between calls to stay within Steam's rate limit
time.sleep(1.5)