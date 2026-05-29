import pandas as pd
import os
from ingest import get_data
from get_applist import get_all_apps

# Allows for easier access and change to path if necessary
APP_LIST_PATH = "data/raw/app_list.csv"
GAMES_RAW_PATH = "data/raw/games_raw.csv"

# Only retaining fields relevant to launch strategy analysis - drops description, images, legal text, etc
GAME_KEYS = ["steam_appid", "name", "type", "is_free", "developers", "publishers", "price_overview", "genres", "categories", "release_date", 
             "recommendations", "metacritic", "platforms"]


def add_games(df_apps, file_exists):
    """
    Depending on if file exists, creates new file and adds info or appends info from the next appid

    Args:
        df_apps (DataFrame): dataframe of all apps
        file_exists (bool): whether csv file exists or not
    """
    if file_exists:
        # Find where to resume from by locating the last saved appid in the app list
        curr_games_raw = pd.read_csv(GAMES_RAW_PATH)
        last_game_added = curr_games_raw["steam_appid"].iloc[-1]
        last_game_row = (df_apps["appid"] == last_game_added).idxmax()
        start_idx = last_game_row
    else:
        start_idx = -1
    
    # Limit iterations to save in batches
    games_count = 0
    attempts = 1000
    for i in range(attempts):
        start_idx += 1
        curr_game = get_data(df_apps.iloc[start_idx, 0])

        # Some app IDs are invalid - skip them
        if curr_game is None:
            continue

        # Only include games
        if curr_game.get("type") != "game":
            continue

        # Skip games with fewer than 50 reviews - insufficient data for meaningful analysis
        if curr_game.get("recommendations", {}).get("total", 0) < 50:
            continue

        # Game cannot be unreleased
        if curr_game.get("release_date", {}).get("coming_soon", True):
            continue

        # Dictionary comprehension to extract only the required fields
        game_df = pd.DataFrame([{key:curr_game.get(key) for key in GAME_KEYS}])

        # Adds to file directly for safe measures and to save space
        game_df.to_csv(GAMES_RAW_PATH, mode="a", index=False, header=(games_count == 0 and not file_exists))

        games_count += 1

        if games_count % 50 == 0:
            print(f"Fetched {games_count} so far...")
    
    print(f"Completed: {games_count} games added from {attempts} attempts")


# Pagination state - loop until Steam confirms no more results
have_more_results = True
last_appid = None

# Re-fetching the list everytime is redundant
if not os.path.exists(APP_LIST_PATH):
    while have_more_results:
        have_more_results, last_appid = get_all_apps(last_appid)

# Application list generated above - contains all Steam app IDs
df_apps = pd.read_csv(APP_LIST_PATH)

# Persist raw data locally to allow re-fetching for other games
file_exists = os.path.exists(GAMES_RAW_PATH)

add_games(df_apps, file_exists)