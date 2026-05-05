-- ============================================================
-- CUSTOMER SEGMENTATION
-- Purpose : Classify customers into VIP, Regular, and New
--           segments based on purchase history and tenure
--           to enable targeted retention and marketing strategies.
-- ============================================================

WITH customer_spending AS (
    SELECT c.customer_key,
           SUM(s.sales_amount)                               AS total_spending,
           DATEDIFF(MONTH, MIN(s.order_date), MAX(s.order_date)) AS life_span
    FROM gold.dim_customers c
    LEFT JOIN gold.fact_sales s
        ON c.customer_key = s.customer_key
    GROUP BY c.customer_key
),
customer_segment AS (
    SELECT customer_key,
           CASE
               WHEN life_span >= 12 AND total_spending > 5000 THEN 'VIP'
               WHEN life_span >= 12 AND total_spending <= 5000 THEN 'Regular'
               ELSE 'New'
           END AS customer_segment
    FROM customer_spending
)
SELECT customer_segment,
       COUNT(customer_key) AS total_customers
FROM customer_segment
GROUP BY customer_segment
ORDER BY COUNT(customer_key) DESC;