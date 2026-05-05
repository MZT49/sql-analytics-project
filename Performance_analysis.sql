-- ============================================================
-- PRODUCT YEARLY PERFORMANCE ANALYSIS
-- Purpose : Evaluate each product's annual sales against its
--           historical average and prior year to identify
--           growth, decline, and consistently high performers.
-- ============================================================

WITH yearly_sales AS (
    SELECT YEAR(fs.order_date)  AS order_year,
           dp.product_name,
           SUM(fs.price)        AS current_sales
    FROM gold.fact_sales fs
    LEFT JOIN gold.dim_products dp
        ON fs.product_key = dp.product_key
    WHERE fs.order_date IS NOT NULL
    GROUP BY YEAR(fs.order_date), dp.product_name
)
SELECT order_year,
       product_name,
       current_sales,
                              -- Average sales across all years for each product
       AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
                              -- Deviation from the product's historical average
       current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS sales_diff,
                              -- Classify performance relative to the product's average
       CASE
           WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
           WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
           ELSE 'Avg'
       END AS avg_change,
                              -- Prior year sales for year-over-year comparison
       LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS prev_year_sales,
                              -- Absolute change vs prior year
       current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS prev_sales_diff,
                              -- Classify year-over-year trend
       CASE
           WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
           WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
           ELSE 'No Change'
       END AS yoy_change
FROM yearly_sales
ORDER BY product_name, order_year ASC;