SELECT * FROM customers_dataset
SELECT customer_id, customer_unique_id, COUNT(*)
FROM customers_dataset
GROUP BY customer_id, customer_unique_id
HAVING COUNT(*) > 1

SELECT * FROM geolocation_dataset
SELECT zip_code_prefix, geolocation_state, COUNT(*)
FROM geolocation_dataset
GROUP BY zip_code_prefix, geolocation_state
HAVING COUNT(*) > 1

SELECT * FROM order_items_dataset
SELECT order_id, product_id, COUNT(*)
FROM order_items_dataset
GROUP BY order_id, product_id
HAVING COUNT(*) > 1

SELECT * FROM order_items_dataset

SELECT * FROM order_reviews_dataset
SELECT review_id, order_id, COUNT(*)
FROM order_reviews_dataset
GROUP BY review_id, order_id
HAVING COUNT(*) > 1

SELECT * FROM orders_dataset
SELECT order_id, customer_id, COUNT(*)
FROM orders_dataset
GROUP BY order_id, customer_id
HAVING COUNT(*) > 1

SELECT * FROM product_dataset
SELECT product_id, product_category_name, COUNT(*)
FROM product_dataset
GROUP BY product_id, product_category_name
HAVING COUNT(*) > 1

SELECT * FROM sellers_dataset
SELECT seller_id, zip_code_prefix, COUNT(*)
FROM sellers_dataset
GROUP BY seller_id, zip_code_prefix
HAVING COUNT(*) > 1

-- NO.1 --
WITH mau AS
(
	SELECT date_part('year', order_purchase_timestamp) AS year,
		   COUNT(DISTINCT customer_unique_id) AS num_customer
	FROM orders_dataset AS od
	JOIN customers_dataset AS cd ON od.customer_id = cd.customer_id 
	GROUP BY 1
)
SELECT * FROM mau
ORDER BY year

-- JAWABAN GOOGLE --
SELECT YEAR(order_purchase_timestamp) AS year,
       COUNT(DISTINCT customer_unique_id) AS num_customers             
FROM customers_dataset c JOIN orders_dataset o
ON c.customer_id = o.customer_id
GROUP BY year;

-- JAWABAN REXY NO. 1 --
select 
	year, 
	round(avg(mau), 0) as average_mau
from (
	select 
		date_part('year', o.order_purchase_timestamp) as year,
		date_part('month', o.order_purchase_timestamp) as month,
		count(distinct c.customer_unique_id) as mau
	from orders_dataset o 
	join customers_dataset c on o.customer_id = c.customer_id
	group by 1,2 
) subq
group by 1



-- No. 2 --
WITH test AS
(
	SELECT customer_unique_id,
		   MIN(date_part('year', order_purchase_timestamp)) AS year
	FROM customers_dataset cd JOIN orders_dataset od ON cd.customer_id = od.customer_id
	JOIN
	(
		SELECT year,
			   COUNT(customer_unique_id) AS new_customer
		FROM
		(
			SELECT customer_unique_id,
				   MIN(date_part('year', order_purchase_timestamp)) AS year
			FROM customers_dataset cd
			JOIN orders_dataset od ON cd.customer_id = od.customer_id
-- 			GROUP BY 1
		) AS year_mua
	) AS new_cust
)
-- NO.2 JAWABAN GOOGLE --
WITH new_cust AS
(
	SELECT *,
	(SELECT MAX(order_purchase_timestamp) FROM orders_dataset) - interval '365 day' AS per_year
	FROM customers_dataset
	INNER JOIN orders_dataset USING (customer_id)
	INNER JOIN order_payments_dataset USING (order_id)
	WHERE order_purchase_timestamp > ((SELECT MAX(order_purchase_timestamp) FROM orders_dataset) - interval '365 day')
)
SELECT COUNT(DISTINCT customer_unique_id) FROM new_cust;



WITH new_cust AS
(
	SELECT SUM(IF(date_part('year', order_purchase_timestamp = '2016', 1, 0))) AS total_2016,
		   SUM(IF(date_part('year', order_purchase_timestamp IN ('2016','2017'), 1, 0))) total_2017,
		   COUNT(customer_unique_id) AS total_2018
	FROM
	(
		SELECT customer_unique_id,
		MIN(date_part('year', order_purchase_timestamp)) AS year_purchase
		FROM customers_dataset cd
		JOIN orders_dataset od ON cd.customer_id = od.customer_id
		GROUP BY customer_unique_id
	) a
	CROSS JOIN
	(
		SELECT year_purchase,
			   COUNT(customer_unique_id) AS count_new_cust
		FROM
		(
			SELECT customer_unique_id,
			MIN(date_part('year', order_purchase_timestamp)) AS year_purchase
			FROM customers_dataset cd
			JOIN orders_dataset od ON cd.customer_id = od.customer_id
			GROUP BY customer_unique_id
		) a
		GROUP BY year_purchase
	) b
)
SELECT * FROM new_cust



SELECT c.year, c.new_customers,
       CASE c.year
       WHEN '2016' THEN 0
       WHEN '2017' THEN ROUND(c.new_customers/total_2016*100,2)
       WHEN '2018' THEN ROUND(c.new_customers/total_2017*100,2)
       END AS growth_rate
FROM
(SELECT b.*,
        SUM(IF(a.year = '2016',1,0)) AS total_2016,
        SUM(IF(a.year IN ('2016','2017'),1,0)) AS total_2017,
        COUNT(a.customer_unique_id) AS total_2018
FROM (SELECT customer_unique_id,
             MIN(date_part('year', order_purchase_timestamp))) AS year
      FROM customers_dataset c JOIN orders_dataset o
      ON c.customer_id = o.customer_id
      GROUP BY customer_unique_id) a
CROSS JOIN (SELECT year, 
                   COUNT(customer_unique_id) AS new_customers
            FROM (SELECT customer_unique_id,
                         MIN(date_part('year', order_purchase_timestamp))) AS year
                  FROM customers_dataset c JOIN orders_dataset o
                  ON c.customer_id = o.customer_id
                  GROUP BY customer_unique_id) a
            GROUP BY year) b
GROUP BY b.year) c
ORDER BY year;

-- JAWABAN REXY NO. 2--
select 
	date_part('year', first_purchase_time) as year,
	count(1) as new_customers
from (
	select 
		c.customer_id,
		min(o.order_purchase_timestamp) as first_purchase_time
	from orders_dataset o 
	join customers_dataset c on c.customer_id = o.customer_id
	group by 1
) subq
group by 1
order by 1


-- NO. 3 JAWABAN BERSAMA--
select 
	year, 
	count(distinct customer_unique_id) as repeating_customers
from (
	select 
		date_part('year', o.order_purchase_timestamp) as year,
		c.customer_unique_id,
		count(1) as purchase_frequency
	from orders_dataset o 
	join customers_dataset c on c.customer_id = o.customer_id
	group by 1, 2
	having count(1) > 1
) subq
group by 1

-- NO. 4 REXY --
select 
	year, 
	round(avg(frequency_purchase),3) as avg_orders_per_customers 
from (
	select 
		date_part('year', o.order_purchase_timestamp) as year,
		c.customer_unique_id,
		count(1) as frequency_purchase
	from orders_dataset o 
	join customers_dataset c on c.customer_id = o.customer_id
	group by 1, 2
) a
group by 1

-- NO. 5 --
with calc_mau as (
select 
	year, 
	round(avg(mau), 2) as average_mau
from
(
	select 
		date_part('year', o.order_purchase_timestamp) as year,
		date_part('month', o.order_purchase_timestamp) as month,
		count(distinct c.customer_unique_id) as mau
	from orders_dataset o 
	join customers_dataset c on o.customer_id = c.customer_id
	group by 1,2 
) subq
group by 1
),
calc_repeat as (
select 
	year, 
	count(distinct customer_unique_id) as repeating_customers
from (
	select 
		date_part('year', o.order_purchase_timestamp) as year,
		c.customer_unique_id,
		count(1) as purchase_frequency
	from orders_dataset o 
	join customers_dataset c on c.customer_id = o.customer_id
	group by 1, 2
	having count(1) > 1
) subq
group by 1
),
calc_avg_order as(
select 
	year, 
	round(avg(frequency_purchase),3) as avg_orders_per_customers 
from (
	select 
		date_part('year', o.order_purchase_timestamp) as year,
		c.customer_unique_id,
		count(1) as frequency_purchase
	from orders_dataset o 
	join customers_dataset c on c.customer_id = o.customer_id
	group by 1, 2
) a
group by 1
order by 1
),
calc_new as(
select 
	date_part('year', first_purchase_time) as year,
	count(1) as new_customers
from (
	select 
		c.customer_id,
		min(o.order_purchase_timestamp) as first_purchase_time
	from orders_dataset o 
	join customers_dataset c on c.customer_id = o.customer_id
	group by 1
) subq
group by 1
order by 1
)
select calc_mau.year, calc_mau.average_mau, calc_new.new_customers, calc_repeat.repeating_customers, calc_avg_order.avg_orders_per_customers 
from calc_mau
join calc_repeat on calc_mau.year = calc_repeat.year
join calc_avg_order on calc_mau.year = calc_avg_order.year
join calc_new on calc_mau.year = calc_new.year