--  customer level transaction statistics
WITH customer_txns AS (
    SELECT 
        u.id AS customer_id,
        u.name,
        TIMESTAMPDIFF(MONTH, u.date_joined, NOW()) AS tenure_months,  -- months since the user joined
        COUNT(s.id) AS total_transactions,                             -- total number of successful transactions
        SUM(s.confirmed_amount) / 100 AS total_transaction_value_naira, -- sum of confirmed transaction I converted from kobo to naira ( 😒 not sure i should have)
        AVG(s.confirmed_amount) / 100 AS avg_transaction_value_naira   -- average transaction amount I converted to naira( 😒 not sure i should have)
    FROM users_customuser u
    JOIN savings_savingsaccount s ON u.id = s.owner_id
    WHERE s.transaction_status = 'successful'  -- to only consider successful transactions
      AND s.confirmed_amount > 0              -- ignore failed or zero-amount transactions
    GROUP BY u.id, u.name, u.date_joined
),

-- Customer Lifetime Value (CLV)
clv_calc AS (
    SELECT 
        customer_id,
        name,
        tenure_months,
        total_transactions,
        ROUND(
            (total_transactions / tenure_months) * 12 * (avg_transaction_value_naira * 0.001),  -- annualized value 
            2
        ) AS estimated_clv
    FROM customer_txns
    WHERE tenure_months >= 1  -- REMOVED very new users to avoid division by zero
)

-- output ordered by highest CLV
SELECT 
    customer_id,
    name,
    tenure_months,
    total_transactions,
    estimated_clv
FROM clv_calc
ORDER BY estimated_clv DESC;
