import requests
import time
from tenacity import retry, wait_fixed, stop_after_attempt

# Fixed retry is sufficient - stops after 5 attempts to avoid infinite loops
@retry(wait=wait_fixed(2), stop=stop_after_attempt(5))
def get_data(appid):
    """
    Fetches game details from the Steam store API for a given app ID

    Args:
        appid (int): steam app ID of the game
    Returns:
        data (dict): game details if sucessfull, else none if invalid
    """
    steam_url = f"https://store.steampowered.com/api/appdetails?appids={appid}"
    steam_response = requests.get(steam_url)
    response_data = steam_response.json()

    # Steam API returns JSON as strings not int
    if response_data and response_data.get(str(appid)) and response_data.get(str(appid)).get("success"):
        # Pause between calls to stay within Steam's rate limit
        time.sleep(0.5)
        return response_data[str(appid)]["data"] 

    return None