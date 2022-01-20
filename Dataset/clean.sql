use DATA_GOTTALENTS
GO

-- clean bảng sale
-- 1. SỬA DỮ LIỆU N/A CỘT SALE_PRICE
UPDATE dbo.Sale 
SET sale_price= CASE WHEN sale_price = 'N/A' THEN '0' ELSE sale_price END
WHERE cus_id IS NOT NULL 
go


-- 2. SỬA DỮ LIỆU CỘT BRAND ( TÊN CÙNG HÃNG & NULL VALUE )
UPDATE dbo.Sale 
SET brand =   CASE	WHEN brand = 'LenovoX1' THEN 'Lenovo' 
					WHEN brand = 'DellXPS' THEN 'Dell'
					WHEN brand IS NULL THEN 'Unknown' 
					ELSE brand END 
GO


-- 3. CHUẨN HOÁ ĐƠN VỊ TIỀN CỘT SALE_PRICE => VNĐ
-- loại bỏ ','
UPDATE dbo.Sale
SET sale_price =  CASE	WHEN sale_price LIKE '%,%' THEN LEFT(sale_price, 2) + SUBSTRING(sale_price, 4,6 )
						ELSE sale_price END 
GO

-- chuẩn hoá số liệu
UPDATE dbo.Sale
SET sale_price =  CASE	WHEN sale_price  = 'N/A' THEN 0 
						WHEN sale_price LIKE '%$%' THEN CAST( SUBSTRING(sale_price, 2, 6) AS INT ) *23000
						WHEN CAST(sale_price AS INT)  > 100000 THEN CAST(sale_price AS INT) 
						WHEN sale_price IS NULL THEN 0 
						ELSE CAST(sale_price AS INT)  * 23000 END
GO

--4. Tách dữ liệu theo các dòng máy tầm trung, cao, thấp => cột price_range
ALTER TABLE dbo.Sale
ADD price_range nvarchar(255);

UPDATE dbo.Sale
SET	 price_range = CASE WHEN sale_price BETWEEN 100000 AND 5000000 THEN '1-5' 
						WHEN sale_price BETWEEN 5000001 AND 10000000 THEN '5-10' 
						WHEN sale_price BETWEEN 10000001 AND 25000000 THEN '10-25'
						WHEN sale_price BETWEEN 25000001 AND 40000000 THEN '25-40'
						WHEN sale_price BETWEEN 40000001 AND 60000000 THEN '40-60'
						WHEN sale_price > 60000000 THEN '60+'
						ELSE 'Unknown' END 
GO

-- 5. Tách dữ liệu cột Reference -> các kênh truyền thông
ALTER TABLE dbo.Sale
ADD ref_nhanvien INT,
	ref_mxh INT,
	ref_web INT,
	ref_friend INT,
	ref_spec INT,
	ref_media INT,
	ref_other INT;

UPDATE dbo.Sale
SET ref_nhanvien =  CASE WHEN ref LIKE N'%nhân viên%' THEN 1 ELSE 0 END,
	ref_mxh = CASE WHEN ref LIKE N'%mạng xã hội%' THEN 1 ELSE 0 END,
	ref_web = CASE WHEN ref LIKE N'%website%' THEN 1 ELSE 0 END,
	ref_friend =  CASE WHEN ref LIKE N'%bạn bè%' THEN 1 ELSE 0 END ,
	ref_spec = CASE WHEN ref LIKE N'%chuyên môn%' THEN 1 ELSE 0 END,
	ref_media = CASE WHEN ref LIKE N'%truyền thông%' THEN 1 ELSE 0 END ,
	ref_other = CASE WHEN ref LIKE N'%Khác%' THEN 1 ELSE 0 END
go

-- 6. Dữ liệu ngày/ tháng/ năm định dạng
--sai dữ liệu
UPDATE dbo.Sale 
SET sale_date = CAST(sale_date AS DATE),
DELETE FROM dbo.Sale 
WHERE	sale_date LIKE '2020-02-30' OR 
		sale_date LIKE '2020-02-31' OR 
		sale_date LIKE '2020-09-31' 

-- tạo cột chứa thứ ngày
ALTER TABLE dbo.Sale
ADD week_day NVARCHAR(255);

UPDATE dbo.Sale
SET week_day = DATEPART(WEEKDAY,sale_date)


DELETE FROM dbo.Sale WHERE cus_id IS NULL
SELECT * FROM dbo.Sale left JOIN dbo.Customer ON sale.cus_id=dbo.Customer.id


