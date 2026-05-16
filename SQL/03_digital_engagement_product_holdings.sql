
-- Q3: Digital Engagement & Product Holdings


-- Q3a — Do mobile app users maintain higher savings balances?

    SELECT
        mobile_app_user,
        COUNT(*) AS customer_count,
        ROUND(AVG(savings_balance)::numeric, 2)  AS avg_savings_balance,
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY savings_balance)::numeric, 2) AS median_savings_balance,
        ROUND(SUM(savings_balance)::numeric, 2)AS total_savings
    FROM fintech
    WHERE savings_balance IS NOT NULL
    AND mobile_app_user IS NOT NULL
    GROUP BY mobile_app_user
    ORDER BY avg_savings_balance DESC;

-- ============================================================
-- FINDING: Non-app users avg LKR 798,128 vs App users LKR 761,404
-- App users do NOT hold higher balances — counter-intuitive.
-- Possible reason: app users transact more frequently (more
-- withdrawals), or higher-value customers prefer branch service.
-- State this honestly and flag it as an interesting finding.
-- ============================================================



-- Q3b — Cross-sell opportunity
-- Target: customers with savings but NO Fixed Deposit AND NO Insurance
-- Summary count and value

    SELECT
        COUNT(*)AS cross_sell_customer_count,
        ROUND(SUM(savings_balance)::numeric, 2) AS total_savings_held_lkr,
        ROUND(AVG(savings_balance)::numeric, 2) AS avg_savings_per_customer
    FROM fintech
    WHERE savings_balance  IS NOT NULL
    AND has_fixed_deposit = 'No'
    AND has_insurance     = 'No';


    -- Breakdown by Segment (to prioritise who to target first)
    SELECT
        customer_segment,
        COUNT(*)  AS cross_sell_customers,
        ROUND(SUM(savings_balance)::numeric, 2) AS total_savings_lkr,
        ROUND(AVG(savings_balance)::numeric, 2) AS avg_savings
    FROM fintech
    WHERE savings_balance  IS NOT NULL
    AND has_fixed_deposit = 'No'
    AND has_insurance     = 'No'
    AND customer_segment IS NOT NULL
    GROUP BY customer_segment
    ORDER BY total_savings_lkr DESC;


  -- Breakdown by Acquisition Channel (to target via the right channel)
    SELECT
        acquisition_channel,
        COUNT(*) AS cross_sell_customers,
        ROUND(SUM(savings_balance)::numeric, 2) AS total_savings_lkr,
        ROUND(AVG(savings_balance)::numeric, 2) AS avg_savings
    FROM fintech
    WHERE savings_balance  IS NOT NULL
    AND has_fixed_deposit = 'No'
    AND has_insurance     = 'No'
    AND acquisition_channel IS NOT NULL
    GROUP BY acquisition_channel
    ORDER BY total_savings_lkr DESC;

-- ============================================================
-- FINDING: 251 customers (50% of base) have no FD and no Insurance.
-- They collectively hold LKR 222,385,272 in savings.
-- This is a significant untapped cross-sell opportunity.
-- ============================================================



-- Q3c — Best Acquisition Channel: highest savings + lowest default

-- Step 1: Average savings by channel
    SELECT
        acquisition_channel,
        COUNT(*) AS total_customers,
        ROUND(AVG(savings_balance)::numeric, 2) AS avg_savings_balance
    FROM fintech
    WHERE savings_balance IS NOT NULL
    AND acquisition_channel IS NOT NULL
    GROUP BY acquisition_channel
    ORDER BY avg_savings_balance DESC;


-- Step 2: Default rate by channel

    SELECT
        acquisition_channel,
        COUNT(*) AS loan_customers,
        SUM(CASE WHEN loan_repayment_status = 'Defaulted' THEN 1 ELSE 0 END) AS defaulted,
        ROUND(SUM(CASE WHEN loan_repayment_status = 'Defaulted' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1 ) AS default_rate_pct
    FROM fintech
    WHERE has_loan = 'Yes'
    AND loan_repayment_status IS NOT NULL
    AND acquisition_channel IS NOT NULL
    GROUP BY acquisition_channel
    ORDER BY default_rate_pct ASC;


-- Step 3: Combined view — savings and default side by side

    SELECT
        f.acquisition_channel,
        COUNT(*) AS total_customers,
        ROUND(AVG(f.savings_balance)::numeric, 2)AS avg_savings,
        SUM(CASE WHEN f.has_loan = 'Yes' AND f.loan_repayment_status = 'Defaulted' THEN 1 ELSE 0 END) AS defaulted_loans,
        SUM(CASE WHEN f.has_loan = 'Yes' THEN 1 ELSE 0 END)  AS total_loans,
        ROUND(SUM(CASE WHEN f.has_loan = 'Yes' AND f.loan_repayment_status = 'Defaulted' THEN 1 ELSE 0 END)
                * 100.0 / NULLIF(SUM(CASE WHEN f.has_loan = 'Yes' THEN 1 ELSE 0 END), 0), 1)  AS default_rate_pct
    FROM fintech f
    WHERE f.acquisition_channel IS NOT NULL
    GROUP BY f.acquisition_channel
    ORDER BY avg_savings DESC;

-- ============================================================
-- FINDING: Agent channel has the LOWEST default rate (5.4%)
-- but also the LOWEST avg savings (LKR 645,883).
-- Branch channel has the HIGHEST avg savings (LKR 841,984)
-- but a higher default rate (11.8%).
-- BEST OVERALL: Agent — lowest risk, consistent loan repayment.
-- Implication: invest in agent network for quality loan customers,
-- use branch/digital for high-value savings acquisition.
-- ============================================================