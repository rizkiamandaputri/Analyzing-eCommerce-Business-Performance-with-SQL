-- NO. 1 --
-- Total of Revenue per Year --
CREATE TABLE total_revenue_per_year AS
SELECT 
	date_part('year', order_purchase_timestamp) AS year,
	SUM(revenue_per_order) AS total_revenue_per_year
FROM
(
	SELECT 
		order_id, 
		SUM(price + freight_value) AS revenue_per_order
	FROM order_items_dataset
	GROUP BY 1
) subq
JOIN orders_dataset AS od ON subq.order_id = od.order_id
WHERE order_status = 'delivered'
GROUP BY 1
ORDER BY 1

-- NO. 2 --
-- Number of Cancel Order per Year --
CREATE TABLE total_cancel_order_per_year AS
SELECT
	date_part('year', order_purchase_timestamp) as year,
	COUNT(1) AS total_cancel_order
FROM orders_dataset
WHERE order_status = 'canceled'
GROUP BY 1
ORDER BY 1

-- NO. 3 --
-- Top Category Generates The Largest Amount of Revenue per Year --
CREATE TABLE top_product_category_by_revenue_per_year AS
SELECT 
	year, 
	product_category_name, 
	revenue 
FROM
(
	SELECT 
		date_part('year', order_purchase_timestamp) AS year,
		product_category_name,
		SUM(price + freight_value) AS revenue,
		RANK()
	    OVER
		(
			PARTITION BY date_part('year', order_purchase_timestamp) 
	 		ORDER BY SUM(price + freight_value) DESC
		) AS rk
		FROM order_items_dataset AS oid
		JOIN orders_dataset AS od ON od.order_id = oid.order_id
		JOIN product_dataset pd ON pd.product_id = oid.product_id
		WHERE order_status = 'delivered'
		GROUP BY 1,2
) sq
WHERE rk = 1

-- NO. 4 --
-- Number of Category With The Most Order Cancellations per Year --
CREATE TABLE top_product_category_by_cancel_per_year AS 
SELECT 
	year, 
	product_category_name, 
	total_cancel 
FROM
(
	SELECT date_part('year', order_purchase_timestamp) AS year,
		   product_category_name,
		   COUNT(1) AS total_cancel,
		   RANK() OVER(
		   PARTITION BY date_part('year', order_purchase_timestamp) 
	ORDER BY COUNT(1) DESC) AS rk
	FROM order_items_dataset AS oid
	JOIN orders_dataset AS od on od.order_id = oid.order_id
	JOIN product_dataset pd on pd.product_id = oid.product_id
	WHERE order_status = 'canceled'
	GROUP BY 1,2
) sq
WHERE rk = 1;

-- NO. 5 --
-- Summary Table --
SELECT
	ry.year,
	try.product_category_name AS category_most_revenue,
	try.revenue AS most_revenue,
	ry.revenue AS total_revenue_per_year,
	tcy.product_category_name AS category_most_cancel,
	tcy.total_cancel AS num_most_cancel,
	cpy.total_cancel AS total_cancel
FROM total_revenue_per_year AS ry
JOIN total_cancel_order_per_year AS cpy ON ry.year = cpy.year
JOIN top_product_category_by_revenue_per_year AS try ON try.year = ry.year
JOIN top_product_category_by_cancel_per_year AS tcy ON tcy.year = ry.year