                            -- The Amount of Usage of Each Type of Payment for Each Year --
-- NO. 1 --
SELECT payment_type,
	   COUNT(1) AS total_use_payment_type
FROM order_payments_dataset
GROUP BY 1
ORDER BY 2 DESC;

-- NO. 2 --
WITH payment_method AS
(
	SELECT date_part('year', order_purchase_timestamp) AS year,
		   payment_type,
		   COUNT(1) AS total_use_payment_type
	FROM order_payments_dataset AS opd
	JOIN orders_dataset AS od ON opd.order_id = od.order_id
	GROUP BY 1,2
)
SELECT *,
	   CASE WHEN year_2017 = 0 THEN NULL
	   ELSE ROUND((year_2018 - year_2017) / year_2017, 2)
	   END AS pct_change_2017_2018
FROM
(
	SELECT payment_type,
		   SUM(CASE WHEN year = '2016' THEN total_use_payment_type ELSE 0 END) AS year_2016,
		   SUM(CASE WHEN year = '2017' THEN total_use_payment_type ELSE 0 END) AS year_2017,
		   SUM(CASE WHEN year = '2018' THEN total_use_payment_type ELSE 0 END) AS year_2018
	FROM payment_method
	GROUP BY 1
) a