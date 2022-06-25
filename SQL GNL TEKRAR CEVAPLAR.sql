
------------------------------------------KOLAY GELSÝN.----------------------------------------------------------------------
--SORULAR YAPTIÐINIZ SORULAR OLABÝLÝR, FARKLI YAKLAÞIMLARLA ÇÖZÜME ULAÞMAYI DA DENERSENÝZ PERÞEMBE GÜNÜ ÜZERÝNDEN GEÇEBÝLÝRÝZ.
-----------------------------------------------------------------------------------------------------------------------------

--1. SORU 
--Write a query that returns the customer name who buy the product named "Apple iPod Touch 128GB Blue".
SELECT DISTINCT SC.first_name, SC.last_name
FROM product.product PP, sale.order_item SI, sale.orders SO, sale.customer SC
WHERE PP.product_id = SI.product_id AND SI.order_id = SO.order_id AND SO.customer_id = SC.customer_id 
	AND PP.product_name = 'Apple iPod Touch 128GB Blue'


--2. SORU 
--Write a query that returns top 100 customer and their order information together for all customers. Maybe customers don't have any order.
SELECT *
FROM sale.customer SC
LEFT JOIN sale.orders SO -- OR FULL OUTER JOIN
	ON SC.customer_id = SO.customer_id

--3. SORU
--Write a query that returns 1st and 2nd degree managers of all staff.
--Manager1 ilk amiri olacak, Manager2 ilk amirin amiri olacak ve Manager2 null olanlar yer almayacak

SELECT A.staff_id, A.first_name, A.last_name, B.first_name AS manager1, C.first_name as manager2
FROM sale.staff A, sale.staff B, sale.staff C
WHERE A.manager_id = B.staff_id AND B.manager_id =C.staff_id
ORDER BY  B.staff_id, C.staff_id
SELECT * FROM sale.staff


--4. SORU 
--Brand, Category ve Model Year'a göre Tekli, 2li ve 3lü gruplarda olmak üzere ortalama fatura tutarlarýný bulunuz.
--Tekli, 2li ve 3lü gruptan kasýt, Brand, Category ve Model year, Brand ve Category, Brand ve Model Year .... gibi 
--toplu, 2li ve tekli avg fatura tutarlarýný bulmaktýr.
SELECT PB.brand_name, PC.category_name, PP.model_year, AVG(SO.list_price*SO.quantity*(1-SO.discount)) AS avg_invoice
FROM product.product PP, product.brand PB, product.category PC, sale.order_item SO
WHERE PP.brand_id = PB.brand_id AND PP.category_id = PC.category_id AND PP.product_id = SO.product_id
GROUP BY 
	CUBE (PB.brand_name, PC.category_name, PP.model_year) 
--GROUPING SETS ((PB.brand_name, PC.category_name, PP.model_year),(PB.brand_name),(PC.category_name),(PP.model_year),
--(PB.brand_name, PC.category_name),(PB.brand_name, PP.model_year),(PC.category_name, PP.model_year),())




--5. SORU 
--Write a query that returns the count of orders of each day in 2018,2019 and 2020. Report the result using Pivot Table.
--The column names should be day names (Sun, Mon, etc.).
SELECT *
FROM(
SELECT YEAR(order_date)year_ ,DATENAME(WEEKDAY,order_date) day_, order_id
FROM sale.orders
) as table1
PIVOT(
count(order_id)
FOR day_ IN([Monday],[Tuesday],[Wednesday],[Thursday],[Friday],[Saturday],[Sunday])) as sonuc
ORDER BY year_


--6. SORU 
--Detect the store that does not have a product named "Samsung Galaxy Tab S3 Keyboard Cover" in its stock. (Paste the store name in the box below.)
SELECT DISTINCT SS.store_id, SS.store_name
FROM product.stock PS , sale.store SS
WHERE SS.store_id= PS.store_id
EXCEPT
SELECT DISTINCT SS.store_id, SS.store_name
FROM product.stock PS, product.product PP, sale.store SS
WHERE PP.product_id = PS.product_id  AND SS.store_id= PS.store_id AND PP.product_name = 'Samsung Galaxy Tab S3 Keyboard Cover'


--2. yol
SELECT DISTINCT A.store_id
FROM product.stock A 
WHERE NOT EXISTS(
SELECT DISTINCT PS.store_id
FROM product.stock PS, product.product PP
WHERE PP.product_id = PS.product_id AND PP.product_name = 'Samsung Galaxy Tab S3 Keyboard Cover' AND A.store_id = PS.store_id)
--7. SORU 
--Sadece 2018,2019 ve 2020 yýllarýn 3ünde de sipariþ verilen ürünlerin hangi yýl kaçar kere sipariþ edildiðini ürün id, ad ve yýllar ile
--birlikte pivot table ile getiriniz.
SET STATISTICS IO ON
SELECT *
FROM(
SELECT PP.product_id, PP.product_name, YEAR(SO.order_date) AS year_, PP.product_id AS id
FROM sale.orders SO, sale.order_item SI, product.product PP
WHERE SO.order_id = SI.order_id AND SI.product_id = PP.product_id AND SI.product_id IN 
(
SELECT PP.product_id
FROM sale.orders SO, sale.order_item SI, product.product PP
WHERE SO.order_id = SI.order_id AND SI.product_id = PP.product_id AND YEAR(SO.order_date) = 2018
INTERSECT
SELECT PP.product_id
FROM sale.orders SO, sale.order_item SI, product.product PP
WHERE SO.order_id = SI.order_id AND SI.product_id = PP.product_id AND YEAR(SO.order_date) = 2019
INTERSECT
SELECT PP.product_id
FROM sale.orders SO, sale.order_item SI, product.product PP
WHERE SO.order_id = SI.order_id AND SI.product_id = PP.product_id AND YEAR(SO.order_date) = 2020
)) AS table1
PIVOT(
COUNT(id)
FOR year_ IN ([2018],[2019],[2020])
) AS pivot2


--2. yol
SELECT PP.product_id, PP.product_name, YEAR(SO.order_date) AS year_, PP.product_id AS id
INTO #temp2
FROM sale.orders SO, sale.order_item SI, product.product PP
WHERE SO.order_id = SI.order_id AND SI.product_id = PP.product_id
SET STATISTICS IO ON
SELECT *
FROM(
SELECT * FROM #temp2 where product_id IN  (
SELECT product_id FROM #temp2 WHERE year_ = 2018
INTERSECT
SELECT product_id FROM #temp2 WHERE year_ = 2019
INTERSECT
SELECT product_id FROM #temp2 WHERE year_ = 2020)) AS table2
PIVOT(
COUNT(id)
FOR year_ IN ([2018],[2019],[2020])
) AS pivot2


--3. yol
CREATE VIEW view1 AS( 
SELECT PP.product_id, PP.product_name, YEAR(SO.order_date) AS year_, PP.product_id AS id
FROM sale.orders SO, sale.order_item SI, product.product PP
WHERE SO.order_id = SI.order_id AND SI.product_id = PP.product_id)
SET STATISTICS IO ON
SELECT *
FROM(
SELECT * FROM view1 where product_id IN  (
SELECT product_id FROM view1 WHERE year_ = 2018
INTERSECT
SELECT product_id FROM view1 WHERE year_ = 2019
INTERSECT
SELECT product_id FROM view1 WHERE year_ = 2020)) AS table2
PIVOT(
COUNT(id)
FOR year_ IN ([2018],[2019],[2020])
) AS pivot2





--8. SORU
--Classify staff according to the count of orders they receive as follows:
--a) 'High-Performance Employee' if the number of orders is greater than 400
--b) 'Normal-Performance Employee' if the number of orders is between 100 and 400
--c) 'Low-Performance Employee' if the number of orders is between 1 and 100
--d) 'No Order' if the number of orders is 0
--Then, list the staffs first name, last name, employee class, and count of orders.  (Count of orders and first names in ascending order)
--1.çözüm
SELECT SS.staff_id, SS.first_name, SS.last_name, SS.active ,(SELECT COUNT(*) FROM sale.orders WHERE staff_id = SS.staff_id ) as order_count,
CASE
	WHEN (SELECT COUNT(*) FROM sale.orders WHERE staff_id = SS.staff_id ) > 400 THEN 'High-Performance Employee'
	WHEN (SELECT COUNT(*) FROM sale.orders WHERE staff_id = SS.staff_id ) BETWEEN 100 AND 400 THEN 'Normal-Performance Employee'
	WHEN (SELECT COUNT(*) FROM sale.orders WHERE staff_id = SS.staff_id ) BETWEEN 1 AND 99 THEN 'Low-Performance Employee'
	ELSE 'No Order'
	END AS staff_position
FROM sale.staff SS
GROUP BY SS.staff_id, SS.first_name, SS.last_name, SS.active
ORDER BY order_count, SS.first_name ASC

--2.çözüm
SELECT first_name, last_name, COUNT(order_id) as order_count,
CASE
	WHEN COUNT(order_id) > 400 THEN 'High-Performance Employee'
	WHEN COUNT(order_id) BETWEEN 100 AND 400 THEN 'Normal-Performance Employee'
	WHEN COUNT(order_id) BETWEEN 1 AND 99 THEN 'Low-Performance Employee'
	WHEN COUNT(order_id) = 0 THEN 'No Order'
	END AS staff_position
FROM sale.staff SS
LEFT JOIN sale.orders SO
	ON SO.staff_id = SS.staff_id
GROUP BY first_name, last_name
ORDER BY order_count, first_name ASC



--9.SORU 
--List counts of orders on the weekend and weekdays. Submit your answer in a single row with two columns. Weekday and Weekend
--1. çözüm
SELECT SUM(IIF(DATEPART(WEEKDAY, order_date) IN (2,3,4,5,6), 1,0)) AS weekday_ ,
--SUM(IIF(DATEPART(WEEKDAY, order_date) IN (7,1), 1,0)) AS weekend
COUNT(*) - SUM(IIF(DATEPART(WEEKDAY, order_date) IN (2,3,4,5,6), 1,0)) AS weekend
FROM sale.orders


--2. çözüm
select *
from (
	select	case 
				when DATEname(DW, [order_date]) in ('Sunday','Saturday') then 'weekend'
				else 'weekday'
			end week_
	from sale.orders) A

PIVOT ( 
		count(week_)
		for week_ in ([weekend],[weekday])
) PVT




--10. SORU 
--List customers ordered pruducts in the computer accessories, speakers and mp4 palyer categories in the same order 
SELECT SC.customer_id, SC.first_name, SC.last_name, SO.order_id
FROM product.product PP, product.category PC, sale.order_item SI, sale.orders SO, sale.customer SC
WHERE PP.category_id = PC.category_id AND PP.product_id = SI.product_id AND SI.order_id = SO.order_id AND SO.customer_id = SC.customer_id 
AND PC.category_name = 'computer accessories'
INTERSECT
SELECT SC.customer_id, SC.first_name, SC.last_name, SO.order_id
FROM product.product PP, product.category PC, sale.order_item SI, sale.orders SO, sale.customer SC
WHERE PP.category_id = PC.category_id AND PP.product_id = SI.product_id AND SI.order_id = SO.order_id AND SO.customer_id = SC.customer_id AND
	PC.category_name = 'speakers'
INTERSECT
SELECT SC.customer_id, SC.first_name, SC.last_name, SO.order_id
FROM product.product PP, product.category PC, sale.order_item SI, sale.orders SO, sale.customer SC
WHERE PP.category_id = PC.category_id AND PP.product_id = SI.product_id AND SI.order_id = SO.order_id AND SO.customer_id = SC.customer_id AND
	PC.category_name = 'mp4 player'

--11. SORU 
--List the store names in ascending order that did not have an order between "2018-07-22" and "2018-07-28".
SELECT DISTINCT store_id
FROM sale.orders
EXCEPT
SELECT DISTINCT store_id
FROM sale.orders
WHERE order_date BETWEEN '2018-07-22' AND '2018-07-28'

--2. ÇÖZÜM
SELECT DISTINCT store_id
FROM sale.orders B
WHERE NOT EXISTS(
SELECT DISTINCT store_id
FROM sale.orders 
WHERE B.store_id = store_id AND order_date BETWEEN '2018-07-22' AND '2018-07-28' )

-- 12. SORU
-- Herbir categorinin en çok satýldýðý yýlýn tespit edildiði ve
-- Herbir categoriye ait kaç farklý ürün bulunduðunu da ayrý bir CTE sorgusunda tanýmlayýnýz.
-- Bu sorgularý kullanarak  Game, Computer Accessories ve mp4 player categorilerine ait en fazla satýþ yapýlan yýlý ve
-- toplam ürün sayýsýný (product tablosundaki) ayný sql sorgusunda döndürünüz.


WITH CTE1 AS(
SELECT *
FROM(
SELECT PP.category_id, PC.category_name, YEAR(SO.order_date) AS yýl ,COUNT(*) AS satýs_sayisi,ROW_NUMBER() OVER(PARTITION BY PP.category_id ORDER BY COUNT(*) DESC) AS rownumber
FROM  product.product PP, sale.order_item SI, sale.orders SO, product.category PC
WHERE PP.product_id = SI.product_id AND SI.order_id = SO.order_id AND PP.category_id = PC.category_id
GROUP BY  PP.category_id, PC.category_name, YEAR(SO.order_date)) as table3
WHERE rownumber = 1),
CTE2 AS(
SELECT PP.category_id, PC.category_name, COUNT(*) AS toplam_urun
FROM product.product PP, product.category PC
WHERE PP.category_id = PC.category_id
GROUP BY PP.category_id, PC.category_name
)
SELECT B.category_id, B.category_name, B.yýl, B.satýs_sayisi, C.toplam_urun
FROM CTE1 B, CTE2 C
WHERE B.category_id = C.category_id AND B.category_name IN ('Game','Computer Accessories','mp4 player')







