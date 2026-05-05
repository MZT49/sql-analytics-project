-- ============================================================
-- CUMULATIVE SALES (RUNNING TOTAL)
-- Purpose : Calculate the month-over-month cumulative sales
--           within each year to monitor progress toward
--           annual revenue targets.
-- ============================================================

SELECT order_month,
       total_sales,
       SUM(total_sales) OVER (
           PARTITION BY YEAR(order_month)
           ORDER BY order_month
       ) AS running_total
FROM (
    SELECT DATETRUNC(MONTH, order_date) AS order_month,
           SUM(sales_amount)            AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH, order_date)
) OT;