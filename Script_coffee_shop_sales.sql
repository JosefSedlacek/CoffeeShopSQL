--########################################################
--############# Příprava dat, změna datových typů ########


-- Prohlédnout si data a datové typy
SELECT * FROM coffee_shop_data csd;
DESCRIBE coffee_shop_data ;


-- Upravit datový typ pro transaction_date
ALTER TABLE coffee_shop_data ADD trnsc_date DATE;

UPDATE coffee_shop_data 
SET trnsc_date = STR_TO_DATE(transaction_date, '%d.%m.%Y');

ALTER TABLE coffee_shop_data DROP COLUMN transaction_date;

ALTER TABLE coffee_shop_data
CHANGE COLUMN trnsc_date transaction_date DATE;

-- Upravid datový typ pro transaction_time
ALTER TABLE coffee_shop_data ADD new_transaction_time TIME;

UPDATE coffee_shop_data
SET new_transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');
ALTER TABLE coffee_shop_data DROP COLUMN transaction_time;
ALTER TABLE coffee_shop_data CHANGE COLUMN new_transaction_time transaction_time TIME;

-- Upravit datový typ pro unit_price
ALTER TABLE coffee_shop_data ADD new_unit_price DOUBLE;

UPDATE coffee_shop_data
SET new_unit_price = CAST(REPLACE(unit_price, ',', '.') AS DOUBLE);
ALTER TABLE coffee_shop_data DROP COLUMN unit_price;
ALTER TABLE coffee_shop_data CHANGE COLUMN new_unit_price unit_price DOUBLE;

-- Kontrola datových typů
DESCRIBE coffee_shop_data;


--########################################################
--###################### Analýza dat #####################

SELECT *
FROM coffee_shop_data;

-- Zjistěte celkové prodeje za měsíc květen
SELECT 
	ROUND(SUM(unit_price * transaction_qty)) AS total_sales
FROM coffee_shop_data
WHERE 
	MONTH (transaction_date) = 5 -- květen;

-- Zjistěte, jestli prodeje meziměsíčně rostly nebo klesaly
-- vybraný měsíc ..... VM = květen = 5
-- předchozí měsíc ... PM = duben = 4
-- "mzms" = "meziměsíčně"
SELECT 
	MONTH(transaction_date) AS MONTH, -- číslo měsíce
	ROUND(SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty),1)   -- rozdíl prodejů meziměsíčně
	OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty),1)  -- vydělení předchozím měsícem
	OVER (ORDER BY MONTH(transaction_date))*100 AS mzms_increase_percentage              -- nárůst nebo pokles procentuálně
FROM 
	coffee_shop_data
WHERE 
	MONTH (transaction_date) IN (4,5) -- duben květen
GROUP BY 
	MONTH (transaction_date)
ORDER BY 
	MONTH (transaction_date);

-- Zjistěte celkový počet objednávek
SELECT count(transaction_id) AS total_orders
FROM coffee_shop_data csd 
WHERE 
	MONTH (transaction_date) = 5; -- květen


-- Zjistěte, jestli počet objednávek meziměsíčně roste nebo klesá
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(COUNT(transaction_id)) AS total_orders,
    (COUNT(transaction_id) - LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mzms_increase_percentage
FROM 
    coffee_shop_data
WHERE 
    MONTH(transaction_date) IN (4, 5) -- duben a květen
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);


-- Zjistěte počet transakcí za květen
SELECT SUM(transaction_qty) as Total_Quantity_Sold
FROM coffee_shop_data
WHERE MONTH(transaction_date) = 5; -- květen


-- Zjistěte, zda celkové transakce meziměsíčně rostou nebo klesají
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_qty)) AS total_quantity_sold,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mzms_increase_percentage
FROM 
    coffee_shop_data
WHERE 
    MONTH(transaction_date) IN (4, 5)   -- duben a květen
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);


-- Kalendářní data, konkrétně 27.5
SELECT
    SUM(unit_price * transaction_qty) AS total_sales,
    SUM(transaction_qty) AS total_quantity_sold,
    COUNT(transaction_id) AS total_orders
FROM 
    coffee_shop_data
WHERE 
    transaction_date = '2023-05-27'; -- datum 27 květen


-- Zjistěte, jaký je trend v prodejích za květen
SELECT ROUND(AVG(total_sales),2) AS average_sales
FROM (
    SELECT 
        SUM(unit_price * transaction_qty) AS total_sales
    FROM 
        coffee_shop_data
	WHERE 
        MONTH(transaction_date) = 5
    GROUP BY 
        transaction_date
) AS internal_query;


-- Zjistěte, jaké byly prodeje v každém dni za vybraný měsíc (květen)
SELECT 
    DAY(transaction_date) AS day_of_month,
    ROUND(SUM(unit_price * transaction_qty),1) AS total_sales
FROM 
    coffee_shop_data
WHERE 
    MONTH(transaction_date) = 5
GROUP BY 
    DAY(transaction_date)
ORDER BY 
    DAY(transaction_date);



-- Pro každý den určete, jestli jsou prodeje nad nebo pod průměrem
SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Nadprůměrné'
        WHEN total_sales < avg_sales THEN 'Podprůměrné'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffee_shop_data
    WHERE 
        MONTH(transaction_date) = 5
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;


-- Porovnejte data - jsou výrazné rozdíly v prodejích mezi pracovními dny a víkendem ?
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
    ROUND(SUM(unit_price * transaction_qty),2) AS total_sales
FROM 
    coffee_shop_data
WHERE 
    MONTH(transaction_date) = 5
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END;


-- Zjistěte, jak se liší prodeje v různých prodejnách
SELECT 
	store_location,
	SUM(unit_price * transaction_qty) as Total_Sales
FROM coffee_shop_data
WHERE
	MONTH(transaction_date) =5 
GROUP BY store_location
ORDER BY 	
	SUM(unit_price * transaction_qty) DESC;



-- Zjistěte, jaké kategorie produktů se prodávají nejlépe
SELECT 
	product_category,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM coffee_shop_data
WHERE
	MONTH(transaction_date) = 5 
GROUP BY product_category
ORDER BY 
	SUM(unit_price * transaction_qty) DESC;



-- Které konrkétní produkty se nejlépe prodávají ?
SELECT 
	product_type,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM coffee_shop_data
WHERE
	MONTH(transaction_date) = 5 
GROUP BY product_type
ORDER BY 
	SUM(unit_price * transaction_qty) DESC
LIMIT 10;



-- Mapujte prodeje za dny v týdnu a za jednotlivé hodiny. 
-- Který čas je pro kavárny nejvýdělečnější ?
SELECT 
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales,
    SUM(transaction_qty) AS Total_Quantity,
    COUNT(*) AS Total_Orders
FROM 
    coffee_shop_data
WHERE 
    DAYOFWEEK(transaction_date) = 3 -- den úterý
    AND HOUR(transaction_time) = 8 -- hodina osmá ranní
    AND MONTH(transaction_date) = 5; -- květen


-- Zjistit pro kazdý jednotlivý den:
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Pondělí'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Úterý'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Středa'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Čtvrtek'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Pátek'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Sobota'
        ELSE 'Neděle'
    END AS den_tydne,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_data
WHERE 
    MONTH(transaction_date) = 5
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Pondělí'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Úterý'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Středa'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Čtvrtek'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Pátek'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Sobota'
        ELSE 'Neděle'
    END;


-- Získat data o jednotlivých časech přes den
-- Otevírací doba je od 6 ráno do 8 večer
SELECT 
    HOUR(transaction_time) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_data
WHERE 
    MONTH(transaction_date) = 5
GROUP BY 
    HOUR(transaction_time)
ORDER BY 
    HOUR(transaction_time);
