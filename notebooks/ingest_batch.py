import pandas as pd
from ingest import get_Data
from get_applist import get_all_apps

# Pagination state - loop until Steam confirms no more results
have_more_results = True
last_appid = None
while have_more_results:
    have_more_results, last_appid = get_all_apps(last_appid)

# Application list generated above - contains all Steam app IDs
app_list = pd.read_csv("data/raw/app_list.csv")

# Holds data for all games, used to convert to dataframe later
game_data = {}

# Only retaining fields relevant to launch strategy analysis - drops description, images, legal text, etc
game_keys = ["steam_appid", "name", "type", "is_free", "developers", "publishers", "price_overview", "genres", "categories", "release_date", "recommendations", "metacritic", "platforms"]

for appid in app_list["appid"]:
    curr_game = get_Data(appid)

    # Some app IDs are invalid - skip them
    if curr_game is None:
        continue

    # Skip games with fewer than 50 reviews - insufficient data for meaningful analysis
    if curr_game.get("recommendations", {}).get("total", 0) < 50:
        continue

    # Game cannot be unreleased
    if curr_game.get("release_date", {}).get("coming_soon", True):
        continue

    # Dictionary comprehension to extract only the required fields
    game_data[appid] = {key:curr_game.get(key) for key in game_keys}

    if len(game_data) > 0 and len(game_data) % 50 == 0:
        print(f"Fetched {len(game_data)} so far...")

print(f"Completed: {len(game_data)} games fetched successfully")

# Persist raw data locally to avoid re-fetching from API
df = pd.DataFrame.from_dict(game_data, orient="index")
df.to_csv("data/raw/games_raw.csv", index=False)