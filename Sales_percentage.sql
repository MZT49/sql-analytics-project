-- ============================================================
-- SALES CONTRIBUTION BY CATEGORY
-- Purpose : Determine each product category's share of total
--           revenue to support strategic investment and
--           resource allocation decisions.
-- ============================================================

WITH category_sales AS (
    SELECT dp.category,
           SUM(fs.sales_amount) AS total_sales
    FROM gold.fact_sales fs
    LEFT JOIN gold.dim_products dp
        ON fs.product_key = dp.product_key
    GROUP BY dp.category
)
SELECT category,
       total_sales,
       CONCAT(
           ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER()) * 100, 2),
           '%'
       ) AS percentage_of_total_sales
FROM category_sales
GROUP BY category, total_sales;