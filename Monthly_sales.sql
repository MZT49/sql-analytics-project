-- ============================================================
-- YEARLY & MONTHLY SALES TRENDS
-- Purpose : Track how total sales, customer count, and order
--           quantity evolve across months and years to identify
--           seasonal patterns and growth trends.
-- ============================================================

SELECT YEAR(order_date)                  AS order_year,
       DATENAME(MM, order_date)          AS order_month,
       SUM(sales_amount)                 AS total_sales,
       COUNT(DISTINCT customer_key)      AS total_customers,
       SUM(quantity)                     AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), DATENAME(MM, order_date)
ORDER BY YEAR(order_date), DATENAME(MM, order_date);