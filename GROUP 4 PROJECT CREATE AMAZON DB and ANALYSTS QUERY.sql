/*
CREATE TABLE STATEMENT FOR GROUP 4 AMAZON DATABASE
*/

CREATE TABLE customers(
	customer_id							int NOT NULL,
	customer_name                   	varchar(50) NOT NULL, 
	customer_email                  	varchar(50) NOT NULL, 
	
	PRIMARY KEY (customer_id)
);

CREATE TABLE addresses(
	address_id                       	int NOT NULL,
	shipping_address_name            	varchar(100) NOT NULL, 
	shipping_address_street        		varchar(100) NOT NULL, 
	shipping_address_city            	varchar(50) NOT NULL, 
	shipping_address_state           	varchar(50) NOT NULL, 
	shipping_address_zip             	varchar(20) NOT NULL,
	
	PRIMARY KEY (address_id)
);

CREATE TABLE customerAddresses(
	customer_id							int NOT NULL,
	address_id                       	int NOT NULL,

	PRIMARY KEY (customer_id, address_id),
	FOREIGN KEY (customer_id)
		REFERENCES customers(customer_id),
	FOREIGN KEY (address_id)
		REFERENCES addresses(address_id)
);

CREATE TABLE payments(
	payment_card_number					varchar(50) NOT NULL,
	payment_full_name                  	varchar(100) NOT NULL,
	
	PRIMARY KEY (payment_card_number)
);

CREATE TABLE customersPayments(
	customer_id							int NOT NULL,
	payment_card_number					varchar(50) NOT NULL,

	PRIMARY KEY (customer_id, payment_card_number),
	FOREIGN KEY (customer_id)
		REFERENCES customers(customer_id),
	FOREIGN KEY (payment_card_number)
		REFERENCES payments(payment_card_number)
);

CREATE TABLE orders(
	order_id							varchar(50) NOT NULL,
	order_date                       	timestamp NOT NULL,

	PRIMARY KEY (order_id)
);

CREATE TABLE customersOrders(
	customer_id							int NOT NULL,
	order_id							varchar(50) NOT NULL,

	PRIMARY KEY (customer_id, order_id),
	FOREIGN KEY (customer_id)
		REFERENCES customers(customer_id),
	FOREIGN KEY (order_id)
		REFERENCES orders(order_id)
);

CREATE TABLE products(
	product_id							varchar(50) NOT NULL,
	product_name                       	varchar(250) NOT NULL,

	PRIMARY KEY (product_id)
);

CREATE TABLE productsPrice(
	product_id							varchar(50) NOT NULL,
	product_date                       	date NOT NULL,
	purchase_price_per_unit 			numeric(1000,2) NOT NULL, 

	PRIMARY KEY (product_id, product_date),
	FOREIGN KEY (product_id) 
		REFERENCES products(product_id)
);

CREATE TABLE ordersProducts(
	order_id							varchar(50) NOT NULL,
	product_id							varchar(50) NOT NULL,
	quantity							int NOT NULL, 

	PRIMARY KEY (order_id, product_id),
	FOREIGN KEY (order_id)
		REFERENCES orders(order_id), 
	FOREIGN KEY (product_id)
		REFERENCES products(product_id)
);

CREATE TABLE categories(
	category_id							int NOT NULL,
	category_name                       varchar(50) NOT NULL,
	
	PRIMARY KEY (category_id)
);

CREATE TABLE productsCategories(
	product_id							varchar(50) NOT NULL,
	category_id							int NOT NULL, 
	description							varchar(100),

	PRIMARY KEY (product_id, category_id),	 
	FOREIGN KEY (product_id)
		REFERENCES products(product_id), 
	FOREIGN KEY (category_id)
		REFERENCES categories(category_id)
);

CREATE TABLE sellers(
	seller_id							int NOT NULL,
	seller_name                       	varchar(50) NOT NULL,
	
	PRIMARY KEY (seller_id)
);

CREATE TABLE productsSellers(
	product_id							varchar(50) NOT NULL,
	seller_id							int NOT NULL, 

	PRIMARY KEY (product_id, seller_id),	 
	FOREIGN KEY (product_id)
		REFERENCES products(product_id), 
	FOREIGN KEY (seller_id)
		REFERENCES sellers(seller_id)
);

------------- SQL SCRIPT ANALYST
-- [Analyst] What percentage of the total sales for 2021 was sold by Amazon.com?
WITH base as(
SELECT
	s.seller_id
	,seller_name
	,SUM(purchase_price_per_unit * quantity) as order_total
	
FROM orders o 
JOIN ordersproducts op 
	ON o.order_id = op.order_id
JOIN products p 
	ON p.product_id = op.product_id 
JOIN productssellers ps 
	ON ps.product_id = p.product_id 
JOIN sellers s 
	ON s.seller_id = ps.seller_id
JOIN productsprice pp 
	ON pp.product_id = p.product_id 
		AND pp.product_date = o.order_date
WHERE 
	date_part('year', order_date) = 2021
	
GROUP BY 1,2
),
amazonsales as(
SELECT 
	'1' as id
	,order_total as amazon_order_total
FROM base 
WHERE seller_name = 'Amazon.com'
	
), 
nonamazonsales as (
SELECT 
	'1' as id
	,sum(order_total) as nonamazon_order_total
FROM base 
WHERE seller_name <> 'Amazon.com'
)

SELECT 
	round(amazon_order_total/(amazon_order_total+nonamazon_order_total),2) as answer_1
FROM amazonsales ams
JOIN nonamazonsales nas
	on ams.id = nas.id
	
-- [Analyst] What is the average purchase price per unit for the top 5 categories?
with base as (
SELECT *
FROM orders o 
JOIN ordersproducts op 
	ON o.order_id = op.order_id
JOIN products p 
	ON p.product_id = op.product_id 
JOIN productsprice pp 
	ON pp.product_id = p.product_id 
		AND pp.product_date = o.order_date
JOIN productscategories pc
	ON pc.product_id = p.product_id
JOIN categories c
	ON c.category_id = pc.category_id

),
top5category as (
select 
	category_name
	,count(*)
	,RANK() OVER (ORDER BY count(*) DESC) 
from base
group by 1
)
SELECT 
	category_name
	,ROUND(AVG(purchase_price_per_unit),2)
FROM base 
WHERE category_name IN (
	SELECT category_name
	FROM top5category
	WHERE rank in (1,2,3,4,5)
)
GROUP BY category_name

-- [Analyst] Which customers ship their purchases to themselves instead of someone else?

with base as(
SELECT *
FROM customers c
JOIN customeraddresses ca
	ON c.customer_id = ca.customer_id
JOIN addresses a 
	ON ca.address_id = a.address_id
) 
SELECT customer_name 
FROM customers
WHERE customer_name NOT IN (
	SELECT customer_name 
	FROM (
		SELECT 
			customer_name
			,count(shipping_address_name)
		FROM base
		WHERE customer_name <> shipping_address_name
		GROUP BY 1) tmp
)

-- [Analyst] What is the most common product category for total orders over $100?
WITH base as (
SELECT *
FROM orders o 
JOIN ordersproducts op 
	ON o.order_id = op.order_id
JOIN products p 
	ON p.product_id = op.product_id 
JOIN productsprice pp 
	ON pp.product_id = p.product_id 
		AND pp.product_date = o.order_date
JOIN productscategories pc
	ON pc.product_id = p.product_id
JOIN categories c
	ON c.category_id = pc.category_id

)
,
tmp as (
SELECT DISTINCT
	category_name
	,(purchase_price_per_unit * quantity) as order_total
FROM base 
WHERE (purchase_price_per_unit * quantity) > 100
)

SELECT 
	category_name
	,count(*)
	,RANK() OVER (ORDER BY count(*) DESC) as ranked_category_count
FROM tmp 
GROUP BY 1
LIMIT 1

-- [Analyst] Can you display all of the products that were purchased over 3 times per customer?
WITH base as (
SELECT 
	op.order_id
	,op.product_id as op_product_id
	,p.product_id as p_product_id
	,p.product_name
	,c.customer_id
	,c.customer_name
FROM orders o 
JOIN ordersproducts op 
	ON o.order_id = op.order_id
JOIN products p 
	ON p.product_id = op.product_id 
JOIN customersorders co
	ON o.order_id = co.order_id
JOIN customers c
	ON c.customer_id = co.customer_id

)
SELECT 
	customer_id
	,customer_name
	,op_product_id
	,product_name
	,count(*) as count_item_ordered
FROM base  
GROUP BY 1,2,3,4
HAVING count(*) >= 3

-- [Analyst] Can you display all of the products that were purchased over 2 times per customer on a monthly basis? 
WITH base as (
SELECT 
	op.order_id
	,op.product_id as op_product_id
	,p.product_id as p_product_id
	,p.product_name
	,c.customer_id
	,c.customer_name
	,date_part('month', o.order_date) as month_order_date
FROM orders o 
JOIN ordersproducts op 
	ON o.order_id = op.order_id
JOIN products p 
	ON p.product_id = op.product_id 
JOIN customersorders co
	ON o.order_id = co.order_id
JOIN customers c
	ON c.customer_id = co.customer_id
)
SELECT 
	customer_id
	,customer_name
	,op_product_id
	,product_name
	,month_order_date
	,count(*) as count_item_ordered
FROM base  
GROUP BY 1,2,3,4,5
HAVING count(*) >= 2
ORDER BY customer_id, month_order_date
	

-- [Analyst] Which products had price variability by product date? 
WITH base as (
SELECT 
	p.product_id
	,product_name
	,product_date
	,purchase_price_per_unit
	,lag(product_date) over (partition by p.product_id order by product_date) as prev_product_date
	,lag(purchase_price_per_unit) over (partition by p.product_id order by product_date) as prev_product_price
FROM products p 
JOIN productsprice pp
	ON p.product_id = pp.product_id
ORDER BY p.product_id
)
SELECT 
	* 
	,(purchase_price_per_unit - prev_product_price) as difference_current_and_previous_price
FROM base 
WHERE prev_product_price IS NOT NULL



