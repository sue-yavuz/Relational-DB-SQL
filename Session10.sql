/*  SESSION # 10
    WINDOW FUNCTIONS
*/
SELECT category_id, product_id,
	COUNT(*) OVER() NOTHING
	, COUNT(*) OVER (PARTITION BY category_id ORDER BY product_id) count_by_cat2
	, COUNT(*) OVER (PARTITION BY category_id ORDER BY product_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) first_to_current
	, COUNT(*) OVER (PARTITION BY category_id ORDER BY product_id ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) current_to_last
	, COUNT(*) OVER (PARTITION BY category_id ORDER BY product_id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) all_rows
	, COUNT(*) OVER (PARTITION BY category_id ORDER BY product_id ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) specified_rows
	, COUNT(*) OVER (PARTITION BY category_id ORDER BY product_id ROWS BETWEEN 2 PRECEDING AND 3 FOLLOWING) specified_rows2
	, COUNT(*) OVER (PARTITION BY category_id  ROWS BETWEEN 2 PRECEDING AND 3 FOLLOWING) specified_rows3
FROM product.product
ORDER BY 1,2

-- How many different product are in each brand in each category

select distinct category_id, brand_id,
       count(product_id) over(partition by category_id, brand_id) num_of_prod
from product.product

---------------------------------
---ANALYTIC NAVIGATION FUNCTIONS
---------------------------------

SELECT A.customer_id, A.first_name, B.order_date,
	FIRST_VALUE(order_date) OVER (ORDER BY order_date) as first_date--,
	--FIRST_VALUE(order_date) OVER (ORDER BY order_date desc) as first_date1
FROM sale.customer A JOIN
		sale.orders B ON A.customer_id = B.customer_id

--Write a query that returns most stocked product in each store.

SELECT DISTINCT store_id,
		FIRST_VALUE(product_id) OVER (PARTITION BY store_id ORDER BY quantity desc) most_stocked_product
FROM product.stock

--Write a query that returns customers and their most expensive order with total amount of it
SELECT DISTINCT
	A.customer_id,
	FIRST_VALUE(A.order_id) OVER ( PARTITION BY customer_id ORDER BY quantity*list_price*(1-discount) DESC) order_id_with_max_value,
	FIRST_VALUE(quantity*list_price*(1-discount))OVER (PARTITION BY customer_id ORDER BY quantity*list_price*(1-discount) DESC) max_value
FROM sale.orders A JOIN sale.order_item B
	ON A.order_id = B.order_id


	select A.order_id, B.list_price,B.quantity,B.discount, quantity*list_price*(1-discount) as net_proce
	FROM sale.orders A JOIN sale.order_item B
	ON A.order_id = B.order_id
	where A.order_id = 1555

--Pop quiz: write a query  to calculate how many different brands are in each category
	select distinct category_id, 
    count(brand_id) over(partition by category_id) num_of_brand
from product.product

	select distinct category_id, 
    count(distinct brand_id) over(partition by category_id) num_of_brand
from product.product

select * from product.product
where category_id = 1
order by brand_id

SELECT category_id , COUNT(DISTINCT brand_id)
FROM product.product
GROUP BY category_id 

---Write a query that returns first order date by month.
SELECT DISTINCT
    YEAR(order_date) AS OrderYear,
    MONTH(order_date) AS OrderMonth,
    FIRST_VALUE(order_date) OVER(PARTITION BY YEAR(order_date), MONTH(order_date) ORDER BY order_date) AS FirstOrderDate
FROM sale.orders

-----------------------
-------LAST_VALUE----
-----------------------
SELECT A.customer_id, A.first_name, B.order_date,
	LAST_VALUE(Order_date) OVER (ORDER BY order_date DESC) as last_date
FROM 
	sale.customer A JOIN sale.orders B
		ON A.customer_id = B.customer_id
ORDER BY 3

--Row or Range clause are optional in LAST_VALUE
---But you may need to explicitly specify a frame to get the result you seek

SELECT A.customer_id, A.first_name, B.order_date,
	LAST_VALUE(Order_date) OVER (ORDER BY order_date DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as last_date
FROM 
	sale.customer A JOIN sale.orders B
		ON A.customer_id = B.customer_id
ORDER BY 3

--Write a query that returns most stocked product in each store.
--using LAST_VALUE
SELECT DISTINCT store_id,
		FIRST_VALUE(product_id) OVER (PARTITION BY store_id ORDER BY quantity desc) most_stocked_product
FROM product.stock

SELECT DISTINCT store_id,
		LAST_VALUE(product_id) OVER (PARTITION BY store_id ORDER BY quantity asc ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) most_stocked_product
FROM product.stock

-- write a query to get the name of the cheapest product (use first_value)
SELECT DISTINCT 
	FIRST_VALUE(product_name) OVER (ORDER BY list_price asc) cheapest_product
FROM product.product

SELECT DISTINCT 
	LAST_VALUE(product_name) OVER (ORDER BY list_price desc ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) cheapest_product
FROM product.product


select * from product.product
order by list_price desc

------------------------------
--LEAD & LAG
------------------------------
/*
LEAD(Column Name, Offset, default value)

default offset = 1
default value is null
*/

SELECT
	order_date,
	LAG(order_date) OVER (ORDER BY order_date) prev_w_lag
FROM sale.orders

--with offset
SELECT
	order_date,
	LAG(order_date,3) OVER (ORDER BY order_date) prev_w_lag
FROM sale.orders

--with default value
SELECT
	order_date,
	LAG(order_date,3, '1900-01-01') OVER (ORDER BY order_date) prev_w_lag
FROM sale.orders

--LEAD
SELECT
	order_date,
	LEAD(order_date) OVER (ORDER BY order_date) next_w_lead
FROM sale.orders

SELECT
	order_date,
	LEAD(order_date, 3) OVER (ORDER BY order_date) next_w_lead
FROM sale.orders

SELECT
	order_date,
	LEAD(order_date, 3, '1900-01-01') OVER (ORDER BY order_date) next_w_lead
FROM sale.orders

/*
declare @firstdate datetime

SELECT @firstdate = MIN (order_Date)
FROM sale.orders

--SELECT @firstdate

SELECT
	order_date,
	LAG(order_date,3, @firstdate) OVER (ORDER BY order_date) prev_w_lag
FROM sale.orders
*/

----Write a query that returns the order date of the one previous sale of each staff (use the LAG function)

SELECT A.order_id, B.staff_id,B.first_name,B.last_name, A.order_date,
	LAG(order_date) OVER (PARTITION BY B.staff_id ORDER BY A.order_id ) previous_order_date
FROM sale.orders A JOIN sale.staff B
	ON A.staff_id = B.staff_id

--Write a query that returns the order date of the one next sale of each staff (use the LEAD function)
select A.order_id, B.staff_id, B.first_name, B.last_name, A.order_date,
    lead(order_date) over (partition by B.staff_id order by order_id) next_order_date
from sale.orders A JOIN sale.staff B
ON  A.staff_id = B.staff_id
order by A.staff_id

select * from sale.orders
order by order_date

-------------------------------------------
--Write a query that returns the difference order count between 
--the current month and the next month for each year. 

--Let's first determine the order count by month
;WITH T1 AS (
	SELECT DISTINCT YEAR(order_date) order_year, MONTH(order_date) order_month,
		COUNT(order_id) OVER (PARTITION BY YEAR(order_date), MONTH(order_date) ) cnt_order
	FROM sale.orders
	)

	SELECT order_year, order_month, cnt_order,
	LEAD(order_month) OVER (PARTITION BY order_year ORDER BY order_year, order_month ) next_month,
	LEAD(cnt_order) OVER (PARTITION BY order_year ORDER BY order_year, order_month ) next_month_cnt
	FROM T1