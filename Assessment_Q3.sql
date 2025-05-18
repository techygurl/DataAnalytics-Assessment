-- Combined the last transaction date for both Savings and Investment accounts
WITH all_transactions AS (
    -- last transaction date for savings from savings_savingsaccount table
    SELECT 
        plan_id,
        owner_id,
        MAX(transaction_date) AS last_transaction_date,
        'Savings' AS type
    FROM savings_savingsaccount
    GROUP BY plan_id, owner_id

    UNION ALL

    -- transaction date for investments using various date fields in plans_plan
    SELECT 
        id AS plan_id,
        owner_id,
        GREATEST(
            COALESCE(last_returns_date, '1900-01-01'),
            COALESCE(last_charge_date, '1900-01-01'),
            COALESCE(withdrawal_date, '1900-01-01'),
            COALESCE(start_date, '1900-01-01')
        ) AS last_transaction_date,
        'Investment' AS type
    FROM plans_plan
    WHERE is_deleted = FALSE AND is_archived = FALSE
),

-- accounts with no transactions in the last 365 days
inactive_accounts AS (
    SELECT
        plan_id,
        owner_id,
        type,
        last_transaction_date,
        DATEDIFF(CURDATE(), last_transaction_date) AS inactivity_days
    FROM all_transactions
    WHERE last_transaction_date < CURDATE() - INTERVAL 365 DAY
)

-- list of inactive accounts, sorted by how long they've been inactive
SELECT *
FROM inactive_accounts
ORDER BY inactivity_days DESC;
