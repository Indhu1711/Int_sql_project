

--DATA CLEANING (coalesece,nullif)

WITH sales_data AS (
SELECT 
     customerkey,
     
     sum(quantity*netprice*exchangerate) AS net_revenue
     FROM sales 
     GROUP BY customerkey 
  )   
   
  SELECT
          avg(s.net_revenue) AS spending_customers_avg_net_rev ,
          avg(COALESCE(s.net_revenue,0)) AS all_customers_avg_net_rev 
  from customer c 
  LEFT JOIN sales_data s ON c.customerkey = s.customerkey;
 
  
  DROP VIEW cohort_analysis;
-- public.cohort_analysis source

--DATA CLEANING ( STRING FORMATTING IN VIEWS)

CREATE VIEW public.cohort_analysis as
WITH customer_revenue AS (
         SELECT s.customerkey,
            s.orderdate,
            sum(s.quantity::double precision * s.netprice * s.exchangerate) AS total_net_revenue,
            count(s.orderkey) AS order_count,
            c.countryfull,
            c.age,
            c.givenname,
            c.surname
           FROM sales s
             LEFT JOIN customer c ON c.customerkey = s.customerkey
          GROUP BY s.customerkey, s.orderdate, c.countryfull, c.age, c.givenname, c.surname
        )
 SELECT customerkey,
    orderdate,
    total_net_revenue,
    order_count,
    countryfull,
    age,
    concat(trim(givenname),' ',trim(surname)) AS cleaned_name,
    min(orderdate) OVER (PARTITION BY customerkey) AS first_purchase_date,
    EXTRACT(year FROM min(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
   FROM customer_revenue cr;




 