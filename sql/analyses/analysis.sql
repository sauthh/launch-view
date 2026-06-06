-- Business question: How many games per genre?
-- Finding: Indie is the most common genre tag on Steam, appearing in 14,471 games. Larger studio titles such as AAA games are typically tagged under specific genre like 
-- Action or Adventure, thus they do not have a dedicated tag.

SELECT
  genre,
  COUNT(*) AS game_count
FROM
  games_genre
GROUP BY
  1
ORDER BY
  2 DESC



-- Business question: How are games distributed across price tiers?
-- Finding: The majority of games are priced in the Free or Budget tier ($0.01 - $9.99), with games count dropping sharply at higher price points. Notably, the High 
-- ($40 - $49.99) tier has fewer games than both Premium ($30 - $39.99) and Ultra ($50 - $59.99), suggesting studios skip this tier and price directly at Ultra or AAA
-- ($60+). This mirrors the genre-level finding from the price distribution query.

WITH
  p_category AS (
    SELECT
      steam_appid,
      CASE
        WHEN price_usd = 0 THEN 'Free'
        WHEN price_usd <= 9.99 THEN 'Budget'
        WHEN price_usd <= 19.99 THEN 'Mid-range'
        WHEN price_usd <= 29.99 THEN 'Standard'
        WHEN price_usd <= 39.99 THEN 'Premium'
        WHEN price_usd <= 49.99 THEN 'High'
        WHEN price_usd <= 59.99 THEN 'Ultra'
        ELSE 'AAA'
      END AS price_category
    FROM
      games
  )

SELECT
  price_category,
  COUNT(*) AS game_count
FROM
  games
  LEFT JOIN p_category USING (steam_appid)
GROUP BY
  1
ORDER BY
  CASE
    WHEN price_category = 'Free' THEN 1
    WHEN price_category = 'Budget' THEN 2
    WHEN price_category = 'Mid-range' THEN 3
    WHEN price_category = 'Standard' THEN 4
    WHEN price_category = 'Premium' THEN 5
    WHEN price_category = 'High' THEN 6
    WHEN price_category = 'Ultra' THEN 7
    ELSE 8
  END



-- Business question: How many games released per year?
-- Finding: Games releases show a consistent upward trend from 2020 onwards, with 2025 being the peak year. While the COVID-19 pandemic (2020-2022) coincided with this 
-- growth period, it is difficult to determine causality without additional data on pre-pandemic trends.

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



-- Business question: What's the average price per genre?
-- Finding: Sports and Racing genre has games with the highest price on average while having the fewest games compared to other genres. They typically require expensive
-- licensed content such as real teams, athletes, and vehicles, driving up development and licensing costs which are passed on to consumers. Massively Multiplayer games 
-- often use free to play or subscription model, driving the base price down. The $3.99 average reflects games that are free or low cost at purchase but may monetize 
-- through other means.

SELECT
  genre,
  ROUND(AVG(price_usd)::NUMERIC, 2) AS average_price_usd
FROM
  games_genre
  LEFT JOIN games USING(steam_appid)
GROUP BY
  1
ORDER BY
  2 DESC



-- Business question: What's the average price per genre? (price_usd > 0)
-- Finding: Even after excluding free games, Sports, Racing, RPG, Simulation, Strategy, and Adventure were the highest price on average in the same order as before.
-- Massively Multiplayer moved up to $9.96 on average making Casual the lowest on average. This suggests Massively Multiplayer games use free to play as an acquisition 
-- strategy rather than a pricing constraint, because when games in this genre are paid, they command similar prices to Adventure or Action titles.

SELECT
  genre,
  ROUND(AVG(price_usd)::NUMERIC, 2) AS average_price_usd
FROM
  games_genre
  LEFT JOIN games USING(steam_appid)
WHERE
  price_usd > 0
GROUP BY
  1
ORDER BY
  2 DESC



-- Business question: What's the distribution of price tiers?
-- Finding: Almost every genre had majority of their games in the Budget tier ($0.01 - $9.99) and Massively Multiplayer was the only genre to have most of its games in 
-- the Free tier. Games priced in the AAA (60+) tier outnumbered both High ($40 - $49.99) and Ultra ($50 - $59.99) tiers in most genres, suggesting studios skip the 
-- higher pricing and jump straight to the AAA price point. Furthermore, for the Indie genre, budget tier accounts for 10,051 games while Mid-range ($10 - $19.99) tier 
-- accounts for 1,794 games, which is approximately a 5.6:1 ratio. A similar pattern holds across most genres where budget tier accounts for more games than Mid to 
-- Standard ($20 - $29.99) tier, suggesting that the budget price point is the dominant strategy regardless of genre.

WITH
  p_category AS (
    SELECT
      steam_appid,
      CASE
        WHEN price_usd = 0 THEN 'Free'
        WHEN price_usd <= 9.99 THEN 'Budget'
        WHEN price_usd <= 19.99 THEN 'Mid-range'
        WHEN price_usd <= 29.99 THEN 'Standard'
        WHEN price_usd <= 39.99 THEN 'Premium'
        WHEN price_usd <= 49.99 THEN 'High'
        WHEN price_usd <= 59.99 THEN 'Ultra'
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
  LEFT JOIN p_category USING (steam_appid)
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
  END



-- Business question: What month is the most popular time to release games?
-- Finding: March to May is the most popular month to release games, May being the most popular. This could potentially coincide with end of spring semester for 
-- students, or studios targeting pre-summer release window before big AAA summer titles.

SELECT
  TO_CHAR(release_date, 'Month') AS release_month,
  COUNT(*) AS game_count
FROM
  games
WHERE
  release_date <= current_date
GROUP BY
  1,
  EXTRACT(
    MONTH
    FROM
      release_date
  )
ORDER BY
  EXTRACT(
    MONTH
    FROM
      release_date
  )



-- Business question: Yearly game releases by price tier
-- Finding: Budget tier ($0.01 - $9.99) tier dominates every year, growing proportionally with total releases. AAA pricing ($60+) became consistent only from 2021 
-- onwards, suggesting higher pricing on Steam is a recent trend. The High tier ($40 - $49.99) remains consistently underrepresented across all years, reinforcing that 
-- studios tend to skip this price point in favor of Ultra ($50 - $59.99) or AAA pricing.

WITH
  p_category AS (
    SELECT
      steam_appid,
      CASE
        WHEN price_usd = 0 THEN 'Free'
        WHEN price_usd <= 9.99 THEN 'Budget'
        WHEN price_usd <= 19.99 THEN 'Mid-range'
        WHEN price_usd <= 29.99 THEN 'Standard'
        WHEN price_usd <= 39.99 THEN 'Premium'
        WHEN price_usd <= 49.99 THEN 'High'
        WHEN price_usd <= 59.99 THEN 'Ultra'
        ELSE 'AAA'
      END AS price_category
    FROM
      games
  )

SELECT
  EXTRACT(
    YEAR
    FROM
      release_date
  ) AS release_year,
  price_category,
  COUNT(*) AS game_count
FROM
  games
  LEFT JOIN p_category USING (steam_appid)
WHERE
  release_date <= current_date
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
  END



-- Business question: Monthly game releases by price tier
-- Finding: Budget tier releases peak in March - May and dip in June - July, suggesting a summer slowdown in indie releases. AAA releases are concentrated in Q1 and Q4, 
-- aligning with post-holiday and holiday shopping seasons respectively. For an indie studio on a budget price point, March - May offers the highest release volume but 
-- also the most competition.

WITH
  p_category AS (
    SELECT
      steam_appid,
      CASE
        WHEN price_usd = 0 THEN 'Free'
        WHEN price_usd <= 9.99 THEN 'Budget'
        WHEN price_usd <= 19.99 THEN 'Mid-range'
        WHEN price_usd <= 29.99 THEN 'Standard'
        WHEN price_usd <= 39.99 THEN 'Premium'
        WHEN price_usd <= 49.99 THEN 'High'
        WHEN price_usd <= 59.99 THEN 'Ultra'
        ELSE 'AAA'
      END AS price_category
    FROM
      games
  )

SELECT
  TO_CHAR(release_date, 'Month') AS release_month,
  price_category,
  COUNT(*) AS game_count
FROM
  games
  LEFT JOIN p_category USING (steam_appid)
WHERE
  release_date <= current_date
GROUP BY
  1,
  2,
  EXTRACT(
    MONTH
    FROM
      release_date
  )
ORDER BY
  EXTRACT(
    MONTH
    FROM
      release_date
  ),
  CASE
    WHEN price_category = 'Free' THEN 1
    WHEN price_category = 'Budget' THEN 2
    WHEN price_category = 'Mid-range' THEN 3
    WHEN price_category = 'Standard' THEN 4
    WHEN price_category = 'Premium' THEN 5
    WHEN price_category = 'High' THEN 6
    WHEN price_category = 'Ultra' THEN 7
    ELSE 8
  END



-- Business question: What's the average recommendations per game?
-- Finding: Massively Multiplayer has the highest average recommendations, with Action being the next highest at roughly a third of the Massively Multiplayer average. 
-- Massively Multiplayer tends to have enormous player bases, so it skews the average dramatically as it tends to be lower on the pricing scale. Setting that as an 
-- outlier, Action has the second highest average recommendations, nearly double of RPG and Adventure. Sports has the highest average price but the lowest average 
-- recommendations, which suggests that high pricing does not correlate with community engagement in that genre, and may indicate a niche market with fewer but willing 
-- buyers.

SELECT
  genre,
  ROUND(AVG(recommendations)::NUMERIC, 2) AS average_recommendations
FROM
  games_genre
  LEFT JOIN games USING (steam_appid)
GROUP BY
  1
ORDER BY
  2 DESC



-- Business question: Which genre + price tier combinations have the highest recommendations?
-- Finding: Most genres show increasing average recommendations at higher price tiers, suggesting that higher priced games attract more dedicated players who are more
-- likely to leave reviews. Some tiers show extreme averages driven by single dominant titles rather than the genre as a whole, which could be interpreted with caution. 
-- Action Free is the highest category at 131,015 average recommendations. Sports is the exception, showing no clear price-to-engagement pattern with recommendations 
-- scattered across all tiers. Early Access shows relatively flat recommendations across all paid tiers (4,664 to 5,445), which suggests it gets consistent engagement 
-- regardless of price, unlike other genres where price correlates with recommendations.

WITH
  p_category AS (
    SELECT
      steam_appid,
      CASE
        WHEN price_usd = 0 THEN 'Free'
        WHEN price_usd <= 9.99 THEN 'Budget'
        WHEN price_usd <= 19.99 THEN 'Mid-range'
        WHEN price_usd <= 29.99 THEN 'Standard'
        WHEN price_usd <= 39.99 THEN 'Premium'
        WHEN price_usd <= 49.99 THEN 'High'
        WHEN price_usd <= 59.99 THEN 'Ultra'
        ELSE 'AAA'
      END AS price_category
    FROM
      games
  )

SELECT
  genre,
  price_category,
  ROUND(AVG(recommendations)::NUMERIC, 2) AS average_recommendations
FROM
  games_genre
  LEFT JOIN games USING (steam_appid)
  LEFT JOIN p_category USING (steam_appid)
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
  END



-- Business question: Which release years/months perform best?
-- Finding: August has the highest average recommendations at 23,280, which may reflect end-of-summer gaming activity. November and December perform strongly at 11,035 
-- and 9,846 respectively, coinciding with holiday gaming season and increased consumer spending. February is a surprising outlier at 10,243 average recommendations 
-- with no clear explanation. January remains the weakest month at 2,711, suggesting studios should avoid January launches. October underperforms relative to its Q4 
-- position at only 4,939 average recommendations.

SELECT
  TO_CHAR(release_date, 'Month') AS release_month,
  ROUND(AVG(recommendations)::NUMERIC, 2) AS average_recommendations
FROM
  games
GROUP BY
  1,
  EXTRACT(
    MONTH
    FROM
      release_date
  )
ORDER BY
  EXTRACT(
    MONTH
    FROM
      release_date
  )



-- Business question: Top 10 most expensive games
-- Finding: All the games have null recommendations, suggesting games priced that high have no player base or are essentially shovelware.

SELECT
  name,
  price_usd,
  recommendations
FROM
  games
ORDER BY
  2 DESC
LIMIT 
  10



-- Business question: Top 10 most recommended games
-- Finding: The top 10 most recommended games are predominantly free or budget priced ($0 - $19.99), with Counter Strike 2 and PUBG being free to play. Only Rust at 
-- $39.99 breaks into the top 10 as a Premium priced game.

SELECT
  name,
  price_usd,
  recommendations
FROM
  games
WHERE
  recommendations IS NOT NULL
ORDER BY
  3 DESC
LIMIT
  10



-- Business question: Do premium ($60+) priced games generate meaningful community engagement?
-- Finding: AAA ($60+) priced games show significantly lower recommendations than free games. One standout title drives the top result at 193,618 while the remaining 
-- nine generate under 50,000 recommendations each, suggesting that higher pricing significantly limits audience size for most titles.

SELECT
  name,
  price_usd,
  recommendations
FROM
  games
WHERE
  recommendations IS NOT NULL
ORDER BY
  2 DESC,
  3 DESC
LIMIT
  10



-- Business question: Top 5 most recommended games per price tier
-- Finding: Lower priced games dominate recommendations as free and budget tier games hold the highest recommendations counts. Rust, priced at $39.99, is the notable 
-- exception, being the only higher priced game with over one million recommendations, demonstrating that strong community driven games can overcome higher price
-- barriers.

WITH
  p_category AS (
    SELECT
      steam_appid,
      CASE
        WHEN price_usd = 0 THEN 'Free'
        WHEN price_usd <= 9.99 THEN 'Budget'
        WHEN price_usd <= 19.99 THEN 'Mid-range'
        WHEN price_usd <= 29.99 THEN 'Standard'
        WHEN price_usd <= 39.99 THEN 'Premium'
        WHEN price_usd <= 49.99 THEN 'High'
        WHEN price_usd <= 59.99 THEN 'Ultra'
        ELSE 'AAA'
      END AS price_category
    FROM
      games
  ),
  top_recommended AS (
    SELECT
      price_category,
      name,
      price_usd,
      recommendations,
      ROW_NUMBER() OVER (
        PARTITION BY
          price_category
        ORDER BY
          recommendations DESC
      ) AS rank
    FROM
      games
      LEFT JOIN p_category USING (steam_appid)
    WHERE
      recommendations IS NOT NULL
  )

SELECT
  price_category,
  name,
  price_usd,
  recommendations
FROM
  top_recommended
WHERE
  rank <= 5
ORDER BY
  CASE
    WHEN price_category = 'Free' THEN 1
    WHEN price_category = 'Budget' THEN 2
    WHEN price_category = 'Mid-range' THEN 3
    WHEN price_category = 'Standard' THEN 4
    WHEN price_category = 'Premium' THEN 5
    WHEN price_category = 'High' THEN 6
    WHEN price_category = 'Ultra' THEN 7
    ELSE 8
  END


-- Business question: Top 5 most recommended games per genre
-- Finding: Top recommended games per genre show that survival and sandbox games (Rust, Terraria, Project Zomboid, 7 Days to Die) appear across multiple genres, 
-- suggesting strong crossover appeal. Sports is the only genre where the top 5 are all priced $20+, while Action and Indie are dominated by budget and free titles. 
-- Racing shows the widest price range, from $1.99 to $69.99 in the top 5.

WITH
  top_genre AS (
    SELECT
      genre,
      name,
      price_usd,
      recommendations,
      ROW_NUMBER() OVER (
        PARTITION BY
          genre
        ORDER BY
          recommendations DESC
      ) AS rank
    FROM
      games_genre
      LEFT JOIN games USING (steam_appid)
    WHERE
      recommendations IS NOT NULL
  )

SELECT
  genre,
  name,
  price_usd,
  recommendations
FROM
  top_genre
WHERE
  rank <= 5
ORDER BY
  1,
  4 DESC
  


-- Business question: Does higher price correlate with more community engagement?
-- Finding: Excluding free games, there is a general positive correlation between price and average recommendations. Budget ($0.01 - $9.99) and Mid-range ($10 - $19.99) 
-- games have the lowest average recommendations at ~4,000, while Standard ($20 - $29.99) jumps to 9,156 and Premium ($30 - $39.99) reaches 24,628. AAA ($60+) games 
-- average 36,606 recommendations. This suggests that higher priced games attract more engaged communities, likely because players who pay more are more invested in the 
-- game and more likely to leave a review. High ($40 - $49.99) is the exception, dipping below Premium, possibly due to fewer games in that tier with strong communities.

WITH
  p_category AS (
    SELECT
      steam_appid,
      CASE
        WHEN price_usd = 0 THEN 'Free'
        WHEN price_usd <= 9.99 THEN 'Budget'
        WHEN price_usd <= 19.99 THEN 'Mid-range'
        WHEN price_usd <= 29.99 THEN 'Standard'
        WHEN price_usd <= 39.99 THEN 'Premium'
        WHEN price_usd <= 49.99 THEN 'High'
        WHEN price_usd <= 59.99 THEN 'Ultra'
        ELSE 'AAA'
      END AS price_category
    FROM
      games
  )

SELECT
  price_category,
  ROUND(AVG(recommendations)::NUMERIC, 2) AS average_recommendations
FROM
  games
  LEFT JOIN p_category USING(steam_appid)
GROUP BY
  1
ORDER BY
  CASE
    WHEN price_category = 'Free' THEN 1
    WHEN price_category = 'Budget' THEN 2
    WHEN price_category = 'Mid-range' THEN 3
    WHEN price_category = 'Standard' THEN 4
    WHEN price_category = 'Premium' THEN 5
    WHEN price_category = 'High' THEN 6
    WHEN price_category = 'Ultra' THEN 7
    ELSE 8
  END



-- Business question: Does higher pricing correlate with higher critic score?
-- Finding: There is a clear positive correlation between price and critic scores, with scores rising from 73 in the Budget tier ($0.01 - $9.99) to 88 in the AAA tier 
-- ($60+). This likely reflects that higher priced games receive more development investment and polish, attracting critical attention. It also confirms that metacritic 
-- scores are heavily skewed toward higher priced titles.

WITH
  p_category AS (
    SELECT
      steam_appid,
      CASE
        WHEN price_usd = 0 THEN 'Free'
        WHEN price_usd <= 9.99 THEN 'Budget'
        WHEN price_usd <= 19.99 THEN 'Mid-range'
        WHEN price_usd <= 29.99 THEN 'Standard'
        WHEN price_usd <= 39.99 THEN 'Premium'
        WHEN price_usd <= 49.99 THEN 'High'
        WHEN price_usd <= 59.99 THEN 'Ultra'
        ELSE 'AAA'
      END AS price_category
    FROM
      games
  )

SELECT
  price_category,
  COUNT(*) AS game_count,
  ROUND(AVG(metacritic)::NUMERIC, 2) AS average_score
FROM
  games
  LEFT JOIN p_category USING (steam_appid)
GROUP BY
  1
ORDER BY
  CASE
    WHEN price_category = 'Free' THEN 1
    WHEN price_category = 'Budget' THEN 2
    WHEN price_category = 'Mid-range' THEN 3
    WHEN price_category = 'Standard' THEN 4
    WHEN price_category = 'Premium' THEN 5
    WHEN price_category = 'High' THEN 6
    WHEN price_category = 'Ultra' THEN 7
    ELSE 8
  END



-- Business question: Which genre gets the highest average critic score?
-- Finding: Genre has minimal impact on critic scores as all genres fall within a narrow 70-75 range except Racing at 70.86 at the low end. This suggests critic quality
-- perception is largely independent of genre.

SELECT
  genre,
  COUNT(*) AS game_count,
  ROUND(AVG(metacritic)::NUMERIC, 2) AS average_score
FROM
  games_genre
  LEFT JOIN games USING (steam_appid)
WHERE
  metacritic IS NOT NULL
GROUP BY
  1
ORDER BY
  3 DESC



-- Business question: Do critically acclaimed games (high metacritic) also get high community engagement?
-- Finding: High metacritic scores do not reliably predict community engagement. Among the top 15 critically acclaimed games, recommendations range from 1,853 to 
-- 384,363, which is a 200x difference. This suggests critical reception and community engagement are largely independent metrics. A game can be critically acclaimed but 
-- remain niche, or conversely generate massive community engagement despite lower critic scores. For a studio, this implies that investing in quality for recognition 
-- alone may not drive player engagement.

SELECT
  name,
  recommendations,
  metacritic
FROM
  games
WHERE
  recommendations IS NOT NULL
  AND metacritic IS NOT NULL
ORDER BY
  metacritic DESC
LIMIT
  15



-- Business question: Are games getting better or worse over time?
-- Finding: Average metacritic scores declined from the early 2000s highs (88-96) to a trough around 2011 - 2016 (70 - 71), coinciding with Steam's rapid expansion and 
-- influx of indie titles. Scores have since recovered to 81 - 83 in 2024 - 2026, potentially reflecting improved quality filtering or maturing indie development. 
-- However, sample sizes vary significantly as early years have fewer than 5 games with metacritic scores while recent years have 30-38, making direct comparisons 
-- unreliable for pre-2010 data.

SELECT
  EXTRACT(
    YEAR
    FROM
      release_date
  ) AS release_year,
  COUNT(*) AS game_count,
  ROUND(AVG(metacritic)::NUMERIC) AS average_score
FROM
  games
WHERE
  metacritic IS NOT NULL
GROUP BY
  1
ORDER BY
  1



-- Business question: Do solo developers score lower than larger teams?
-- Finding: Solo developers average a metacritic score of 74 while teams of 2-4 developers score progressively higher, peaking at 86 for a 4 person team. Games with 5+ 
-- developers have insufficient metacritic data to draw conclusions, likely because larger team projects on Steam are niche titles that don't attract critic reviews.

SELECT
  developer_count,
  ROUND(AVG(metacritic)::NUMERIC) AS average_score
FROM
  games
WHERE
  developer_count > 0
  AND metacritic IS NOT NULL
GROUP BY
  1
ORDER BY
  1



-- Business question: Does team size predict commercial success?
-- Finding: Solo developers account for the vast majority of games with recommendations at 3,149 games and average 7,826 recommendations. However, sample sizes drop 
-- sharply for teams of 2+ developers, making comparisons unreliable. No clear trend between team size and community engagement can be established from this data.

SELECT
  developer_count,
  ROUND(AVG(recommendations)::NUMERIC, 2) AS average_recommendations,
  COUNT(*) AS game_count
FROM
  games
WHERE
  developer_count > 0
  AND developer_count IS NOT NULL
  AND recommendations IS NOT NULL
GROUP BY
  1
ORDER BY
  1