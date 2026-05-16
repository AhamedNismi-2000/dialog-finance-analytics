
 — Q2: Loan Portfolio & Risk

-- Q2a (i) — Overall Loan Penetration Rate

    SELECT
        COUNT(*)     AS total_customers,
        SUM(CASE WHEN has_loan = 'Yes' THEN 1 ELSE 0 END) AS customers_with_loan,
        ROUND(SUM(CASE WHEN has_loan = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1 ) AS penetration_rate_pct
    FROM fintech
    WHERE has_loan IS NOT NULL;
  -- ============================================================
-- Q2a (i) — Overall Loan Penetration Rate


-- FINDING:
-- Overall loan penetration is 43.6% — nearly half the customer
-- base holds a loan, which is relatively high for a fintech.



-- Q2a (ii) — Loan Penetration by Customer Segment

    SELECT
        customer_segment,
        COUNT(*)   AS total_customers,
        SUM(CASE WHEN has_loan = 'Yes' THEN 1 ELSE 0 END)  AS customers_with_loan,
        ROUND(SUM(CASE WHEN has_loan = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1 ) AS penetration_rate_pct
    FROM fintech
    WHERE has_loan IS NOT NULL
    AND customer_segment IS NOT NULL
    GROUP BY customer_segment
    ORDER BY penetration_rate_pct DESC;

  -- ============================================================
-- Q2a (ii) — Loan Penetration by Customer Segment


-- FINDING:
-- Premium (45.1%) and Regular (44.7%) have similar penetration.
-- Starter has the lowest at 38.5% — an opportunity to grow
-- loan uptake among entry-level customers with appropriate
-- risk controls given their higher default rate (see Q2c).



-- Q2a (iii) — Loan Penetration by Acquisition Channel

    SELECT
        acquisition_channel,
        COUNT(*) AS total_customers,
        SUM(CASE WHEN has_loan = 'Yes' THEN 1 ELSE 0 END) AS customers_with_loan,
        ROUND( SUM(CASE WHEN has_loan = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1 )  AS penetration_rate_pct
    FROM fintech
    WHERE has_loan IS NOT NULL
    AND acquisition_channel IS NOT NULL
    GROUP BY acquisition_channel
    ORDER BY penetration_rate_pct DESC;
 -- ============================================================
-- Q2a (iii) — Loan Penetration by Acquisition Channel


-- FINDING:
-- Agent channel has the highest penetration at 47.9%,
-- suggesting agents are the most effective at cross-selling loans.
-- Digital channel is lowest at 41.2% — digital customers
-- may be more self-directed and less receptive to loan offers.
   



    -- Q2b  — Debt-to-Savings Ratio (DSR)
    -- Formula: Outstanding_Loan_Balance / Savings_Balance
    -- DSR > 1.0 means the customer owes more than they have saved
    -- Summary: how many exceed 1.0 and total LKR exposure

    SELECT
        COUNT(*)  AS loan_customers_with_valid_dsr,
        SUM(CASE WHEN outstanding_loan_balance / savings_balance > 1.0 THEN 1 ELSE 0 END)  AS customers_exceeding_1,
        ROUND(SUM(CASE WHEN outstanding_loan_balance / savings_balance > 1.0 THEN 1 ELSE 0 END)::numeric * 100.0 / COUNT(*),1)AS pct_exceeding_1,
        ROUND(SUM(CASE WHEN outstanding_loan_balance / savings_balance > 1.0 THEN outstanding_loan_balance ELSE 0 END)::numeric,2 ) AS total_lkr_exposure
    FROM fintech
    WHERE has_loan = 'Yes'
    AND outstanding_loan_balance IS NOT NULL
    AND savings_balance IS NOT NULL
    AND savings_balance > 0;
  
  -- ============================================================
-- Q2b — Debt-to-Savings Ratio (DSR) — Summary


-- FINDING:
-- 126 out of 212 loan customers (59.4%) exceed a DSR of 1.0,
-- meaning they owe MORE than they have saved.
-- Total LKR exposure from these high-risk customers: LKR 130,101,268.
-- More than half of loan customers are technically over-leveraged.
-- Business implication: if a significant economic shock occurs,
-- these customers cannot cover their loan obligations from savings
-- alone, representing direct credit risk to FinSight Lanka.



-- Detail: individual DSR per customer (high risk first)

    SELECT
        customer_id,
        customer_segment,
        district,
        loan_type,
        savings_balance,
        outstanding_loan_balance,
        ROUND((outstanding_loan_balance / savings_balance)::numeric ,2) AS debt_to_savings_ratio,
        CASE
            WHEN outstanding_loan_balance / savings_balance > 2.0 THEN 'Critical'
            WHEN outstanding_loan_balance / savings_balance > 1.0 THEN 'High Risk'
            ELSE 'Acceptable'
        END  AS risk_flag
    FROM fintech
    WHERE has_loan = 'Yes'
    AND outstanding_loan_balance IS NOT NULL
    AND savings_balance IS NOT NULL
    AND savings_balance > 0
    ORDER BY debt_to_savings_ratio DESC;



-- Q2c (i) — Default Rate by Customer Segment

    SELECT
        customer_segment,
        COUNT(*)                                                        AS total_loan_customers,
        SUM(CASE WHEN loan_repayment_status = 'Defaulted' THEN 1 ELSE 0 END)  AS defaulted,
        SUM(CASE WHEN loan_repayment_status = 'Delayed'   THEN 1 ELSE 0 END)  AS delayed,
        SUM(CASE WHEN loan_repayment_status = 'On-Time'   THEN 1 ELSE 0 END)  AS on_time,
        ROUND(SUM(CASE WHEN loan_repayment_status = 'Defaulted' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),1 ) AS default_rate_pct
    FROM fintech
    WHERE has_loan = 'Yes'
    AND loan_repayment_status IS NOT NULL
    AND customer_segment IS NOT NULL
    GROUP BY customer_segment
    ORDER BY default_rate_pct DESC;

 -- ============================================================
-- Q2c (i) — Default Rate by Customer Segment


-- FINDING:
-- Starter segment defaults at 17.1% — more than double
-- the Premium rate (9.8%) and double Regular (8.6%).
-- Starter customers are the highest credit risk group.   



-- Q2c (ii) — Default Rate by Loan Type

    SELECT
        loan_type,
        COUNT(*) AS total_loans,
        SUM(CASE WHEN loan_repayment_status = 'Defaulted' THEN 1 ELSE 0 END)  AS defaulted,
        ROUND(SUM(CASE WHEN loan_repayment_status = 'Defaulted' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1)  AS default_rate_pct
    FROM fintech
    WHERE has_loan = 'Yes'
    AND loan_repayment_status IS NOT NULL
    AND loan_type IS NOT NULL
    GROUP BY loan_type
    ORDER BY default_rate_pct DESC;

 -- ============================================================
-- Q2c (ii) — Default Rate by Loan Type


-- FINDING:
-- Vehicle loans have the highest default rate at 16.0%,
-- followed by Housing at 11.5%.
-- Business loans are the safest at 6.8%.  


    -- Q2c (iii) — Default Rate by District

    SELECT
        district,
        COUNT(*) AS total_loans,
        SUM(CASE WHEN loan_repayment_status = 'Defaulted' THEN 1 ELSE 0 END)  AS defaulted,
        ROUND( SUM(CASE WHEN loan_repayment_status = 'Defaulted' THEN 1 ELSE 0 END)* 100.0 / COUNT(*), 1) AS default_rate_pct
    FROM fintech
    WHERE has_loan = 'Yes'
    AND loan_repayment_status IS NOT NULL
    AND district IS NOT NULL
    GROUP BY district
    ORDER BY default_rate_pct DESC;

  -- ============================================================
-- Q2c (iii) — Default Rate by District

-- FINDING:
-- Kurunegala (16.7%) and Ratnapura (14.8%) are the highest
-- risk districts. Colombo and Gampaha also show elevated rates
-- despite being urban centres.
-- Jaffna and Badulla have the lowest default rates (4.5%).  



    -- Q2c (iv) — High Risk Combinations (Segment + Loan Type)
    -- Flags combinations with default rate above overall average

    SELECT
        customer_segment,
        loan_type,
        COUNT(*) AS total_loans,
        SUM(CASE WHEN loan_repayment_status = 'Defaulted' THEN 1 ELSE 0 END) AS defaulted,
        ROUND( SUM(CASE WHEN loan_repayment_status = 'Defaulted' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),1) AS default_rate_pct,
        CASE
        WHEN SUM(CASE WHEN loan_repayment_status = 'Defaulted' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) > 10 THEN 'Elevated Risk'
            ELSE 'Normal'
             END  AS risk_flag
    FROM fintech
    WHERE has_loan = 'Yes'
    AND loan_repayment_status IS NOT NULL
    AND customer_segment IS NOT NULL
    AND loan_type IS NOT NULL
    GROUP BY customer_segment, loan_type
    ORDER BY default_rate_pct DESC;

-- ============================================================
-- Q2c (iv) — High Risk Combinations (Segment + Loan Type)

-- FINDING:
-- Starter segment + Vehicle loans represents the highest
-- concentration of risk — both are individually elevated
-- and together they warrant immediate attention.
-- Recommendation: tighten lending criteria for Vehicle loans
-- issued to Starter segment customers.