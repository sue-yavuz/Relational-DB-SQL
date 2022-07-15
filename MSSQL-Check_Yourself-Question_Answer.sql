--MSSQL CHECK YOURSELF
--(Use SampleRetail DB on SQL Server and paste the result in the answer box.)

USE SampleRetail;
GO


--Functions
--QUESTION 1: List the product names in ascending order where the part from the beginning to the first space character is "Samsung" in the product_name column.
select	product_name
from	product.product
WHERE	NULLIF(PATINDEX('SAMSUNG% %', product_name), 0) IS NOT NULL
ORDER BY 1
GO

--QUESTION 2: Write a query that returns streets in ascending order. The streets have an integer character lower than 5 after the "#" character end of the street. (use sale.customer table)
select	street
from	sale.customer
WHERE	NULLIF(PATINDEX('%#[0-4]%', street), 0) IS NOT NULL
		and STR(SUBSTRING(street, PATINDEX('%#[0-4]%', street)+1, 3))<5
ORDER BY 1
GO


--Joins&View
--QUESTION 1: Write a query that returns the order date of the product named "Sony - 5.1-Ch. 3D / Smart Blu-ray Home Theater System - Black".
SELECT	so.order_date
FROM	sale.orders so, sale.order_item soi, product.product pp
WHERE	so.order_id=soi.order_id 
		and soi.product_id=pp.product_id
		and pp.product_name='Sony - 5.1-Ch. 3D / Smart Blu-ray Home Theater System - Black'
GO

--QUESTION 2: Write a query that returns orders of the products branded "Seagate". It should be listed Product names and order IDs of all the products ordered or not ordered. (order_id in ascending order)
SELECT	pp.product_name, soi.order_id
FROM	product.brand pb
JOIN	product.product pp 
		ON pb.brand_id=pp.brand_id 
		and pb.brand_name='Seagate'
LEFT JOIN sale.order_item soi
		ON pp.product_id=soi.product_id 
ORDER BY 2	
GO

--Advanced Grouping Operations
--QUESTION 1: Please write a query to return only the order ids that have an average amount of more than $2000. Your result set should include order_id. Sort the order_id in ascending order.
SELECT	order_id 
FROM	sale.order_item
GROUP BY order_id
HAVING AVG(quantity*list_price) >2000
GO

--QUESTION 2: Write a query that returns the count of orders of each day between '2020-01-19' and '2020-01-25'. Report the result using Pivot Table. Note: The column names should be day names (Sun, Mon, etc.).
SELECT * 
FROM	(
SELECT	order_id, DATENAME(DW, order_date) as order_dateneme
FROM	sale.orders
WHERE	order_date BETWEEN '2020-01-19' and '2020-01-25'
) as A 
PIVOT (
	COUNT(order_id)
	FOR order_dateneme in(
	[Sunday], [Monday], [Tuesday], [Wednesday], 
	[Thursday], [Friday], [Saturday]
	)
) as pvt
GO

--Set Operators
--QUESTION 1: Detect the store that does not have a product named "Samsung Galaxy Tab S3 Keyboard Cover" in its stock. (Paste the store name in the box below.)
SELECT	B.store_name
FROM	(
	SELECT	ps.store_id
	FROM	product.product pp, Product.stock ps
	WHERE	pp.product_id=ps.product_id
	EXCEPT
	SELECT	ps.store_id
	FROM	product.product pp, Product.stock ps
	WHERE	pp.product_id=ps.product_id
			and pp.product_name = 'Samsung Galaxy Tab S3 Keyboard Cover'
) as A, sale.store B
WHERE A.store_id=B.store_id

--QUESTION 2: List in ascending order the stores where both "Samsung Galaxy Tab S3 Keyboard Cover" and "Apple - Pre-Owned iPad 3 - 64GB - Black" are stocked.
SELECT	B.store_name
FROM	(
	SELECT	ps.store_id
	FROM	product.product pp, Product.stock ps
	WHERE	pp.product_id=ps.product_id
			and pp.product_name = 'Samsung Galaxy Tab S3 Keyboard Cover'
	INTERSECT
	SELECT	ps.store_id
	FROM	product.product pp, Product.stock ps
	WHERE	pp.product_id=ps.product_id
			and pp.product_name ='Apple - Pre-Owned iPad 3 - 64GB - Black'
) as A, sale.store B
WHERE A.store_id=B.store_id
ORDER BY B.store_name

--CASE Expression

--QUESTION 1:Classify staff according to the count of orders they receive as follows:
/*
a) 'High-Performance Employee' if the number of orders is greater than 400
b) 'Normal-Performance Employee' if the number of orders is between 100 and 400
c) 'Low-Performance Employee' if the number of orders is between 1 and 100
d) 'No Order' if the number of orders is 0
Then, list the staff's first name, last name, employee class, and count of orders.  (Count of orders and first names in ascending order)
*/
SELECT	first_name, last_name
		,CASE
		WHEN a.Count_of_orders IS NULL THEN 'No Order'
		WHEN a.Count_of_orders < 100 THEN 'Low-Performance Employee'
		WHEN a.Count_of_orders < 400 THEN 'Normal-Performance Employee'
		WHEN a.Count_of_orders >= 400 THEN 'High-Performance Employee'
		END as employee_class
		, COALESCE(a.Count_of_orders, 0) AS Count_of_orders
FROM (
SELECT	staff_id, COUNT(order_id) as Count_of_orders
FROM	sale.orders
GROUP BY staff_id
) a
RIGHT JOIN  sale.staff b
		ON a.staff_id=b.staff_id
ORDER BY 4, 1

--QUESTION 2:List counts of orders on the weekend and weekdays. Submit your answer in a single row with two columns. For example: 164 161. First value is for weekend.
SELECT	*
FROM	(
SELECT	CASE
		WHEN DATEPART(DW, order_date) in (1,7) THEN 'Weekend'
		ELSE 'Weekday'
		END as week_part
FROM	sale.orders
) A
PIVOT (
	count(week_part)
	for week_part in(
	[Weekend], [Weekday])
) pvt

SELECT	*
FROM	(
SELECT	CASE
		WHEN DATENAME(DW, order_date) in ('Sunday','Saturday') THEN 'Weekend'
		ELSE 'Weekday'
		END as week_part
FROM	sale.orders
) A
PIVOT (
	count(week_part)
	for week_part in(
	[Weekend], [Weekday])
) pvt

--Subqueries and CTE's

--QUESTION 1: List the store names in ascending order that did not have an order between "2018-07-22" and "2018-07-28".
WITH store_temp (store_name) as(
	SELECT	store_name
	FROM	sale.store
	EXCEPT
	SELECT	ss.store_name
	FROM	sale.orders so, sale.store ss
	WHERE	ss.store_id=so.store_id
			and order_date between '2018-07-22' and '2018-07-28'
) SELECT * FROM store_temp;

WITH store_temp (store_name) as(
	
	EXCEPT
	SELECT	ss.store_name
	FROM	sale.orders so, sale.store ss
	WHERE	ss.store_id=so.store_id
			and order_date between '2018-07-22' and '2018-07-28'
) SELECT	store_name
	FROM	sale.store
;

--QUESTION 2: List customers with each order over 500$ and reside in the city of Charleston. List customers' first name and last name ( both of the last name and first name in ascending order). 
select	distinct sc.first_name, sc.last_name
from	sale.customer sc, sale.orders so, sale.order_item soi
WHERE	sc.customer_id=so.customer_id
		and so.order_id=soi.order_id
		and (soi.list_price*soi.quantity*(1-soi.discount))>500
		and sc.city='Charleston'
order by 2,1

SELECT first_name, last_name 
FROM sale.customer SC
WHERE city='Charleston' and EXISTS (
			SELECT O.customer_id
			FROM sale.order_item I, sale.orders O WHERE O.order_id=I.order_id
			AND SC.customer_id = O.customer_id
			GROUP BY O.order_id, O.customer_id
			HAVING SUM(quantity*list_price*(1-discount)) > 500
			EXCEPT
			SELECT O.customer_id
			FROM sale.order_item I, sale.orders O WHERE O.order_id=I.order_id
			AND SC.customer_id = O.customer_id
			GROUP BY O.order_id, O.customer_id
			HAVING SUM(quantity*list_price*(1-discount)) <= 500
			)
ORDER BY last_name, first_name

--Window Functions
--QUESTION 1: List the employee's first order dates by month in 2020. Expected columns are: first name, last name, month and the first order date. (last name and month in ascending order)
/*
2020'de çalýþanýn ilk sipariþ tarihlerini aylara göre listeleyin.
Beklenen sütunlar þunlardýr: ad, soyadý, ay ve ilk sipariþ tarihi. (artan sýrada soyadý ve ay)
*/
select distinct first_name, last_name, month(order_date), first_order
from (
select *, 
	FIRST_VALUE(order_date) OVER(partition by (staff_id),
				month(order_date) order by order_date) AS first_order
from sale.orders 
where year(order_date) = 2020
) AS so, sale.staff sf 
where so.staff_id = sf.staff_id
order by 2
;

--QUESTION 2: Write a query using the window function that returns staffs' first name, last name, and their total net amount of orders in descending order.

SELECT	distinct order_date, total_turnovers
FROM	(
SELECT	distinct so.store_id, so.order_date,
		SUM(soi.quantity*soi.list_price) OVER(PARTITION BY so.store_id ORDER BY so.order_date) as total_turnovers
FROM	sale.orders so, sale.order_item soi
WHERE	so.order_id=soi.order_id and so.order_date BETWEEN '2019-04-01' AND '2019-04-30'	
) A, sale.store B
WHERE	a.store_id=b.store_id
		and b.store_name='Burkes Outlet'
;

--QUESTION 3: 
--Write a query using the window function that returns staffs' first name, last name, and their total net amount of orders in descending order.
SELECT	distinct first_name, last_name
		,SUM(soi.quantity*soi.list_price*(1-soi.discount)) OVER(PARTITION BY so.staff_id) as amount_of_orders
FROM	sale.staff ss, sale.orders so, sale.order_item soi
WHERE	ss.staff_id=so.staff_id
		and so.order_id=soi.order_id
ORDER BY 3 DESC