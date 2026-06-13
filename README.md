# Launch View

## Business Question
What genre, price point, and launch month combination generates the highest community engagement (measured by player recommendations) for indie games on Steam?

## Project Overview
This project analyzes 20,500+ Steam games collected via the Steam Web API to identify the optimal genre, price point, and launch timing for an indie game release. Game attributes including community recommendations, genre tags, pricing, metacritic scores, release dates, and developer team size were examined to surface data driven launch strategy recommendations

## Stack
- **Languages & Tools**: Python, PostgreSQL, Power BI
- **Libraries**: pandas, requests, SQLAlchemy, tenacity, python-dotenv

## Data Sources
- **Source**: Steam API (store.steampowered.com and api.steampowered.com)
- **Scope**: ~170,000 apps collected, filtered to ~20,500 games
- **Date Range**: 1998 - June 2026

## Project Structure
```
├── LICENSE
├── README.md
├── dashboards
│   ├── dashboard.pbix
│   ├── dashboard.pdf
│   └── screenshots
│       ├── Critical_Reception.png
│       ├── Launch_Strategy.png
│       └── Steam_Market_Overview.png
├── data
│   ├── processed
│   └── raw
├── docs
│   └── steam_launch_strategy_memo.pdf
├── notebooks
│   ├── clean.ipynb
│   ├── get_applist.py
│   ├── ingest.py
│   ├── ingest_batch.py
│   └── load_db.py
├── requirements.txt
└── sql
    └── analyses
        └── analysis.sql
```

## How to Run
1. Clone the repo and run `pip install -r requirements.txt`
2. Copy `.env.example` to `.env` and fill in the Steam API key and Supabase connection string
3. Run `python notebooks/ingest_batch.py` to collect game data
4. Open and run `notebooks/clean.ipynb` in Jupyter to clean the dataset
5. Run `python notebooks/load_db.py` to load into PostgreSQL

## Key Findings
- Indie is the most common genre tag on Steam, followed by Casual, Action, then Adventure
- Budget ($0.01 - $9.99) is the most popular price tier followed by Free
- Sports and Racing genres have the highest pricing on average but the fewest recommendations
- Massively Multiplayer genre has the highest average recommendations while having the fewest games and being the cheapest on average but is dominated by fewer large titles
- Higher priced games correlate with both higher average metacritic scores and more community engagement
- August is the most popular month to release games, followed by November and December
- Genre has minimal impact on metacritic scores as all genres fall within a narrow 4-point range

## Dashboard
The interactive dashboard was built in Power BI and covers three pages. Download `dashboard.pbix` to explore interactively in Power BI Desktop, or view the static PDF version.

[Download Dashboard PDF](dashboards/dashboard.pdf) | [Download .pbix](dashboards/dashboard.pbix)

### Market Overview
![Market Overview](dashboards/screenshots/Steam_Market_Overview.png)

### Launch Strategy
![Launch Strategy](dashboards/screenshots/Launch_Strategy.png)

### Critical Reception
![Critical Reception](dashboards/screenshots/Critical_Reception.png)

## Memo
[Steam Launch Strategy Memo](docs/steam_launch_strategy_memo.pdf)

## Limitations

### Data Collection Limitations
- Steam API returns inconsistent responses as the same app ID can return data one run and None on the next, meaning some games may be missing or underrepresented
- Non-English genre tags (15 games) were excluded due to inconsistent localization in the Steam API
- Only ~20,500 games retained from 170,000+ apps as many were filtered due to missing price, genre, or release date data
- `recommendations` has 17,000+ null values, which means over 80% of games have no review data, heavily skewing engagement metrics toward more popular titles

### Metric Limitations
- Recommendations measure willingness to review, not actual playtime or retention as silent players who play hundreds of hours aren't captured
- Metacritic scores only exist for ~700 games out of 20,500, which is heavily biased toward larger studio titles that attract critic attention
- No revenue or sales data, thus recommendations are used as a proxy for commercial success but don't directly measure it
- No concurrent player data, so actual player retention over time can't be measured

### Analytical Limitations
- Correlation ≠ causation. Higher price correlating with more recommendations doesn't mean raising your price will get more reviews
- Dataset skewed toward recent years as 2021 - 2026 dominates, older games are underrepresented
- Genre tags are self-reported by developers on Steam, so they tend to be inconsistent and subjective
- Survivorship bias in metacritic data as the games that received critic reviews are disproportionately older or higher budget titles, so the metacritic analysis may not reflect the indie game landscape accurately