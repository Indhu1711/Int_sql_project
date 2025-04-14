SELECT 
     cohort_year,
     count(DISTINCT customerkey) AS total_customers,
     sum(total_net_revenue) AS total_revenue,
     sum(total_net_revenue)/count(DISTINCT customerkey) AS customer_revenue
FROM cohort_analysis
WHERE orderdate = first_purchase_date 
GROUP BY cohort_year ;


--CUSTOMER SEGMENTATION
---Who are our most valuable customers?
---statistics of segmented customers


WITH customer_ltv AS (
SELECT 
     customerkey,
     cleaned_name,
     sum(total_net_revenue ) AS total_ltv
     FROM cohort_analysis
     GROUP BY customerkey, cleaned_name  
     ), 
     
     customer_segments AS (
     SELECT 
          PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_ltv) AS ltv_25th_percentile,
          PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_ltv) AS ltv_75th_percentile
          FROM customer_ltv 
), segment_values AS (

SELECT 
     c.*,
     CASE
     	WHEN c.total_ltv < cs.ltv_25th_percentile  THEN '1-Low value'
     	WHEN c.total_ltv <= cs.ltv_75th_percentile  THEN '2-Mid value'
     	ELSE '3-High value'
     END AS customer_segment
     FROM customer_ltv c,
     customer_segments cs
)

SELECT 
      customer_segment,
      sum(total_ltv) AS total_ltv,
      count(customerkey)   AS customer_count,
      sum(total_ltv) / count(customerkey) AS avg_ltv
      FROM segment_values
      GROUP BY customer_segment
      ORDER BY customer_segment DESC;