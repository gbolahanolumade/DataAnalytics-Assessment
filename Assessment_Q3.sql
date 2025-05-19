-- Step 1: Get the most recent transaction date for each plan
WITH last_transactions AS (
    SELECT
        sa.plan_id,
        MAX(sa.transaction_date) AS last_transaction_date  -- Latest transaction per plan
    FROM
        adashi_staging.savings_savingsaccount sa
    GROUP BY
        sa.plan_id
),

-- Step 2: Get all active plans and classify their type
active_plans AS (
    SELECT
        p.id AS plan_id,         
        p.owner_id,              
        CASE 
            WHEN p.plan_type_id = 1 THEN 'Savings'       
            WHEN p.plan_type_id = 2 THEN 'Investment'    
            ELSE 'Other'                                 
        END AS type,
        p.status_id              
    FROM
        plans_plan p
    WHERE
        p.status_id = 1          
)

-- Step 3: Join the active plans with their last transaction data and find inactive ones
SELECT
    ap.plan_id,
    ap.owner_id,
    ap.type,
    lt.last_transaction_date,
    DATEDIFF(CURDATE(), lt.last_transaction_date) AS inactivity_days  
FROM
    active_plans ap
LEFT JOIN
    last_transactions lt ON ap.plan_id = lt.plan_id 
WHERE
    lt.last_transaction_date IS NULL                 
    OR DATEDIFF(CURDATE(), lt.last_transaction_date) > 365  
ORDER BY
    inactivity_days DESC;  
