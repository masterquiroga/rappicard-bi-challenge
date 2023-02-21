CREATE OR REPLACE TABLE `rappicard-bi-challenge.silver.events` AS
WITH usable_data AS (
  SELECT
    GENERATE_UUID() AS uuid,
    ID as customer,
    CAST(UPDATE AS DATE) AS date,
    DATE_TRUNC(UPDATE, day) AS day,
    DATE_TRUNC(UPDATE, week) AS week,
    DATE_TRUNC(UPDATE, month) AS month,
    DATE_TRUNC(UPDATE, quarter) AS quarter,
    DATE_TRUNC(UPDATE, year) AS year,
    STATUS,
    MOTIVE,
    INTEREST_RATE / 100 AS INTEREST_RATE,
    AMOUNT,
    PRODUCT_ID,
    CAT / 100 AS CAT,
    TXN,
    CP,
    DELIVERY_SCORE,
    SALES_CHANNEL,
    CASE
      WHEN DELIVERY_SCORE < 6 THEN 'Detractor'
      WHEN DELIVERY_SCORE BETWEEN 7 AND 8 THEN 'Passive'
      WHEN DELIVERY_SCORE BETWEEN 9 AND 10 THEN 'Promotor'
      ELSE NULL
    END AS DELIVERY_SCORE_CATEGORY,
  FROM `rappicard-bi-challenge.bronze.events`
),
improved_data AS (
  SELECT 
    u.*
  FROM usable_data u
)
SELECT 
  *
FROM improved_data;
