SELECT
    u.id AS owner_id,
    u.name, 
    COUNT(DISTINCT s.id) AS savings_count,
    COUNT(DISTINCT p.id) AS investment_count,
    SUM(COALESCE(s.amount, 0) + COALESCE(p.amount, 0)) AS total_deposits
FROM
    users_customuser u
    -- Joined investment plans on user ID
JOIN savings_savingsaccount s ON u.id = s.owner_id AND s.amount > 0
JOIN plans_plan p ON u.id = p.owner_id 
                  AND p.is_a_fund = TRUE 
                  AND p.is_deleted = FALSE 
                  AND p.is_archived = FALSE 
                  AND p.amount > 0
    -- Only included investment plans with a positive amount 
       -- also Grouped results by user ID and name
GROUP BY
    u.id, u.name
ORDER BY
    total_deposits DESC;