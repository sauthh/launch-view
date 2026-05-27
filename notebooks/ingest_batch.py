import pandas as pd
from ingest import get_Data

app_list = pd.read_csv("data/raw/app_list.csv")

game_data = {}
game_keys = ["steam_appid", "name", "type", "is_free", "developers", "publishers", "price_overview", "genres", "categories", "release_date", "recommendations", "metacritic", "platforms"]

for appid in app_list["appid"]:
    curr_game = get_Data(appid)

    if curr_game is None:
        continue

    game_data[appid] = {key:curr_game.get(key) for key in game_keys}

# Saves to csv for less hassle
df = pd.DataFrame.from_dict(game_data, orient="index")
df.to_csv("data/raw/games_raw.csv", index=False)