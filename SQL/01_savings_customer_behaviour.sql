
--Q1: Savings & Customer Behaviour

-- Q1a (i) — Average Savings Balance by Customer Segment



    SELECT
        customer_segment,
        COUNT(*)                          AS customer_count,
        ROUND(AVG(savings_balance)::numeric, 2)    AS avg_balance,
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY savings_balance )::numeric, 2)::numeric AS median_balance,
        ROUND(SUM(savings_balance)::numeric, 2)   AS total_balance
    FROM fintech
    WHERE savings_balance IS NOT NULL
    AND customer_segment IS NOT NULL
    GROUP BY customer_segment
    ORDER BY avg_balance DESC;



-- Q1a (ii) — Average Savings Balance by Province

    SELECT
        province,
        COUNT(*)                          AS customer_count,
        ROUND(AVG(savings_balance)::numeric, 2)    AS avg_balance,
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY savings_balance )::numeric, 2)::numeric AS median_balance
    FROM fintech
    WHERE savings_balance IS NOT NULL
    AND province IS NOT NULL
    GROUP BY province
    ORDER BY avg_balance DESC;



-- Q1a (iii) — Average Savings Balance by Urban/Rural

    SELECT
        urban_rural,
        COUNT(*)                          AS customer_count,
        ROUND(AVG(savings_balance)::numeric, 2)    AS avg_balance,
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY savings_balance )::numeric, 2)::numeric AS median_balance
    FROM fintech
    WHERE savings_balance IS NOT NULL
    AND urban_rural IS NOT NULL
    GROUP BY urban_rural
    ORDER BY avg_balance DESC;



-- Q1b — Age Band Analysis
-- Banding logic (life-stage approach):
--   18-25 : Young adults / first jobbers
--   26-35 : Early career — growing income
--   36-45 : Mid career — peak earning years
--   46-55 : Pre-retirement — consolidating wealth
--   56-65 : Near retirement
--   66+   : Post retirement

    SELECT
        CASE
            WHEN age BETWEEN 18 AND 25 THEN '18-25'
            WHEN age BETWEEN 26 AND 35 THEN '26-35'
            WHEN age BETWEEN 36 AND 45 THEN '36-45'
            WHEN age BETWEEN 46 AND 55 THEN '46-55'
            WHEN age BETWEEN 56 AND 65 THEN '56-65'
            WHEN age > 65              THEN '66+'
            ELSE 'Unknown'
        END                                    AS age_band,
        COUNT(*)                               AS customer_count,
        ROUND(SUM(savings_balance)::numeric, 2)         AS total_savings,
        ROUND(AVG(savings_balance)::numeric, 2)         AS avg_savings_per_customer
    FROM fintech
    WHERE savings_balance IS NOT NULL
    AND age IS NOT NULL
    GROUP BY age_band
    ORDER BY total_savings DESC;



-- Q1c — Growing vs Draining Customers
-- Net flow = monthly_deposit_avg - monthly_withdrawal_avg
-- Positive = customer growing savings each month
-- Negative = customer draining savings each month

    SELECT
        flow_status,
        COUNT(*)                                      AS customer_count,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1)::numeric AS percentage,
        ROUND(AVG(net_flow)::numeric, 2)                       AS avg_net_flow
    FROM (
        SELECT
            customer_id,
            (monthly_deposit_avg - monthly_withdrawal_avg) AS net_flow,
            CASE
                WHEN (monthly_deposit_avg - monthly_withdrawal_avg) > 0 THEN 'Growing'
                WHEN (monthly_deposit_avg - monthly_withdrawal_avg) < 0 THEN 'Draining'
                ELSE 'Neutral'
            END AS flow_status
        FROM fintech
        WHERE monthly_deposit_avg  IS NOT NULL
        AND monthly_withdrawal_avg IS NOT NULL
    ) flow_calc
    GROUP BY flow_status
    ORDER BY customer_count DESC;



-- Q1c (bonus) — Growing vs Draining broken down by Segment

    SELECT
        customer_segment,
        COUNT(*)                                                         AS total_customers,
        SUM(CASE WHEN (monthly_deposit_avg - monthly_withdrawal_avg) > 0 THEN 1 ELSE 0 END) AS growing,
        SUM(CASE WHEN (monthly_deposit_avg - monthly_withdrawal_avg) < 0 THEN 1 ELSE 0 END) AS draining,
        ROUND(
            SUM(CASE WHEN (monthly_deposit_avg - monthly_withdrawal_avg) > 0 THEN 1 ELSE 0 END)
            * 100.0 / COUNT(*), 1
        )::numeric            AS prcnt_growing,
        ROUND(AVG(monthly_deposit_avg - monthly_withdrawal_avg)::numeric, 2)      AS avg_net_flow
    FROM fintech
    WHERE monthly_deposit_avg  IS NOT NULL
    AND monthly_withdrawal_avg IS NOT NULL
    AND customer_segment IS NOT NULL
    GROUP BY customer_segment
    ORDER BY avg_net_flow DESC;
