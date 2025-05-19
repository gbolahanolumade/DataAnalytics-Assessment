SELECT
    cu.id AS owner_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS name,

    COUNT(DISTINCT CASE 
        WHEN p.is_regular_savings = 1 THEN p.id 
    END) AS savings_count,


    COUNT(DISTINCT CASE 
        WHEN p.is_fixed_investment = 1 THEN p.id 
    END) AS investment_count,

    SUM(sa.confirmed_amount) AS total_deposits
FROM
    adashi_staging.users_customuser cu
JOIN
    adashi_staging.plans_plan p 
    ON cu.id = p.owner_id

JOIN
    adashi_staging.savings_savingsaccount sa 
    ON p.owner_id = sa.owner_id

WHERE
    sa.confirmed_amount > 0

GROUP BY
    cu.id, name

HAVING
    savings_count > 0 AND investment_count > 0

ORDER BY
    total_deposits DESC;
