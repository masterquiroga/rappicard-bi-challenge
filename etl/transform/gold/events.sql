CREATE OR REPLACE TABLE `rappicard-bi-challenge.gold.events` AS
WITH improved_data AS (
    SELECT DISTINCT
        uuid,
        customer,
        date,
        day,
        week,
        month,
        quarter,
        year,
        STATUS,
        CASE WHEN MOTIVE IS NULL OR MOTIVE = "" THEN "NA"
        ELSE MOTIVE END AS MOTIVE,
        CASE WHEN STATUS = "REJECTED"
            THEN MOTIVE
            ELSE NULL
        END AS rejection_motive,

        CASE 
            WHEN 
                (MAX(CASE WHEN MOTIVE = "DIGITAL" THEN 1 ELSE 0 END) OVER(past_dates_by_customer)) = 1
            THEN "DIGITAL"
            WHEN 
                (MAX(CASE WHEN MOTIVE = "PLASTIC" THEN 1 ELSE 0 END) OVER(past_dates_by_customer)) = 1
            THEN "PLASTIC"
        END AS card_type,
        INTEREST_RATE,
        AMOUNT,
        PRODUCT_ID,
        CAT,
        TXN,
        CASE WHEN TXN > 0
            THEN LOG(1 + AVG(INTEREST_RATE) OVER (
                PARTITION BY customer
                    ORDER BY date ASC
                ROWS BETWEEN UNBOUNDED PRECEDING
                AND CURRENT ROW
            ))
            ELSE NULL
        END AS force_of_interest,
        CASE WHEN TXN > 0
            THEN LOG(1 + AVG(INTEREST_RATE) OVER (
                PARTITION BY customer
                    ORDER BY date ASC
                ROWS BETWEEN UNBOUNDED PRECEDING
                AND CURRENT ROW
            ))
            ELSE NULL
        END AS force_of_cost,
        CP,
        DELIVERY_SCORE,
        SALES_CHANNEL,
        DELIVERY_SCORE_CATEGORY,
        CASE WHEN STATUS = "NO RESPONSE" THEN 1 ELSE 0 END no_response_event,
        CASE WHEN STATUS = "RESPONSE" THEN 1 ELSE 0 END response_event,
        CASE WHEN STATUS IN ("NO RESPONSE", "RESPONSE") THEN 1 ELSE 0 END contact_event,
        CASE WHEN STATUS = "RISK" THEN 1 ELSE 0 END risk_evaluation_event,
        CASE WHEN STATUS = "REJECTED" THEN 1 ELSE 0 END rejection_event,
        CASE WHEN STATUS = "APPROVED" THEN 1 ELSE 0 END approval_event,
        CASE WHEN STATUS = "DELIVERED" THEN 1 ELSE 0 END delivery_event,
        CASE WHEN STATUS = "TRANSACTION" THEN 1 ELSE 0 END transaction_event,
        SUM(IFNULL(TXN, 0)) OVER(past_dates_by_customer) cumulated_volume,
        SUM(CASE WHEN TXN > 0 THEN 1 ELSE 0 END) OVER(past_dates_by_customer) cumulated_transactions,
        SUM(IFNULL(AMOUNT, 0)) OVER(past_dates_by_customer) cumulated_credit_amount,
        DATE_DIFF(MAX(date) OVER(past_dates_by_customer), MIN(date) OVER(past_dates_by_customer), DAY) customer_lifespan,
    FROM `rappicard-bi-challenge.silver.events`
    WINDOW past_dates_by_customer AS (
        PARTITION BY customer
        ORDER BY date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )
),
lateral_dates AS (
    SELECT
            uuid,
            customer,
            date,
            STATUS,
            LAG(date) OVER(PARTITION BY customer ORDER BY date, 
                CASE STATUS
                    WHEN "NO RESPONSE" THEN 1
                    WHEN "RESPONSE" THEN 2
                    WHEN "RISK" THEN 3
                    WHEN "REJECTED" THEN 4
                    WHEN "APPROVED" THEN 5
                    WHEN "DELIVERED" THEN 6
                    WHEN "TRANSACTION" THEN 7
                    ELSE 0            
                END ASC
            ) AS past_date,
            LEAD(date) OVER(PARTITION BY customer ORDER BY date, 
                CASE STATUS
                    WHEN "NO RESPONSE" THEN 1
                    WHEN "RESPONSE" THEN 2
                    WHEN "RISK" THEN 3
                    WHEN "REJECTED" THEN 4
                    WHEN "APPROVED" THEN 5
                    WHEN "DELIVERED" THEN 6
                    WHEN "TRANSACTION" THEN 7
                    ELSE 0            
                END ASC
            ) AS next_date,
        FROM
            improved_data
),
lateral_statuses AS (
    SELECT 
        *,
        LAG(STATUS) OVER(PARTITION BY customer ORDER BY date, CASE STATUS
                    WHEN "NO RESPONSE" THEN 1
                    WHEN "RESPONSE" THEN 2
                    WHEN "RISK" THEN 3
                    WHEN "REJECTED" THEN 4
                    WHEN "APPROVED" THEN 5
                    WHEN "DELIVERED" THEN 6
                    WHEN "TRANSACTION" THEN 7
                    ELSE 0            
                END ASC) AS past_status,
        LEAD(STATUS) OVER(PARTITION BY customer ORDER BY date, CASE STATUS
            WHEN "NO RESPONSE" THEN 1
            WHEN "RESPONSE" THEN 2
            WHEN "RISK" THEN 3
            WHEN "REJECTED" THEN 4
            WHEN "APPROVED" THEN 5
            WHEN "DELIVERED" THEN 6
            WHEN "TRANSACTION" THEN 7
            ELSE 0            
        END ASC) AS next_status,
    FROM
        lateral_dates
),
time_to_events AS (
    SELECT DISTINCT
        uuid,
        past_date,
        date,
        next_date,
        past_status,
        STATUS,
        next_status,
        DATE_DIFF(date, past_date, DAY) AS time_to_event,
        CASE 
            WHEN STATUS IN ("RESPONSE", "NO RESPONSE") AND past_status IN ("RESPONSE", "NO RESPONSE") THEN DATE_DIFF(date, past_date, DAY)
            ELSE NULL
        END intra_contact_time,
        CASE
            WHEN STATUS = 'RISK' AND past_status = "RESPONSE" THEN DATE_DIFF(date, past_date, DAY)
            ELSE NULL
        END AS time_to_evaluation,
        CASE
            WHEN STATUS = 'REJECTED' AND past_status = 'RISK' THEN DATE_DIFF(p.date, p.past_date, DAY)
            ELSE NULL
        END AS time_to_rejection,
        CASE
            WHEN STATUS = 'APPROVED' AND past_status = 'RISK' THEN DATE_DIFF(p.date, p.past_date, DAY)
            ELSE NULL
        END AS time_to_approval,
        CASE
            WHEN STATUS = 'DELIVERED' AND past_status = 'APPROVED' THEN DATE_DIFF(p.date, p.past_date, DAY)
            ELSE NULL
        END AS time_to_delivery,
        CASE
            WHEN STATUS = 'TRANSACTION' AND past_status = 'DELIVERED' THEN DATE_DIFF(p.date, p.past_date, DAY)
            ELSE NULL
        END AS time_to_first_transaction,
        CASE WHEN STATUS = 'TRANSACTION' THEN CASE WHEN past_status IN ('DELIVERED', 'APPROVED')
                THEN 1
                ELSE 0
            END
            ELSE NULL
        END AS is_first_transaction,
        CASE
            WHEN STATUS = 'TRANSACTION' AND past_status = 'TRANSACTION' THEN DATE_DIFF(p.date, p.past_date, DAY)
            ELSE NULL
        END AS intra_transaction_time,
        CASE 
            WHEN STATUS = 'TRANSACTION' THEN CASE WHEN next_status IS NULL
                THEN 1
                ELSE 0
            END
            ELSE NULL
        END AS is_last_transaction,
        CASE WHEN past_date IS NULL
            THEN 1
            ELSE 0
        END AS is_first_event,
        CASE WHEN next_date IS NULL
            THEN 1
            ELSE 0
        END AS is_last_event,
        ROW_NUMBER() OVER(PARTITION BY customer ORDER BY date, CASE STATUS
            WHEN "NO RESPONSE" THEN 1
            WHEN "RESPONSE" THEN 2
            WHEN "RISK" THEN 3
            WHEN "REJECTED" THEN 4
            WHEN "APPROVED" THEN 5
            WHEN "DELIVERED" THEN 6
            WHEN "TRANSACTION" THEN 7
            ELSE 0      
        END ASC) AS event_number,
        CASE 
            WHEN STATUS = "TRANSACTION" AND past_status NOT IN ("TRANSACTION", "DELIVERED", "APPROVED") THEN 1
            WHEN STATUS = "DELIVERED" AND past_status <> "APPROVED" THEN 1
            WHEN STATUS = "REJECTED" AND past_status <> "RISK" THEN 1
            WHEN STATUS = "APPROVED" AND past_status <> "RISK" THEN 1
            WHEN STATUS = "RISK" AND past_status <> "RESPONSE" THEN 1
            ELSE 0
        END is_incosistent,
    FROM lateral_statuses p
),
cash_flows AS (
    SELECT
        uuid,
        discount_factor,
        costing_factor,
        CASE WHEN TXN > 0
            THEN TXN * discount_factor
            ELSE NULL
        END AS txn_present_value,
        CASE WHEN TXN > 0
            THEN TXN * costing_factor
            ELSE NULL
        END AS txn_present_cost,
        CASE WHEN TXN > 0
            THEN TXN * discount_factor - TXN
            ELSE NULL
        END AS interest_accrued_since
    FROM (
        SELECT
            uuid,
            TXN,
            CASE WHEN TXN > 0
                THEN IFNULL(EXP( (force_of_interest) * (DATE_DIFF(CURRENT_DATE(), date, DAY)/365.25)), 1)
                ELSE NULL
            END AS discount_factor,
            CASE WHEN TXN > 0
                THEN IFNULL(EXP( (force_of_cost) * (DATE_DIFF(CURRENT_DATE(), date, DAY)/365.25)), 1)
                ELSE NULL
            END AS costing_factor,
        FROM improved_data
    )
),
rfm AS (
    WITH ranks AS (
        SELECT 
            d.uuid,
            CUME_DIST() OVER (ORDER BY date, customer DESC)  AS recency_rank,
            CUME_DIST() OVER (ORDER BY cumulated_transactions ASC, date, customer DESC) AS frequency_rank,
            CUME_DIST() OVER (ORDER BY interest_accrued_since ASC, date, customer DESC) AS monetary_rank
        FROM
            improved_data d
        LEFT JOIN cash_flows c
        ON d.uuid = c.uuid
    ),
    corrs AS (
        SELECT 
            ranks.*,
            CORR(recency_rank, frequency_rank) OVER() AS rf_corr,
            CORR(recency_rank, monetary_rank) OVER() AS rm_corr,
            CORR(frequency_rank, monetary_rank) OVER() AS fm_corr
        FROM ranks
    )
    SELECT
        corrs.*,
        /** Incorporate variable interactions to copula */
        CUME_DIST() OVER(ORDER BY (
              recency_rank * (1 + rf_corr + rm_corr + (rf_corr * rm_corr)/ 2)
            + frequency_rank * (1 + rf_corr + fm_corr + (rf_corr * fm_corr) / 2)
            + monetary_rank * (1 + rf_corr + fm_corr + (rm_corr * fm_corr) / 2)
        )) AS rfm
    FROM corrs
),
ultimate_data AS (
    SELECT
        CURRENT_DATE() AS information_date,
        d.uuid,
        DATE_DIFF(CURRENT_DATE(), d.date, DAY) AS recency, 
        d.cumulated_transactions AS frequency,
        interest_accrued_since AS monetary,
        rfm AS score,
        d.customer,
        d.date,
        d.day,
        d.week,
        d.month,
        d.quarter,
        d.year,
        CASE 
            WHEN d.AMOUNT = 0 AND next_status IS NULL AND MOTIVE NOT IN ("DIGITAL", "PLASTIC") OR MOTIVE IS NULL
            THEN "REJECTED"
            ELSE d.STATUS
        END STATUS,
        CASE 
            WHEN d.STATUS NOT IN ("APPROVED", "REJECTED") THEN NULL
            ELSE d.MOTIVE
        END MOTIVE,
        d.rejection_motive,
        d.card_type,
        d.INTEREST_RATE,
        d.AMOUNT,
        d.PRODUCT_ID,
        d.CAT,
        d.TXN,
        d.force_of_interest,
        d.force_of_cost,
        d.CP,
        d.DELIVERY_SCORE,
        d.SALES_CHANNEL,
        d.DELIVERY_SCORE_CATEGORY,
        d.no_response_event,
        d.response_event,
        d.contact_event,
        d.risk_evaluation_event,
        d.rejection_event,
        d.approval_event,
        d.delivery_event,
        d.transaction_event,
        d.cumulated_volume,
        d.cumulated_transactions,
        d.cumulated_credit_amount,
        d.customer_lifespan,

        event_number,
        is_first_event,
        is_last_event,
        is_first_transaction,
        is_last_transaction,
        is_incosistent,
        discount_factor,
        txn_present_value,
        txn_present_cost,
        past_date,
        past_status,
        time_to_event,
        next_date,
        next_status,
        intra_contact_time,
        time_to_evaluation,
        time_to_rejection,
        time_to_approval,
        time_to_delivery,
        time_to_first_transaction,
        intra_transaction_time,
        recency_rank,
        frequency_rank,
        monetary_rank,
        rf_corr,
        rm_corr,
        fm_corr,
        rfm
    FROM improved_data d
    LEFT JOIN time_to_events i
    ON d.uuid = i.uuid
    LEFT JOIN cash_flows c
    ON d.uuid = c.uuid
    LEFT JOIN rfm r
    ON d.uuid = r.uuid
)
SELECT
    *,
FROM ultimate_data
ORDER BY rfm DESC, date, customer, CASE STATUS
    WHEN "NO RESPONSE" THEN 1
    WHEN "RESPONSE" THEN 2
    WHEN "RISK" THEN 3
    WHEN "REJECTED" THEN 4
    WHEN "APPROVED" THEN 5
    WHEN "DELIVERED" THEN 6
    WHEN "TRANSACTION" THEN 7
    ELSE 0            
END ASC, CASE past_status
    WHEN "NO RESPONSE" THEN 1
    WHEN "RESPONSE" THEN 2
    WHEN "RISK" THEN 3
    WHEN "REJECTED" THEN 4
    WHEN "APPROVED" THEN 5
    WHEN "DELIVERED" THEN 6
    WHEN "TRANSACTION" THEN 7
    ELSE 0            
END ASC
