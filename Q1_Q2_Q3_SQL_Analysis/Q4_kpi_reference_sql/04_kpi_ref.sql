
-- Q4: KPI Definitions


-- ============================================================
-- KPI 1 — Loan Default Rate                    [AREA: Risk]

-- Definition : % of loan customers who have defaulted
-- Formula    : (Defaulted Loans / Total Loan Customers) x 100
-- Current Value: 10.55% (verified in Power BI)
-- Target/Benchmark: Keep below 8% (industry standard for fintech)
-- Business Reason: High default rate directly impacts profitability
--                  and signals poor credit risk management.
--                  Starter + Vehicle loan combination is the
--                  key driver at 17.1% — needs immediate action.

    SELECT
        ROUND(
            SUM(CASE WHEN loan_repayment_status = 'Defaulted' THEN 1 ELSE 0 END)
            * 100.0 / COUNT(*), 2
        ) AS loan_default_rate_pct
    FROM fintech
    WHERE has_loan = 'Yes'
    AND loan_repayment_status IS NOT NULL;

-- FINDING:
-- Current default rate of 10.55% exceeds the 8% target.
-- Starter segment is the primary driver at 17.1% default rate.
-- Immediate action required on Starter + Vehicle loan combination.


-- ============================================================
-- KPI 2 — High Risk Exposure (DSR > 1.0)       [AREA: Risk]

-- Definition : % of loan customers whose outstanding loan
--              balance exceeds their savings balance
-- Formula    : (Customers with DSR > 1.0 / Total Loan Customers) x 100
-- Current Value: 59.63% — LKR 130,101,268 total exposure
-- Target/Benchmark: Keep below 40%
-- Business Reason: Over-leveraged customers cannot self-rescue
--                  during economic shocks — direct credit risk
--                  to FinSight Lanka's loan portfolio.

    SELECT
        ROUND(
            SUM(CASE WHEN outstanding_loan_balance / savings_balance > 1.0
                    THEN 1 ELSE 0 END)::numeric * 100.0 / COUNT(*), 2
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

-- FINDING:
-- 59.63% of loan customers owe more than they have saved.
-- Total LKR exposure: LKR 130,101,268.
-- This is nearly 20 percentage points above the 40% target —
-- a critical risk that requires immediate portfolio review.




-- ============================================================
-- KPI 3 — Cross-Sell Penetration Rate          [AREA: Growth]

-- Definition : % of ACTIVE customers who hold BOTH a Fixed
--              Deposit AND Insurance (fully cross-sold)
-- Formula    : (Active customers with FD AND Insurance /
--               Total Active Customers) x 100
-- Current Value: 6.37% (Active customers only — verified in Power BI)
-- Target/Benchmark: Grow to 35% within 12 months
-- Business Reason: 251 customers (50% of base) hold neither FD
--                  nor Insurance — massive untapped revenue
--                  opportunity worth LKR 222M in reachable savings.
-- Note: Denominator uses Active customers only to match DAX measure.
--       This aligns with business reality — inactive customers
--       are not being marketed to.

    SELECT
        COUNT(*) AS active_customers,
        SUM(CASE WHEN has_fixed_deposit = 'Yes'
                AND has_insurance = 'Yes' THEN 1 ELSE 0 END)  AS fully_cross_sold,
        ROUND(
            SUM(CASE WHEN has_fixed_deposit = 'Yes'
                    AND has_insurance = 'Yes' THEN 1 ELSE 0 END)
            * 100.0 / COUNT(*), 2
        ) AS cross_sell_penetration_pct
    FROM fintech
    WHERE account_status = 'Active';

-- FINDING:
-- Only 6.37% of active customers hold both FD and Insurance.
-- Gap to target (35%) represents a significant growth opportunity.
-- Priority: target the 251 savings-only customers holding LKR 222M.




-- ============================================================
-- KPI 4 — Mobile App Adoption Rate         [AREA: Engagement]

-- Definition : % of active customers using the mobile app
-- Formula    : (Active Mobile App Users / Total Active Customers) x 100
-- Current Value: 66.31% (verified in Power BI)
-- Target/Benchmark: Grow to 75% (digital-first strategy)
-- Business Reason: App adoption drives lower servicing costs and
--                  higher transaction frequency. Currently
--                  non-app users hold slightly higher balances
--                  (LKR 798K vs LKR 761K) — closing this gap
--                  through app engagement is a key growth lever.

    SELECT
        COUNT(*)  AS active_customers,
        SUM(CASE WHEN mobile_app_user = 'Yes' THEN 1 ELSE 0 END) AS app_users,
        ROUND(
            SUM(CASE WHEN mobile_app_user = 'Yes' THEN 1 ELSE 0 END)
            * 100.0 / COUNT(*), 2
        )  AS app_adoption_rate_pct
    FROM fintech
    WHERE account_status = 'Active';

-- FINDING:
-- 66.31% adoption is below the 75% target.
-- Approximately 128 active customers are not yet using the app.
-- Digital onboarding campaign targeting these customers
-- could close the gap within 6 months.


-- ============================================================
-- KPI 5 — Average Savings Balance per Customer [AREA: Growth]
-- ============================================================
-- Definition : Average savings balance held per active customer
-- Formula    : Total Savings Balance / Number of Active Customers
-- Current Value: LKR 728,660 (verified in Power BI)
-- Target/Benchmark: Grow by 10% year-on-year (target: LKR 801,526)
-- Business Reason: Core measure of deposit health. Premium segment
--                  drives this metric disproportionately (LKR 2.65M avg)
--                  so retaining Premium customers is critical to
--                  maintaining a healthy overall average.

    SELECT
        COUNT(*) AS active_customers,
        ROUND(AVG(savings_balance)::numeric, 2) AS avg_savings_per_customer,
        ROUND(SUM(savings_balance)::numeric, 2) AS total_deposits
    FROM fintech
    WHERE account_status = 'Active'
    AND savings_balance IS NOT NULL;

-- FINDING:
-- Average active customer holds LKR 728,660 in savings.
-- 10% YoY growth target = LKR 801,526 by next year.
-- Key lever: retain Premium customers (avg LKR 2.65M)
-- and convert cross-sell pool to deepen product holdings.


-- ============================================================
-- KPI SUMMARY TABLE

-- KPI 1 : Loan Default Rate          — 10.55%      target < 8%
-- KPI 2 : High Risk Exposure (DSR)   — 59.63%      target < 40%
-- KPI 3 : Cross-Sell Penetration     — 6.37%       target > 35%
-- KPI 4 : Mobile App Adoption        — 66.31%      target > 75%
-- KPI 5 : Avg Savings per Customer   — LKR 728,660 target +10% YoY
--

--   Risk       : KPI 1 + KPI 2
--   Growth     : KPI 3 + KPI 5
--   Engagement : KPI 4
