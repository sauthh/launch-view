import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy import types
import pandas as pd
import ast

GAMES_CLEAN_PATH = "data/processed/games_clean.csv"

# Database url stored in .env to avoid exposing credentials in the repo
load_dotenv()
engine = create_engine(os.getenv("DATABASE_URL"))

# Load main games table with explicit column types to ensure correct PostgreSQL schema
df_games = pd.read_csv(GAMES_CLEAN_PATH, usecols=["steam_appid", "name", "developers", "publishers", "price_usd", "release_date", "recommendations", "metacritic"])

# Convert to datetime so SQLAlchemy maps it to DATE type in PostgreSQL
df_games["release_date"] = pd.to_datetime(df_games["release_date"])
df_games.to_sql("games", engine, if_exists="replace", index=False, dtype={"steam_appid": types.Integer(), 
                                                                          "name": types.Text(), 
                                                                          "developers": types.Text(), 
                                                                          "publishers": types.Text(), 
                                                                          "price_usd": types.Float(), 
                                                                          "release_date": types.Date(), 
                                                                          "recommendations": types.Integer(), 
                                                                          "metacritic": types.Integer()})

# One row per genre per game for relational querying in SQL
df_genre = pd.read_csv(GAMES_CLEAN_PATH, usecols=["steam_appid", "genres"])
df_genre["genres"] = df_genre["genres"].apply(lambda x: ast.literal_eval(x) if not pd.isna(x) else None)
df_genre = df_genre.explode("genres")
df_genre = df_genre.rename(columns={"genres": "genre"})
df_genre.to_sql("games_genre", engine, if_exists="replace", index=False, dtype={"steam_appid": types.Integer(),
                                                                                "genre": types.Text()})