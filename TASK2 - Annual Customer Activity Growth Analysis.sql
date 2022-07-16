-- NO. 1 --
-- Average of Monthly Active User (MAU) per Year --
WITH mau AS
(
	SELECT year,
		   round(avg(customer), 2) AS avg_mau
	FROM
	(
		SELECT date_part('year', order_purchase_timestamp) AS year,
		       date_part('month', order_purchase_timestamp) AS month,
		       COUNT(DISTINCT customer_unique_id) AS customer
		FROM orders_dataset AS od
		JOIN customers_dataset AS cd ON od.customer_id = cd.customer_id
		GROUP BY 1,2
	) a
	GROUP BY 1
)
SELECT * FROM mau

-- NO. 2 --
-- Total of New Customer per Year --
WITH new_purchase AS
(
	SELECT date_part('year', order_purchase_timestamp) AS year,
		   COUNT(1) AS new_customer
	FROM orders_dataset AS od
	JOIN customers_dataset AS cd ON od.customer_id = cd.customer_id
	GROUP BY 1
)
SELECT * FROM new_purchase
ORDER BY 1

-- NO. 3 --
-- Number of Customers Who Repeat Orders per Year --
WITH repeat_purchase AS
(
	SELECT year,
	       COUNT(DISTINCT customer_unique_id) AS repeat_order
	FROM
	(
		SELECT date_part('year', order_purchase_timestamp) AS year,
			   customer_unique_id,
		       COUNT(1) AS purchase_frequency
		FROM orders_dataset AS od
		JOIN customers_dataset AS cd ON od.customer_id = cd.customer_id
		GROUP BY 1,2
		HAVING COUNT(1) > 1
	) a
	GROUP BY 1
)
SELECT * FROM repeat_purchase

-- NO. 4 --
-- Average of Frequency Order per Year --
WITH avg_orders AS
(
	SELECT year,
		   round(avg(frequency_purchase), 3) AS avg_orders_cust
	FROM
	(
		SELECT date_part('year', order_purchase_timestamp) AS year,
		       customer_unique_id,
		       COUNT(1) AS frequency_purchase
		FROM orders_dataset AS od
		JOIN customers_dataset AS cd ON od.customer_id = cd.customer_id
		GROUP BY 1,2
	) a
	GROUP BY 1
)
SELECT * FROM avg_orders
ORDER BY 1

-- NO. 5 --
WITH mau AS
(
	SELECT year,
		   round(avg(customer), 2) AS avg_mau
	FROM
	(
		SELECT date_part('year', order_purchase_timestamp) AS year,
		       date_part('month', order_purchase_timestamp) AS month,
		       COUNT(DISTINCT customer_unique_id) AS customer
		FROM orders_dataset AS od
		JOIN customers_dataset AS cd ON od.customer_id = cd.customer_id
		GROUP BY 1,2
	) a
	GROUP BY 1
),
new_purchase AS
(
	SELECT date_part('year', order_purchase_timestamp) AS year,
		   COUNT(1) AS new_customer
	FROM orders_dataset AS od
	JOIN customers_dataset AS cd ON od.customer_id = cd.customer_id
	GROUP BY 1
),
repeat_purchase AS
(
	SELECT year,
	       COUNT(DISTINCT customer_unique_id) AS repeat_order
	FROM
	(
		SELECT date_part('year', order_purchase_timestamp) AS year,
			   customer_unique_id,
		       COUNT(1) AS purchase_frequency
		FROM orders_dataset AS od
		JOIN customers_dataset AS cd ON od.customer_id = cd.customer_id
		GROUP BY 1,2
		HAVING COUNT(1) > 1
	) a
	GROUP BY 1
),
avg_orders AS
(
	SELECT year,
		   round(avg(frequency_purchase), 3) AS avg_orders_cust
	FROM
	(
		SELECT date_part('year', order_purchase_timestamp) AS year,
		       customer_unique_id,
		       COUNT(1) AS frequency_purchase
		FROM orders_dataset AS od
		JOIN customers_dataset AS cd ON od.customer_id = cd.customer_id
		GROUP BY 1,2
	) a
	GROUP BY 1
)
SELECT mau.year, mau.avg_mau, new_purchase.new_customer, repeat_purchase.repeat_order, avg_orders.avg_orders_cust 
FROM mau
JOIN repeat_purchase on mau.year = repeat_purchase.year
JOIN avg_orders ON mau.year = avg_orders.year
JOIN new_purchase ON mau.year = new_purchase.year
ORDER BY year