/**
 *  wow such query
 * ░░░░░░░░░▄░░░░░░░░░░░░░░▄░░░░
 * ░░░░░░░░▌▒█░░░░░░░░░░░▄▀▒▌░░░
 * ░░░░░░░░▌▒▒█░░░░░░░░▄▀▒▒▒▐░░░
 * ░░░░░░░▐▄▀▒▒▀▀▀▀▄▄▄▀▒▒▒▒▒▐░░░
 * ░░░░░▄▄▀▒░▒▒▒▒▒▒▒▒▒█▒▒▄█▒▐░░░
 * ░░░▄▀▒▒▒░░░▒▒▒░░░▒▒▒▀██▀▒▌░░░ 
 * ░░▐▒▒▒▄▄▒▒▒▒░░░▒▒▒▒▒▒▒▀▄▒▒▌░░
 * ░░▌░░▌█▀▒▒▒▒▒▄▀█▄▒▒▒▒▒▒▒█▒▐░░
 * ░▐░░░▒▒▒▒▒▒▒▒▌██▀▒▒░░░▒▒▒▀▄▌░  many customers
 * ░▌░▒▄██▄▒▒▒▒▒▒▒▒▒░░░░░░▒▒▒▒▌░
 * ▀▒▀▐▄█▄█▌▄░▀▒▒░░░░░░░░░░▒▒▒▐░
 * ▐▒▒▐▀▐▀▒░▄▄▒▄▒▒▒▒▒▒░▒░▒░▒▒▒▒▌
 * ▐▒▒▒▀▀▄▄▒▒▒▄▒▒▒▒▒▒▒▒░▒░▒░▒▒▐░
 * ░▌▒▒▒▒▒▒▀▀▀▒▒▒▒▒▒░▒░▒░▒░▒▒▒▌░
 * ░▐▒▒▒▒▒▒▒▒▒▒▒▒▒▒░▒░▒░▒▒▄▒▒▐░░
 * ░░▀▄▒▒▒▒▒▒▒▒▒▒▒░▒░▒░▒▄▒▒▒▒▌░░  wow
 * ░░░░▀▄▒▒▒▒▒▒▒▒▒▒▄▄▄▀▒▒▒▒▄▀░░░
 * ░░░░░░▀▄▄▄▄▄▄▀▀▀▒▒▒▒▒▄▄▀░░░░░
 * ░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▀▀░░░░░░░░
 * 
 * This SQL query creates the "customers" ABT in the "gold" dataset for the RappiCard BI Challenge. 
 * First off, we start with some data that's been selected from the "events" table. 
 * From there, we create a few different tables that have different stats for each customer, 
 * such as the date of their first event, their response rate, and the time it took for them to get approved.
 * (Among many other useful stats).
 *
 * Then we join all of these tables together and calculate some additional stats, 
 * such as the time it took for a customer to respond and the time it took to get approved.
 * We also figure out if a customer has ever been delinquent (meaning they owe more money than they can pay back).
 * Finally, we add in some additional columns with even more stats (such as the time between first and last transactions),
 * and we order everything by the date of the customer's first event... Et voilà!
 * 
 * @author Víctor G. G. Quiroga <masterquiroga@protonmail.ch>
 */
CREATE OR REPLACE TABLE `rappicard-bi-challenge.gold.customers` AS (
    WITH data AS (
        SELECT * FROM `rappicard-bi-challenge.gold.events`
    ),
    contacted AS (
        SELECT
            customer,
            MIN(date) date,
            MIN(date) cohort,
            MIN(date) first_event,
            MAX(date) last_event,
            MAX(CASE WHEN STATUS = "NO RESPONSE" THEN 1 ELSE 0 END) not_responded,
            SUM(CASE WHEN STATUS = "NO RESPONSE" THEN 1 ELSE 0 END) no_response_count,
            MIN(CASE WHEN STATUS = "NO RESPONSE" THEN date ELSE NULL END) first_no_response,
            MAX(CASE WHEN STATUS = "NO RESPONSE" THEN date ELSE NULL END) last_no_response,
        FROM data
        GROUP BY customer
    ),
    responded AS (
        SELECT
            customer,
            MAX(CASE WHEN STATUS = "RESPONSE" THEN 1 ELSE 0 END) responded,
            SUM(CASE WHEN STATUS = "RESPONSE" THEN 1 ELSE 0 END) response_count,
            MIN(CASE WHEN STATUS = "RESPONSE" THEN date ELSE NULL END) first_response,
            MAX(CASE WHEN STATUS = "RESPONSE" THEN date ELSE NULL END) last_response
        FROM data
        GROUP BY customer
    ),
    evaluated AS (
        SELECT
            customer,
            MAX(CASE WHEN STATUS = "EVALUATED" THEN 1 ELSE 0 END) evaluated,
            SUM(CASE WHEN STATUS = "EVALUATED" THEN 1 ELSE 0 END) evaluation_count,
            MIN(CASE WHEN STATUS = "EVALUATED" THEN date ELSE NULL END) first_evaluation,
            MAX(CASE WHEN STATUS = "EVALUATED" THEN date ELSE NULL END) last_evaluation
        FROM data
        GROUP BY customer
    ),
    rejected AS (
        SELECT
            customer,
            MAX(CASE WHEN STATUS = "REJECTED" THEN 1 ELSE 0 END) rejected,
            SUM(CASE WHEN STATUS = "REJECTED" THEN 1 ELSE 0 END) rejection_count,
            MIN(CASE WHEN STATUS = "REJECTED" THEN date ELSE NULL END) first_rejection,
            MAX(CASE WHEN STATUS = "REJECTED" THEN date ELSE NULL END) last_rejection,

            MAX(CASE WHEN MOTIVE = "EMPTY" THEN 1 ELSE 0 END) empty_rejected,
            SUM(CASE WHEN MOTIVE = "EMPTY" THEN 1 ELSE 0 END) empty_rejection_count,
            MIN(CASE WHEN MOTIVE = "EMPTY" THEN date ELSE NULL END) first_empty_rejection,
            MAX(CASE WHEN MOTIVE = "EMPTY" THEN date ELSE NULL END) last_empty_rejection,

            MAX(CASE WHEN MOTIVE = "INCOME" THEN 1 ELSE 0 END) income_rejected,
            SUM(CASE WHEN MOTIVE = "INCOME" THEN 1 ELSE 0 END) income_rejection_count,
            MIN(CASE WHEN MOTIVE = "INCOME" THEN date ELSE NULL END) first_income_rejection,
            MAX(CASE WHEN MOTIVE = "INCOME" THEN date ELSE NULL END) last_income_rejection,

            MAX(CASE WHEN MOTIVE = "MOP" THEN 1 ELSE 0 END) mop_rejected,
            SUM(CASE WHEN MOTIVE = "MOP" THEN 1 ELSE 0 END) mop_rejection_count,
            MIN(CASE WHEN MOTIVE = "MOP" THEN date ELSE NULL END) first_mop_rejection,
            MAX(CASE WHEN MOTIVE = "MOP" THEN date ELSE NULL END) last_mop_rejection,

            MAX(CASE WHEN MOTIVE = "USAGE" THEN 1 ELSE 0 END) usage_rejected,
            SUM(CASE WHEN MOTIVE = "USAGE" THEN 1 ELSE 0 END) usage_rejection_count,
            MIN(CASE WHEN MOTIVE = "USAGE" THEN date ELSE NULL END) first_usage_rejection,
            MAX(CASE WHEN MOTIVE = "USAGE" THEN date ELSE NULL END) last_usage_rejection

        FROM data
        GROUP BY customer
    ),
    approved AS (
        SELECT
            stats.*,
            ohlca.* EXCEPT(customer)
        FROM (
            SELECT DISTINCT
                customer,
                FIRST_VALUE(CASE WHEN STATUS = "APPROVED" THEN amount ELSE 0 END) OVER customer_dates AS opening_amount_approved,
                MAX(CASE WHEN STATUS = "APPROVED" THEN amount ELSE NULL END) OVER customer_dates AS highest_amount_approved,
                MIN(CASE WHEN STATUS = "APPROVED" THEN amount ELSE NULL END) OVER customer_dates AS lowest_amount_approved,
                LAST_VALUE(CASE WHEN STATUS = "APPROVED" THEN amount ELSE 0 END) OVER customer_dates AS closing_amount_approved,
                AVG(CASE WHEN STATUS = "APPROVED" THEN amount ELSE NULL END) OVER customer_dates AS avg_amount_approved,
                
                FIRST_VALUE(CASE WHEN MOTIVE = "PLASTIC" THEN amount ELSE 0 END) OVER customer_dates AS opening_plastic_amount_approved,
                MAX(CASE WHEN MOTIVE = "PLASTIC" THEN amount ELSE NULL END) OVER customer_dates AS highest_plastic_amount_approved,
                MIN(CASE WHEN MOTIVE = "PLASTIC" THEN amount ELSE NULL END) OVER customer_dates AS lowest_plastic_amount_approved,
                LAST_VALUE(CASE WHEN MOTIVE = "PLASTIC" THEN amount ELSE 0 END) OVER customer_dates AS closing_plastic_amount_approved,
                AVG(CASE WHEN MOTIVE = "PLASTIC" THEN amount ELSE NULL END) OVER customer_dates AS avg_plastic_amount_approved,

                FIRST_VALUE(CASE WHEN MOTIVE = "DIGITAL" THEN amount ELSE 0 END) OVER customer_dates AS opening_digital_amount_approved,
                MAX(CASE WHEN MOTIVE = "DIGITAL" THEN amount ELSE NULL END) OVER customer_dates AS highest_digital_amount_approved,
                MIN(CASE WHEN MOTIVE = "DIGITAL" THEN amount ELSE NULL END) OVER customer_dates AS lowest_digital_amount_approved,
                LAST_VALUE(CASE WHEN MOTIVE = "DIGITAL" THEN amount ELSE 0 END) OVER customer_dates AS closing_digital_amount_approved,
                AVG(CASE WHEN MOTIVE = "DIGITAL" THEN amount ELSE NULL END) OVER customer_dates AS avg_digital_amount_approved
            FROM data
            WINDOW customer_dates AS (
                PARTITION BY customer
                ORDER BY date ASC
                ROWS BETWEEN UNBOUNDED PRECEDING 
                AND UNBOUNDED FOLLOWING
            )
        ) ohlca
        LEFT JOIN (
            SELECT
                data.customer,
                MAX(CASE WHEN STATUS = "APPROVED" THEN 1 ELSE 0 END) approved,
                SUM(CASE WHEN STATUS = "APPROVED" THEN 1 ELSE 0 END) approval_count,
                MAX(CASE WHEN MOTIVE = "PLASTIC" THEN 1 ELSE 0 END) plastic_approved,
                SUM(CASE WHEN MOTIVE = "PLASTIC" THEN 1 ELSE 0 END) plastic_approval_count,
                MAX(CASE WHEN MOTIVE = "DIGITAL" THEN 1 ELSE 0 END) digital_approved,
                SUM(CASE WHEN MOTIVE = "DIGITAL" THEN 1 ELSE 0 END) digital_approval_count,
                MIN(CASE WHEN STATUS = "APPROVED" THEN date ELSE NULL END) first_approval,
                MAX(CASE WHEN STATUS = "APPROVED" THEN date ELSE NULL END) last_approval,
                MIN(CASE WHEN MOTIVE = "PLASTIC" THEN date ELSE NULL END) first_plastic_approval,
                MAX(CASE WHEN MOTIVE = "PLASTIC" THEN date ELSE NULL END) last_plastic_approval,
                MIN(CASE WHEN MOTIVE = "DIGITAL" THEN date ELSE NULL END) first_digital_approval,
                MAX(CASE WHEN MOTIVE = "DIGITAL" THEN date ELSE NULL END) last_digital_approval,
            FROM data
            GROUP BY customer
        ) stats
        ON ohlca.customer = stats.customer
    ),
    delivered AS (
        SELECT
            stats.*,
            ohlca.* EXCEPT(customer)
        FROM (
            SELECT DISTINCT
                customer,
                FIRST_VALUE(CASE WHEN STATUS = "DELIVERED" THEN DELIVERY_SCORE ELSE 0 END) OVER customer_dates AS opening_delivery_score,
                MAX(CASE WHEN STATUS = "DELIVERED" THEN DELIVERY_SCORE ELSE NULL END) OVER customer_dates AS highest_delivery_score,
                MIN(CASE WHEN STATUS = "DELIVERED" THEN DELIVERY_SCORE ELSE NULL END) OVER customer_dates AS lowest_delivery_score,
                LAST_VALUE(CASE WHEN STATUS = "DELIVERED" THEN DELIVERY_SCORE ELSE 0 END) OVER customer_dates AS closing_delivery_score,
                AVG(CASE WHEN STATUS = "DELIVERED" THEN DELIVERY_SCORE ELSE NULL END) OVER customer_dates AS avg_delivery_score
            FROM data
            WINDOW customer_dates AS (
                PARTITION BY customer
                ORDER BY date ASC
                ROWS BETWEEN UNBOUNDED PRECEDING 
                AND UNBOUNDED FOLLOWING
            )
        ) ohlca
        LEFT JOIN (
            SELECT
                data.customer,
                MAX(CASE WHEN STATUS = "DELIVERED" THEN 1 ELSE 0 END) delivered,
                SUM(CASE WHEN STATUS = "DELIVERED" THEN 1 ELSE 0 END) delivery_count,
                MIN(CASE WHEN STATUS = "DELIVERED" THEN date ELSE NULL END) first_delivery,
                MAX(CASE WHEN STATUS = "DELIVERED" THEN date ELSE NULL END) last_delivery,
            FROM data
            GROUP BY customer
        ) stats
        ON ohlca.customer = stats.customer
    ),
    transacted AS (
        SELECT
            stats.*,
            ohlca.* EXCEPT(customer),
        FROM (
            SELECT DISTINCT
                customer,
                FIRST_VALUE(CASE WHEN STATUS = "TRANSACTION" THEN TXN ELSE 0 END) OVER customer_dates AS opening_transaction_amount,
                MAX(CASE WHEN STATUS = "TRANSACTION" THEN TXN ELSE NULL END) OVER customer_dates AS highest_transaction_amount,
                MIN(CASE WHEN STATUS = "TRANSACTION" THEN TXN ELSE NULL END) OVER customer_dates AS lowest_transaction_amount,
                LAST_VALUE(CASE WHEN STATUS = "TRANSACTION" THEN TXN ELSE 0 END) OVER customer_dates AS closing_transaction_amount,
                AVG(CASE WHEN STATUS = "TRANSACTION" THEN TXN ELSE NULL END) OVER customer_dates AS avg_transaction_amount
            FROM data
            WINDOW customer_dates AS (
                PARTITION BY customer
                ORDER BY date ASC
                ROWS BETWEEN UNBOUNDED PRECEDING 
                AND UNBOUNDED FOLLOWING
            )
        ) ohlca
        LEFT JOIN (
            SELECT
                data.customer,
                MAX(CASE WHEN STATUS = "TRANSACTION" THEN 1 ELSE 0 END) transacted,
                MIN(CASE WHEN STATUS = "TRANSACTION" THEN date ELSE NULL END) first_transaction,
                MAX(CASE WHEN STATUS = "TRANSACTION" THEN date ELSE NULL END) last_transaction,
                SUM(CASE WHEN STATUS = "TRANSACTION" THEN 1 ELSE 0 END) transaction_count,
                SUM(CASE WHEN STATUS = "TRANSACTION" THEN TXN ELSE 0 END) transaction_volume,
                SUM(CASE WHEN STATUS = "TRANSACTION" THEN txn_present_value ELSE 0 END) transaction_volume_pv,
                SUM(CASE WHEN STATUS = "TRANSACTION" THEN txn_present_value - TXN ELSE 0 END) interest_accrued
            FROM data
            GROUP BY customer
        ) stats
        ON ohlca.customer = stats.customer
    ),
    rfmd AS (
        WITH stats AS (
            SELECT DISTINCT
                d.customer,
                d.cohort,
                DATE_DIFF(CURRENT_DATE(), last_event, DAY) AS recency,
                transaction_count AS frequency,
                interest_accrued AS monetary,
                DATE_DIFF(last_transaction, first_transaction, DAY) transactions_lifespan,
                AVG(DATE_DIFF(last_transaction, first_transaction, DAY)) OVER() AS global_transactions_lifespan,
                AVG(DATE_DIFF(last_transaction, first_transaction, DAY)) OVER() AS global_intratransaction_time,
                AVG(transaction_count) OVER() AS global_transaction_count,
                (AVG(DATE_DIFF(last_transaction, first_transaction, DAY)) OVER()/AVG(transaction_count) OVER()) AS global_churn_threshold,
                interest_accrued,
                a.highest_amount_approved,
                transaction_count,
                transaction_volume,
                last_transaction
            FROM
                contacted d
            LEFT JOIN transacted t
            ON d.customer = t.customer
            LEFT JOIN approved a
            ON d.customer = a.customer
        ), 
        hazards AS (
            SELECT
                *,
                /**
                *
                * If someone transacts more volume than whatever the most he/she was granted
                * and his last transaction was done more than one month ago
                * then it meant he/she was somehow able to pay its credit before making that
                * transaction somewhere in between regardless if he/she is
                * able to pay it later on...
                * (because you couldn't have transacted more than what you were granted
                * unless you somehow paid in advance).
                *
                * Note that I'm not saying risk, but `hazard` since it's not a real probability,
                * but rather we're giving an abstract measure for the potential source of intensity
                * an undesirable event. Also numerically it can be > 1.
                */
                CASE WHEN 
                    (highest_amount_approved >= transaction_volume) AND
                    recency >= 28
                    THEN 0
                    ELSE interest_accrued/GREATEST(highest_amount_approved, 1)
                END AS default_hazard,
                CASE WHEN recency < global_churn_threshold
                    THEN 0
                    ELSE transactions_lifespan/global_transactions_lifespan
                END AS churn_hazard
            FROM stats
        ),
        ranks AS (
            SELECT
                *,
                /**
                * Note that I'm incorporating the cohort as a secondary ordering
                * and the customer ID. Since customer IDs are sequential,
                * it is reasonably that if both customers were created in the same
                * date and have the same observations, we use the fact that 
                * a lower customer ID should've create early on 
                * than a customer with a higher lower ID
                * and thus, theoretically, has cumulated "more" information.
                */
                CUME_DIST() OVER (ORDER BY default_hazard DESC, cohort, customer DESC) AS a_priori_default_risk,
                CUME_DIST() OVER (ORDER BY churn_hazard DESC, cohort, customer DESC) AS a_priori_churn_risk,
                CUME_DIST() OVER (ORDER BY recency DESC, cohort, customer DESC)  AS recency_rank,
                CUME_DIST() OVER (ORDER BY frequency ASC, cohort, customer DESC) AS frequency_rank,
                CUME_DIST() OVER (ORDER BY monetary ASC, cohort, customer DESC) AS monetary_rank
            FROM hazards
        ),
        /**
         * We attempt to estimate delinquency (payment past due) if one of the two criterions are met:
         * - The amount granted is 0 and his transactionality is > 0
         * Or:
         * - He or she is above the 50% percentile for the default hazard
         * - A customer made it's last transaction a (statistically) long time ago (probably churned)
         * - The accrued interest is more than whatever he or she was granted the most
         */
        delinquency AS (
            SELECT
                *,
                CASE 
                    WHEN a_priori_churn_risk > 0.5 THEN 1
                    ELSE 0
                END AS churn,

                (CASE 
                    WHEN highest_amount_approved <= 0 OR interest_accrued <= 0 THEN 1 
                    ELSE 
                        (CASE WHEN a_priori_default_risk > 0.5 THEN 1 ELSE 0 END) *
                        (CASE WHEN a_priori_churn_risk > 0.5 THEN 1 ELSE 0 END) *
                        (CASE WHEN interest_accrued > highest_amount_approved THEN 1 ELSE 0 END)
                END) 
                AS delinquent
            FROM 
                ranks
        ),
        risks AS (
            SELECT
                *,
                CUME_DIST() OVER(ORDER BY delinquent DESC, cohort, customer DESC) AS delinquency_risk,
            FROM delinquency
        ),
        corrs AS (
            SELECT 
                risks.*,
                CORR(recency_rank, frequency_rank) OVER() AS rf_corr,
                CORR(recency_rank, monetary_rank) OVER() AS rm_corr,
                CORR(frequency_rank, monetary_rank) OVER() AS fm_corr,
                CORR(recency_rank, delinquency_risk) OVER() as rd_corr,
                CORR(frequency_rank, delinquency_risk) OVER() as fd_corr,
                CORR(monetary_rank, delinquency_risk) OVER() as md_corr
            FROM risks
        ),
        interactions AS (
            SELECT
                *,
                (
                        1 + rf_corr + rm_corr + rd_corr
                    +   ((rf_corr * rm_corr) + (rd_corr * rm_corr) + (rf_corr * rd_corr))/2
                    +   (rf_corr * rm_corr * rd_corr) / 3
                ) AS recency_interactions,
                (
                        1 + rf_corr + fm_corr + fd_corr
                    +   ((rf_corr * fm_corr) + (fd_corr * fm_corr) + (rf_corr * fd_corr))/2
                    +   (rf_corr * fm_corr * fd_corr) / 3
                ) AS frequency_interactions,
                (
                        1 + fm_corr + rm_corr + md_corr
                    +   ((fm_corr * rm_corr) + (md_corr * rm_corr) + (fm_corr * md_corr))/2
                    +   (fm_corr * rm_corr * md_corr) / 3
                ) AS monetary_interactions,
                (
                        1 + rd_corr + md_corr + fd_corr
                    +   ((rd_corr * md_corr) + (fd_corr * md_corr) + (rd_corr * fd_corr))/2
                    +   (rd_corr * md_corr * fd_corr) / 3
                ) AS delinquency_interactions
            FROM corrs
        )
        SELECT
            customer,
            recency,
            frequency,
            monetary,
            recency_rank,
            frequency_rank,
            monetary_rank,
            a_priori_churn_risk,
            a_priori_default_risk,
            churn,
            delinquent,
            /** RFMD copula */
            CUME_DIST() OVER(ORDER BY (
                recency_rank * recency_interactions +
                frequency_rank * frequency_interactions +
                monetary_rank * monetary_interactions +
                delinquent * delinquency_interactions
            )) AS rfmd
        FROM interactions
    )
    SELECT DISTINCT
        CURRENT_DATE() AS information_date,
        GENERATE_UUID() AS uuid,
        DATE_DIFF(CURRENT_DATE(), cohort, DAY) AS lifespan,
        recency,
        frequency,
        monetary,
        a_priori_churn_risk,
        a_priori_default_risk,
        churn,
        delinquent,
        rfmd.rfmd AS score,
        contacted.*,
        DATE_DIFF(responded.first_response, LEAST(contacted.first_no_response, responded.first_response), DAY) AS time_to_response,
        DATE_DIFF(evaluated.first_evaluation, responded.first_response, DAY) AS time_to_evaluation,
        DATE_DIFF(rejected.first_rejection, evaluated.first_evaluation, DAY) AS time_to_rejection,
        DATE_DIFF(approved.first_approval, evaluated.first_evaluation, DAY) AS time_to_approval,
        DATE_DIFF(delivered.first_delivery, approved.first_approval, DAY) AS time_to_delivery,
        DATE_DIFF(transacted.first_transaction, GREATEST(delivered.first_delivery, approved.first_approval), DAY) AS time_to_first_transaction,
        (DATE_DIFF(transacted.last_transaction, transacted.first_transaction, DAY) / GREATEST(1, transacted.transaction_count)) AS intra_transaction_time,
        responded.* EXCEPT(customer),
        evaluated.* EXCEPT(customer),
        rejected.* EXCEPT(customer),
        approved.* EXCEPT(customer),
        delivered.* EXCEPT(customer),
        transacted.* EXCEPT(customer),
        rfmd.* EXCEPT(
            customer,
            recency,
            frequency,
            monetary,
            churn,
            delinquent,
            a_priori_churn_risk,
            a_priori_default_risk,
            rfmd
        )
    FROM contacted 
    LEFT JOIN responded
    ON contacted.customer = responded.customer
    LEFT JOIN evaluated
    ON contacted.customer = evaluated.customer
    LEFT JOIN rejected
    ON contacted.customer = rejected.customer
    LEFT JOIN approved
    ON contacted.customer = approved.customer
    LEFT JOIN delivered
    ON contacted.customer = delivered.customer
    LEFT JOIN transacted
    ON contacted.customer = transacted.customer
    LEFT JOIN rfmd
    ON contacted.customer = rfmd.customer
    ORDER BY recency ASC, score ASC, first_event DESC, last_event DESC
);

