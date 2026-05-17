
-- FinSight Lanka Assessment — Q4: KPI Definitions



-- KPI 1 — Loan Default Rate                    [AREA: Risk]

-- Definition : % of loan customers who have defaulted
-- Formula    : (Defaulted Loans / Total Loans) x 100
-- Current Value: 11.4%
-- Target/Benchmark: Keep below 8% (industry standard for fintech)
-- Business Reason: High default rate directly impacts profitability
--                  and signals poor credit risk management.
--                  Starter + Vehicle loan combination is the
--                  key driver at 17.1% — needs immediate action.

SELECT
    ROUND(
        SUM(CASE WHEN loan_repayment_status = 'Defaulted' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 1
    ) AS loan_default_rate_pct
FROM fintech
WHERE has_loan = 'Yes'
  AND loan_repayment_status IS NOT NULL;



-- KPI 2 — High Risk Exposure (DSR > 1.0)       [AREA: Risk]

-- Definition : % of loan customers whose outstanding loan
--              balance exceeds their savings balance
-- Formula    : (Customers with DSR > 1.0 / Total Loan Customers) x 100
-- Current Value: 59.4% — LKR 130,101,268 total exposure
-- Target/Benchmark: Keep below 40%
-- Business Reason: Over-leveraged customers cannot self-rescue
--                  during economic shocks — direct credit risk.

    SELECT
        ROUND(
            SUM(CASE WHEN outstanding_loan_balance / savings_balance > 1.0
                    THEN 1 ELSE 0 END)::numeric * 100.0 / COUNT(*), 1
        ) AS high_risk_exposure_pct,
        ROUND(
            SUM(CASE WHEN outstanding_loan_balance / savings_balance > 1.0
                    THEN outstanding_loan_balance ELSE 0 END)::numeric, 0
        ) AS total_lkr_exposure
    FROM fintech
    WHERE has_loan = 'Yes'
    AND outstanding_loan_balance IS NOT NULL
    AND savings_balance IS NOT NULL
    AND savings_balance > 0;



-- KPI 3 — Cross-Sell Penetration Rate          [AREA: Growth]

-- Definition : % of customers who hold BOTH a Fixed Deposit
--              AND Insurance (fully cross-sold)
-- Formula    : (Customers with FD AND Insurance / Total Customers) x 100
-- Current Value: Calculate below
-- Target/Benchmark: Grow to 35% within 12 months
-- Business Reason: 251 customers (50% of base) hold neither FD
--                  nor Insurance — massive untapped revenue opportunity
--                  worth LKR 222 million in reachable savings.

    SELECT
        COUNT(*)                                                        AS total_customers,
        SUM(CASE WHEN has_fixed_deposit = 'Yes'
                AND has_insurance = 'Yes' THEN 1 ELSE 0 END)         AS fully_cross_sold,
        ROUND(
            SUM(CASE WHEN has_fixed_deposit = 'Yes'
                    AND has_insurance = 'Yes' THEN 1 ELSE 0 END)
            * 100.0 / COUNT(*), 1
        )                                                               AS cross_sell_penetration_pct
    FROM fintech;



-- KPI 4 — Mobile App Adoption Rate           [AREA: Engagement]

-- Definition : % of active customers using the mobile app
-- Formula    : (Mobile App Users / Total Active Customers) x 100
-- Current Value: Calculate below
-- Target/Benchmark: Grow to 75% (digital-first strategy)
-- Business Reason: App adoption drives lower servicing costs and
--                  higher transaction frequency. Currently
--                  non-app users hold slightly higher balances
--                  (LKR 798K vs LKR 761K) — closing this gap
--                  through app engagement is a key growth lever.

    SELECT
        COUNT(*)                                                        AS active_customers,
        SUM(CASE WHEN mobile_app_user = 'Yes' THEN 1 ELSE 0 END)       AS app_users,
        ROUND(
            SUM(CASE WHEN mobile_app_user = 'Yes' THEN 1 ELSE 0 END)
            * 100.0 / COUNT(*), 1
        )                                                               AS app_adoption_rate_pct
    FROM fintech
    WHERE account_status = 'Active';



-- KPI 5 — Average Savings Balance per Customer [AREA: Growth]

-- Definition : Average savings balance held per active customer
-- Formula    : Total Savings Balance / Number of Active Customers
-- Current Value: Calculate below
-- Target/Benchmark: Grow by 10% year-on-year
-- Business Reason: Core measure of deposit health. Premium segment
--                  drives this metric disproportionately (LKR 2.65M avg)
--                  so retaining Premium customers is critical to
--                  maintaining a healthy overall average.

    SELECT
        COUNT(*)                                                        AS active_customers,
        ROUND(AVG(savings_balance)::numeric, 2)                         AS avg_savings_per_customer,
        ROUND(SUM(savings_balance)::numeric, 2)                         AS total_deposits
    FROM fintech
    WHERE account_status = 'Active'
    AND savings_balance IS NOT NULL;


