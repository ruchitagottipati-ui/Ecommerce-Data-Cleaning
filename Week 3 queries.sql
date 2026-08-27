-- Q1: How many orders fall under each Status?
SELECT Status, COUNT(*) AS order_count
FROM orders
GROUP BY Status
ORDER BY order_count DESC;

-- Q2: Total and average order value by Category
SELECT Category,
       COUNT(*) AS order_count,
       ROUND(SUM(Amount), 2) AS total_amount,
       ROUND(AVG(Amount), 2) AS avg_amount
FROM orders
WHERE Amount > 0
GROUP BY Category
ORDER BY total_amount DESC;

-- Q3: Broader status groups (requires status_lookup table)
SELECT s.status_group, COUNT(*) AS order_count
FROM orders o
JOIN status_lookup s ON o.Status = s.Status
GROUP BY s.status_group
ORDER BY order_count DESC;

-- Q4: Monthly order and revenue trend
SELECT strftime('%Y-%m', Date) AS order_month,
       COUNT(*) AS order_count,
       ROUND(SUM(CASE WHEN Amount > 0 THEN Amount ELSE 0 END), 2) AS total_revenue
FROM orders
GROUP BY order_month
ORDER BY order_month;

-- Q5: Categories priced above the overall average (subquery)
SELECT Category, ROUND(AVG(Amount), 2) AS avg_category_amount
FROM orders
WHERE Amount > 0
GROUP BY Category
HAVING AVG(Amount) > (
    SELECT AVG(Amount) FROM orders WHERE Amount > 0
)
ORDER BY avg_category_amount DESC;

-- Q6: Price tier vs order outcome (requires category_tier table)
SELECT c.price_tier, s.status_group, COUNT(*) AS order_count
FROM orders o
JOIN category_tier c ON o.Category = c.Category
JOIN status_lookup s ON o.Status = s.Status
GROUP BY c.price_tier, s.status_group
ORDER BY c.price_tier, order_count DESC;

-- Q7: Top 5 cities by revenue
SELECT [ship-city] AS city, 
       COUNT(*) AS order_count, 
       ROUND(SUM(Amount), 2) AS total_revenue
FROM orders
WHERE Amount > 0 AND [ship-city] != 'Unknown'
GROUP BY [ship-city]
ORDER BY total_revenue DESC
LIMIT 5;

-- Q8: Orders priced above their own category's average (CTE)
WITH category_avg AS (
    SELECT Category, AVG(Amount) AS avg_amount
    FROM orders
    WHERE Amount > 0
    GROUP BY Category
)
SELECT o.Category, COUNT(*) AS above_avg_orders
FROM orders o
JOIN category_avg c ON o.Category = c.Category
WHERE o.Amount > c.avg_amount AND o.Amount > 0
GROUP BY o.Category
ORDER BY above_avg_orders DESC;

-- Q9: B2B vs regular customer orders
SELECT B2B,
       COUNT(*) AS order_count,
       ROUND(AVG(Amount), 2) AS avg_order_value,
       ROUND(AVG(Qty), 2) AS avg_quantity
FROM orders
WHERE Amount > 0
GROUP BY B2B;

-- Q10: Cancellation rate by category
SELECT o.Category,
       COUNT(*) AS total_orders,
       SUM(CASE WHEN s.status_group = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
       ROUND(100.0 * SUM(CASE WHEN s.status_group = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS cancellation_rate_pct
FROM orders o
JOIN status_lookup s ON o.Status = s.Status
GROUP BY o.Category
ORDER BY cancellation_rate_pct DESC;

     
