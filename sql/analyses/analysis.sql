-- Business question: How many games per genre?
-- Finding: Indie is the most common genre tag on Steam, appearing in 14,390 games. Other games such as AAA titles are typically tagged under specific genre like 
-- Action or Adventure.
-- Excluded non-genre tags: content descriptors (Gore, Violent, Nudity, Sexual Content), software categories (Photo Editing, Design & Illustrations, Video Production
-- Animation & Modeling, Accounting, Software Training, Game Development, Utilities), status tags (Early Access), and monetization models (Free To Play) which are
-- captured separately via price_usd = 0 in the games table.

SELECT
  genre,
  COUNT(*) AS game_count
FROM
  games_genre
WHERE
  genre not in (
    'Early Access',
    'Gore',
    'Violent',
    'Nudity',
    'Sexual Content',
    'Photo Editing',
    'Video Production',
    'Animation & Modeling',
    'Accounting',
    'Design & Illustration',
    'Software Training',
    'Game Development',
    'Free To Play',
    'Utilities'
  )
GROUP BY
  1
ORDER BY
  2 DESC



-- Business question: What's the average price per genre?
-- Finding: Sports genre has games with the highest price on average due to game studios releasing sports games per year for almost every sport. Massively Multiplayer 
-- games often use free to play or subscription model, driving the base price down. The $4.01 average reflects games that are free or low cost at purchase but may 
-- monetize through other means.

SELECT
  genre,
  ROUND(AVG(price_usd)::numeric, 2) AS average_price_usd
FROM
  games_genre
  LEFT JOIN games ON games_genre.steam_appid = games.steam_appid
WHERE
  genre NOT IN (
    'Early Access',
    'Gore',
    'Violent',
    'Nudity',
    'Sexual Content',
    'Photo Editing',
    'Video Production',
    'Animation & Modeling',
    'Accounting',
    'Design & Illustration',
    'Software Training',
    'Game Development',
    'Free To Play',
    'Utilities'
  )
GROUP BY
  1
ORDER BY
  2 DESC


-- Finding: Sports, Racing, RPG, Simulation, Strategy, and Adventure were the highest price on average in the same order as before. When excluding free to play games
-- from the calculation, Massively Multiplayer moved up to $10.04 on average making Education the lowest on average, which is still the same price as before. This 
-- suggests Massively Multiplayer games use free to play as an acquisition strategy rather than a pricing constraint, because when games in this genre are paid, they
-- command similar prices to Adventure titles.

SELECT
  genre,
  ROUND(AVG(price_usd)::numeric, 2) AS average_price_usd
FROM
  games_genre
  LEFT JOIN games ON games_genre.steam_appid = games.steam_appid
WHERE
  genre NOT IN (
    'Early Access',
    'Gore',
    'Violent',
    'Nudity',
    'Sexual Content',
    'Photo Editing',
    'Video Production',
    'Animation & Modeling',
    'Accounting',
    'Design & Illustration',
    'Software Training',
    'Game Development',
    'Free To Play',
    'Utilities'
  )
  AND price_usd > 0
GROUP BY
  1
ORDER BY
  2 DESC



-- Business question: What's the distrubution of price tiers?
-- Finding: Almost every genre had majority of their games in the budget tier ($0.01 - $9.99) and Massively Multiplayer was the only genre to have most of its game in 
-- the free tier. Games priced in the AAA (60+) tier outnumbered both High ($40 - $49.99) and Ultra ($50 - $59.99) tiers in most genres, suggesting studios skip the 
-- higher pricing and jump straight to the AAA price point. Furthermore, for the Indie genre, budget tier accounts for 8,799 games while Mid-range ($10 - $19.99) tier 
-- accounts for 2,585 games, which is a 3:1 ratio. A similar pattern holds across most genres where across most genres, budget tier accounts for more games than mid to 
-- standard ($20 - $29.99) tier, suggesting that the budget price point is the dominant strategy regardless of genre.

WITH
  p_category AS (
    SELECT
      steam_appid,
      CASE
        WHEN price_usd = 0 THEN 'Free'
        WHEN price_usd < 9.99 THEN 'Budget'
        WHEN price_usd < 19.99 THEN 'Mid-range'
        WHEN price_usd < 29.99 THEN 'Standard'
        WHEN price_usd < 39.99 THEN 'Premium'
        WHEN price_usd < 49.99 THEN 'High'
        WHEN price_usd < 59.99 THEN 'Ultra'
        ELSE 'AAA'
      END AS price_category
    FROM
      games
  )

SELECT
  genre,
  price_category,
  Count(*) AS game_count
FROM
  games_genre
  left join p_category ON games_genre.steam_appid = p_category.steam_appid
WHERE
  genre NOT IN (
    'Early Access',
    'Gore',
    'Violent',
    'Nudity',
    'Sexual Content',
    'Photo Editing',
    'Video Production',
    'Animation & Modeling',
    'Accounting',
    'Design & Illustration',
    'Software Training',
    'Game Development',
    'Free To Play',
    'Utilities'
  )
GROUP BY
  1,
  2
ORDER BY
  1,
  CASE
    WHEN price_category = 'Free' THEN 1
    WHEN price_category = 'Budget' THEN 2
    WHEN price_category = 'Mid-range' THEN 3
    WHEN price_category = 'Standard' THEN 4
    WHEN price_category = 'Premium' THEN 5
    WHEN price_category = 'High' THEN 6
    WHEN price_category = 'Ultra' THEN 7
    ELSE 8
  END;



-- Business question: How many games released per year
-- Finding: Games releases show a consistent upward trend from 2020 onwards, with 2025 being the peak year. While the COVID-19 pandemic (2020-2022) coincided with this 
-- growth preiod, it is difficult to determine causality without additional data on pre-pandemic trends.

SELECT
  EXTRACT(
    YEAR
    FROM
      release_date
  ) AS release_date,
  COUNT(*) AS game_count
FROM
  games
WHERE
  release_date <= current_date
GROUP BY
  1
ORDER BY
  1



-- Business question: What's the average recommendations per game
-- Finding: Massively Multiplayer has the highest average recommendations, with Action being the next highest at roughly a third of the Massively Multiplayer average. 
-- Massively Multiplayer tends to have enormous player bases, so it skews the average dramatically as it tends to be lower on the pricing scale. Setting that as an 
-- outlier, Action has the second highest average recommendations, nearly double of RPG and Adventure. Sports has the highest average price but the lowest average 
-- recommendations, which suggests that high pricing does not correlate with community engagement in that genre, and may indicate a niche market with fewer but willing 
-- buyers.

SELECT
  genre,
  ROUND(AVG(recommendations)::numeric, 2) AS average_recommendations
FROM
  games_genre
  LEFT JOIN games ON games.steam_appid = games_genre.steam_appid
WHERE
  genre NOT IN (
    'Early Access',
    'Gore',
    'Violent',
    'Nudity',
    'Sexual Content',
    'Photo Editing',
    'Video Production',
    'Animation & Modeling',
    'Accounting',
    'Design & Illustration',
    'Software Training',
    'Game Development',
    'Free To Play',
    'Utilities',
    'Education'
  )
GROUP BY
  1
ORDER BY
  2 DESC