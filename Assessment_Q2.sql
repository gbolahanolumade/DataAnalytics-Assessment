-- Step 1: Calculate the number of transactions each user makes per month
WITH monthly_transactions AS (
    SELECT
        sa.owner_id,  
        DATE_FORMAT(sa.transaction_date, '%Y-%m') AS month,  
        COUNT(*) AS transactions_in_month  
    FROM
        adashi_staging.savings_savingsaccount sa
    GROUP BY
        sa.owner_id,
        DATE_FORMAT(sa.transaction_date, '%Y-%m')  -- Grouping by user and month
),

-- Step 2: Compute the average number of transactions per month for each user
average_transactions_per_user AS (
    SELECT
        owner_id,
        AVG(transactions_in_month) AS avg_tx_per_month  
    FROM
        monthly_transactions
    GROUP BY
        owner_id
),

-- Step 3: Categorize users into frequency groups based on their average monthly transactions
categorized_users AS (
    SELECT
        owner_id,
        avg_tx_per_month,
        CASE
            WHEN avg_tx_per_month >= 10 THEN 'High Frequency'  
            WHEN avg_tx_per_month >= 3 THEN 'Medium Frequency' 
            ELSE 'Low Frequency'                               
        END AS frequency_category
    FROM
        average_transactions_per_user
)

-- Step 4: Aggregate users by category and calculate average monthly transactions for each category
SELECT
    frequency_category,  
    COUNT(*) AS customer_count,  
    ROUND(AVG(avg_tx_per_month), 1) AS avg_transactions_per_month  
FROM
    categorized_users
GROUP BY
    frequency_category
ORDER BY
  
    FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');
