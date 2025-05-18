-- total transactions and active months per user
WITH user_transactions AS (
    SELECT 
        owner_id AS user_id,
        COUNT(*) AS total_transactions,
        COUNT(DISTINCT DATE_FORMAT(transaction_date, '%Y-%m')) AS active_months  -- counting distinct year-months to get active months
    FROM savings_savingsaccount
    GROUP BY owner_id
),
-- average transactions per active month
user_avg_txn_per_month AS (
    SELECT 
        user_id,
        CASE 
            WHEN active_months = 0 THEN 0
            ELSE total_transactions / active_months  
        END AS avg_txn_per_month
    FROM user_transactions
),

--  Categorized users based on their average transaction frequency
categorized_users AS (
    SELECT 
        CASE 
            WHEN avg_txn_per_month >= 10 THEN 'High Frequency'
            WHEN avg_txn_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        avg_txn_per_month
    FROM user_avg_txn_per_month
)

-- total users per category and their average transaction rate
SELECT 
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_txn_per_month), 1) AS avg_transactions_per_month
FROM categorized_users
GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency'); --  category order


