--DEÐÝÞKEN TANIMLAMA
--SQL de deðiþken tanýmlarken kullanýlan komut DECLARE dir.

DECLARE @ISIM AS VARCHAR(100) --deðiþkenin adýný yazarken @ kullanýlýr ve sonrasýnda deðiþkenin tipini yazarýz.

--Þimdi bu deðiþkenin deðerini çekelim

SELECT @ISIM  --@ISIM deðiþkenini bir deðer atamadýðýmýz için NULL olarak getirir.

--Deðiþkeni tanýmlarken ayný anda baþlangýç deðeri atayabiliriz.
DECLARE @ISIM AS VARCHAR(100) ='matrix'
SELECT @ISIM

--ya da deðiþkeni tanýmlayýp, sonradan deðer atayabiliriz:
DECLARE @ISIM AS VARCHAR(100)
SET @ISIM='matrix'
SELECT @ISIM

--Sayýsal bir deðiþken tanýmlayalým:

DECLARE @SAYI AS INTEGER
SET @SAYI=15
SELECT @SAYI

--Birden fazla deðiþken atayalým

DECLARE 
@SAYI1 AS INTEGER,
@SAYI2 AS INTEGER
SET @SAYI1=10
SET @SAYI2=20
SELECT @SAYI1,@SAYI2

--VEYA

DECLARE @SAYI1 AS INTEGER
SET @SAYI1=10
DECLARE @SAYI2 AS INTEGER
SET @SAYI2=20
SELECT @SAYI1 AS SAYI_1,@SAYI2 AS SAYI_2, @SAYI1 + @SAYI2 AS TOPLAM

--Toplamý da bir deðiþkene atayabiliriz:

DECLARE @SAYI1 AS INTEGER
SET @SAYI1=10
DECLARE @SAYI2 AS INTEGER
SET @SAYI2=20
DECLARE @TOPLAM AS INTEGER
SET @TOPLAM = @SAYI1 + @SAYI2

SELECT @SAYI1 AS SAYI_1,@SAYI2 AS SAYI_2, @TOPLAM AS TOPLAM
--Yukarýdaki select ifadesini tek baþýna çalýþtýrdýðýmýzda hata verecektir.

--Birden fazla deðiþken tanýmlamanýn bir diðer yolu:

DECLARE 
@SAYI1 AS INTEGER,
@SAYI2 AS INTEGER,
@TOPLAM AS INTEGER
SET @SAYI1=10
SET @SAYI2=20
SET @TOPLAM = @SAYI1 + @SAYI2
SELECT @SAYI1 AS SAYI_1,@SAYI2 AS SAYI_2, @TOPLAM AS TOPLAM

--Her seferde declare yazdýýðýmýz gibi tek seferde declare yazýp deðiþkenlere deðerler atayabiliriz.
--Þu ana kadar deðiþkenlere statik deðerler atadýk.
--Ayný þekilde veri tablolarýndan dönen deðerleri de deðiþkenlere atayabiliriz.

USE SampleRetail
GO

SELECT * FROM sale.customer

DECLARE 
@first_name AS VARCHAR(255), --1 NOLU KÝÞÝNÝN ADINI,SOYADINI VE TELEFON NUMARASINI DEÐÝÞKENLERE ATAYALIM
@last_name AS VARCHAR(255),
@phone AS VARCHAR(25)

SELECT @first_name=first_name, @last_name = last_name, @phone = phone
FROM sale.customer 
WHERE customer_id = 1
--Buraya kadar sorgu çekmiyoruz yalnýzca tablodan dönen bir deðeri deðiþkene atýyoruz.
--Þimdi deðiþkenlere atadýðýmýz deðerleri çekelim:
SELECT @first_name, @last_name, @phone

--Tablodan birden fazla deðer dönerse son deðeri alýr:
DECLARE 
@first_name AS VARCHAR(255), --1 NOLU KÝÞÝNÝN ADINI,SOYADINI VE TELEFON NUMARASINI DEÐÝÞKENLERE ATAYALIM
@last_name AS VARCHAR(255),
@phone AS VARCHAR(25)

SELECT @first_name=first_name, @last_name = last_name, @phone = phone
FROM sale.customer 
--WHERE customer_id = 1

SELECT @first_name, @last_name, @phone


--Bir tane de datetime türünde bir deðiþken tanýmlayalým:

DECLARE @TARIH AS DATETIME
SET @TARIH = GETDATE()

SELECT @TARIH










