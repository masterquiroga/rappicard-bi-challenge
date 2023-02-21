CREATE OR REPLACE TABLE `rappicard-bi-challenge.bronze.events` AS
WITH cleaned_data AS (
    SELECT DISTINCT
        ID, 
        UPDATE,
        CASE 
            WHEN STATUS IS NULL THEN NULL
            ELSE TRIM(STATUS)
        END AS STATUS,
        CASE 
            WHEN MOTIVE IS NULL THEN NULL
            ELSE TRIM(MOTIVE)
        END AS MOTIVE,
        CASE 
            WHEN INTEREST_RATE IS NULL OR NOT REGEXP_CONTAINS(INTEREST_RATE, r'^[-+]?[0-9]*\.?[0-9]+$') THEN 0
            ELSE CAST(TRIM(INTEREST_RATE) AS FLOAT64)
        END AS INTEREST_RATE,
        CASE 
            WHEN AMOUNT IS NULL OR NOT REGEXP_CONTAINS(AMOUNT, r'^[-+]?[0-9]*\.?[0-9]+$') THEN 0
            ELSE CAST(TRIM(AMOUNT) AS FLOAT64)
        END AS AMOUNT,
        CASE 
            WHEN PRODUCT_ID IS NULL THEN NULL
            ELSE TRIM(PRODUCT_ID)
        END AS PRODUCT_ID,
        CASE 
            WHEN CAT IS NULL OR NOT REGEXP_CONTAINS(CAT, r'^[-+]?[0-9]*\.?[0-9]+$') THEN 0
            ELSE CAST(TRIM(CAT) AS FLOAT64)
        END AS CAT,
        CASE 
            WHEN TXN IS NULL OR NOT REGEXP_CONTAINS(TXN, r'^[-+]?[0-9]*\.?[0-9]+$') THEN 0
            ELSE CAST(TRIM(TXN) AS FLOAT64)
        END AS TXN,
        CASE 
            WHEN CP IS NULL THEN NULL
            ELSE TRIM(CP)
        END AS CP,
        CASE 
            WHEN DELIVERY_SCORE = "Sin Puntuación" OR DELIVERY_SCORE IS NULL OR NOT REGEXP_CONTAINS(DELIVERY_SCORE, r'^[-+]?[0-9]+$') THEN NULL
            ELSE CAST(TRIM(DELIVERY_SCORE) AS INT64)
        END AS DELIVERY_SCORE,
        CASE 
            WHEN SALES_CHANNEL IS NULL THEN ''
            ELSE TRIM(SALES_CHANNEL)
        END AS SALES_CHANNEL
    FROM `rappicard-bi-challenge.raw.events`
),
imputed_data AS (
    SELECT 
        ID,
        /** Specific fix for the 2 identified cases with the clear correction */
        CASE WHEN EXTRACT(YEAR FROM UPDATE) = 2023
            THEN (
                DATE_SUB(UPDATE, INTERVAL 3 YEAR)
            )
            ELSE UPDATE
        END UPDATE,
        CASE
            WHEN TXN > 0 THEN "TRANSACTION"
            WHEN CAT > 0 OR INTEREST_RATE > 0 OR AMOUNT > 0 OR MOTIVE IN ("DIGITAL", "PLASTIC") THEN "APPROVED"
            WHEN MOTIVE IN ("MOP", "USAGE", "INCOME", "EMPTY") THEN "REJECTED"
            WHEN DELIVERY_SCORE >= 0 THEN "DELIVERED"
            WHEN STATUS = "" THEN "NO RESPONSE"
            ELSE IFNULL(STATUS, "NO RESPONSE")
        END AS STATUS,
        CASE WHEN STATUS = "APPROVED"
            THEN IFNULL(MOTIVE, (SELECT MOTIVE FROM cleaned_data WHERE MOTIVE IN ("DIGITAL", "PLASTIC") GROUP BY MOTIVE ORDER BY COUNT(*) DESC LIMIT 1))
            ELSE CASE WHEN STATUS = "REJECTED"
                THEN IFNULL(MOTIVE, (SELECT MOTIVE FROM cleaned_data WHERE MOTIVE IN ("MOP", "USAGE", "INCOME", "EMPTY") GROUP BY MOTIVE ORDER BY COUNT(*) DESC LIMIT 1))
                ELSE NULL
            END
        END AS MOTIVE,
        CASE WHEN STATUS <> "APPROVED"
            THEN NULL
            ELSE IFNULL(INTEREST_RATE, 0)
        END AS INTEREST_RATE,
        CASE WHEN STATUS <> "APPROVED"
            THEN NULL
            ELSE IFNULL(AMOUNT, 0)
        END AS AMOUNT,
        PRODUCT_ID,
        CASE WHEN STATUS <> "APPROVED"
            THEN NULL
            # @see https://www.gob.mx/cms/uploads/attachment/file/56414/LTOSF.pdf
            ELSE CASE WHEN CAT < INTEREST_RATE
                THEN IFNULL(INTEREST_RATE, 00)
                ELSE IFNULL(CAT, 0)
            END
        END AS CAT,
        TXN,
        IFNULL(CP, (SELECT CP FROM cleaned_data WHERE CP <> '' GROUP BY CP ORDER BY COUNT(*) DESC LIMIT 1)) AS CP,
        CASE WHEN STATUS = "DELIVERED"
            THEN IFNULL(DELIVERY_SCORE, (SELECT DISTINCT AVG(DELIVERY_SCORE) OVER() FROM cleaned_data WHERE DELIVERY_SCORE IS NOT NULL))
            ELSE NULL
        END DELIVERY_SCORE,
        IFNULL(SALES_CHANNEL, (SELECT SALES_CHANNEL FROM cleaned_data WHERE SALES_CHANNEL <> '' GROUP BY SALES_CHANNEL ORDER BY COUNT(*) DESC LIMIT 1)) AS SALES_CHANNEL
    FROM cleaned_data
)
SELECT
    *
FROM imputed_data
WHERE STATUS IS NOT NULL AND STATUS <> "";