CREATE TABLE IF NOT EXISTS customers_dataset
(
	customer_id character varying(40) NOT NULL,
	customer_unique_id character varying(40) NOT NULL,
	zip_code_prefix integer,
	customer_city character varying(50),
	customer_state character(2),
	CONSTRAINT customers_dataset_pkey PRIMARY KEY (customer_id)
);
 
CREATE TABLE IF NOT EXISTS geolocation_dataset
(
	zip_code_prefix integer,
	geolocation_lat double precision,
	geolocation_lng double precision,
	geolocation_city character varying(50),
	geolocation_state character(2)
);
 
CREATE TABLE IF NOT EXISTS order_items_dataset
(
	order_id character varying(40),
	order_item_id integer,
	product_id character varying(40),
	seller_id character varying(40),
	shipping_limit_date timestamp without time zone,
	price double precision,
	freight_value double precision
);
 
CREATE TABLE IF NOT EXISTS order_payments_dataset
(
	order_id character varying(40),
	payment_sequential character(2),
	payment_type character varying(15),
	payment_installments character(2),
	payment_value double precision
);
 
CREATE TABLE IF NOT EXISTS order_reviews_dataset
(
	review_id character varying(40),
	order_id character varying(40),
	review_score character(1),
	review_comment_title character varying,
	review_comment_message character varying,
	review_creation_date timestamp without time zone,
    review_answer_timestamp timestamp without time zone
);

CREATE TABLE IF NOT EXISTS orders_dataset
(
	order_id character varying(40),
	customer_id character varying(40),
	order_status character(15),
    order_purchase_timestamp timestamp without time zone,
	order_approved_at timestamp without time zone,
    order_delivered_carrier_date timestamp without time zone,
    order_delivered_customer_date timestamp without time zone,
    order_estimated_delivery_date timestamp without time zone,
	CONSTRAINT orders_dataset_pkey PRIMARY KEY (order_id)
);
 
CREATE TABLE IF NOT EXISTS product_dataset
(
	id INT,
	product_id VARCHAR(40) NOT NULL,
	product_category_name VARCHAR(50),
	product_name_lenght double precision,
    product_description_lenght double precision,
	product_photos_qty double precision,
	product_weight_g double precision,
	product_length_cm double precision,
	product_height_cm double precision,
	product_width_cm double precision,
	CONSTRAINT product_dataset_pkey PRIMARY KEY (product_id)
);

CREATE TABLE IF NOT EXISTS sellers_dataset
(
	seller_id character varying(40) NOT NULL,
	zip_code_prefix integer,
	seller_city character varying(50),
	seller_state character(2),
	CONSTRAINT sellers_dataset_pkey PRIMARY KEY (seller_id)
);