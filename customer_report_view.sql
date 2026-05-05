-- ============================================================
-- CUSTOMER REPORT VIEW
-- Purpose : Create a consolidated customer-level report view
--           that aggregates transactional data with behavioural
--           metrics including segmentation, age group, order
--           value, monthly spending rate, and recency.
--           Intended for use in dashboards and further analysis.
-- ============================================================

CREATE VIEW gold.report_customers AS
WITH base_query AS (
                         -- Join customer demographics with transactional data
    SELECT s.order_number,
           s.order_date,
           c.customer_key,
           s.product_key,
           c.customer_number,
           s.sales_amount,
           s.quantity,
           CONCAT(c.first_name, ' ', c.last_name)  AS customer_name,
           DATEDIFF(YEAR, c.birthdate, GETDATE())  AS customer_age
    FROM gold.dim_customers c
    LEFT JOIN gold.fact_sales s
        ON s.customer_key = c.customer_key
    WHERE s.order_date IS NOT NULL
),
customer_aggregation AS (
                        -- Aggregate key metrics per customer across all transactions
    SELECT customer_key,
           customer_number,
           customer_name,
           customer_age,
           SUM(sales_amount)                                   AS total_sales,
           SUM(quantity)                                       AS total_quantity,
           COUNT(DISTINCT order_number)                        AS total_orders,
           COUNT(DISTINCT product_key)                         AS total_products,
           DATEDIFF(MONTH, MIN(order_date), MAX(order_date))   AS life_span,
           MAX(order_date)                                     AS last_order
    FROM base_query
    GROUP BY customer_key,
             customer_number,
             customer_name,
             customer_age
)
SELECT customer_key,
       customer_number,
       customer_name,
                        -- Segment customers by tenure and total spend
       CASE
           WHEN life_span >= 12 AND total_sales > 5000 THEN 'VIP'
           WHEN life_span >= 12 AND total_sales <= 5000 THEN 'Regular'
           ELSE 'New'
       END AS customer_segment,
              customer_age,
                        -- Group customers into age bands for demographic analysis
       CASE
           WHEN customer_age < 25             THEN 'Below 25'
           WHEN customer_age BETWEEN 25 AND 50 THEN '25-50'
           ELSE 'Above 50'
       END AS age_group,
              total_sales,
              total_quantity,
              total_orders,
              total_products,
                       -- Average revenue generated per order
       CASE
           WHEN total_orders = 0 THEN 0
           ELSE total_sales / total_orders
       END AS avg_order_value,
                       -- Average monthly spend to measure customer engagement rate
       CASE
           WHEN life_span = 0 THEN total_sales
           ELSE total_sales / life_span
       END AS avg_monthly_spending,
              life_span,
                       -- Months since last purchase — lower value indicates higher engagement
       DATEDIFF(MONTH, last_order, GETDATE()) AS recency
FROM customer_aggregation;