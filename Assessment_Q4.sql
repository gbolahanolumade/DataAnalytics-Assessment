-- Step 1: Summarize transaction data per customer
WITH transaction_summary AS (
    SELECT
        sa.owner_id,
        COUNT(*) AS total_transactions,           
        AVG(sa.amount) AS avg_transaction_value,  
        SUM(sa.amount) AS total_transaction_value 
    FROM
        adashi_staging.savings_savingsaccount sa
    GROUP BY
        sa.owner_id
),

-- Step 2: Calculate the tenure (in months) for each customer
user_tenure AS (
    SELECT
        u.id AS customer_id,
        CONCAT(u.first_name, ' ', u.last_name) AS name, 
        TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months 
    FROM
        adashi_staging.users_customuser u
),

-- Step 3: Estimate CLV using the defined formula
clv_estimates AS (
    SELECT
        ut.customer_id,
        ut.name,
        ut.tenure_months,
        ts.total_transactions,
        ROUND(
            (ts.total_transactions / NULLIF(ut.tenure_months, 0)) * 12 * (ts.avg_transaction_value * 0.001),
            2
        ) AS estimated_clv  -- CLV: Yearly profit projection based on historical behavior
    FROM
        user_tenure ut
    JOIN
        transaction_summary ts ON ut.customer_id = ts.owner_id
)

-- Step 4: Return all CLV estimates sorted from highest to lowest
SELECT *
FROM clv_estimates
ORDER BY estimated_clv DESC;
