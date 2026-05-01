create database final_depi
use final_depi

select * from coustmer

select * from sales

select * from proudcts

select * from suppliers

select * from orders

select * from Returns

select * from inventory

alter table Returns
add constraint fk_returen_order
foreign key (Order_ID) references orders; 

 alter table inventory
add constraint fk_inventory_p
foreign key (SKU) references proudcts; 

 alter table orders
add constraint fk_orders_p
foreign key (SKU) references proudcts;

 alter table sales
add constraint fk_sales_p
foreign key (SKU) references proudcts;



 alter table orders
add constraint fk_orders_s
foreign key (Supplier_ID) references suppliers;

 alter table orders
add constraint fk_orders_c
foreign key (Customer_ID) references coustmer;

 alter table returen
 alter column Return_ID nvarchar(50)  not null ;
 
 alter table [Returns]
add constraint Pk_returen
primary key (Return_ID)  ;

SELECT *
FROM [dbo].[coustmer]
WHERE Customer_ID IS NULL;

SELECT *
FROM [dbo].[sales]
WHERE Sale_ID IS NULL;

SELECT *
FROM [dbo].[proudcts]
WHERE SKU IS NULL;

SELECT *
FROM [dbo].[suppliers]
WHERE Supplier_ID IS NULL;

SELECT *
FROM [dbo].[orders]
WHERE Order_ID IS NULL;

SELECT *
FROM [dbo].[Returns]
WHERE Return_ID IS NULL;

SELECT 
    COUNT(*) - COUNT(Supplier_ID) AS Supplier_ID_Nulls,
    COUNT(*) - COUNT(Supplier_Name) AS Supplier_Name_Nulls,
    COUNT(*) - COUNT(Phone) AS Phone_Nulls,
    COUNT(*) - COUNT(City) AS City_Nulls,
    COUNT(*) - COUNT(Country) AS Country_Nulls,
    COUNT(*) - COUNT(Rating) AS Rating_Nulls,
    COUNT(*) - COUNT(On_Time_Delivery) AS Delivery_Nulls
FROM suppliers;

update coustmer set 
Customer_ID = TRIM([Customer_ID]) , 
Customer_Name = TRIM([Customer_Name]) ,
email = TRIM([email])  

UPDATE sales SET 
    Selling_Price = ROUND(Selling_Price, 2),
    Total_Revenue = ROUND(Total_Revenue, 2),
    Region = UPPER(Region);

UPDATE proudcts SET 
    Product_Name = TRIM(Product_Name),
    Selling_Price = ROUND(Selling_Price, 2),
    Avg_Price = ROUND(Avg_Price, 2),
    category = UPPER(category);

    UPDATE suppliers SET 
    Supplier_Name = TRIM(Supplier_Name),
    Rating = ROUND(Rating, 2);

UPDATE orders SET 
    Unit_Cost      = ROUND(Unit_Cost, 2),
    Selling_Price  = ROUND(Selling_Price, 2),
    Total_Revenue  = ROUND(Total_Revenue, 2),
    Profit         = ROUND(Profit, 2);
    
    UPDATE Returns SET 
    Refund_Amount = ROUND(Refund_Amount, 2);

select sum(Total_orders) AS SUM_ORDERS from coustmer --cards--
SELECT 
    SUM(Quantity_Sold) AS SUM_Quantity,
    SUM(Selling_Price) AS SUM_Selling,
    SUM(Total_Revenue) AS SUM_Revenue
FROM sales; --cards--



select max(Total_orders) AS max_ORDERS from coustmer --cards--
SELECT 
    MAX(Quantity_Sold) AS max_Quantity,
    MAX(Selling_Price) AS max_selling,
    MAX(Total_Revenue) AS max_revenue
   
FROM sales;


select min(Total_orders) AS min_ORDERS from sales
 
select min(Quantity_Sold) AS min_Quantity , --cards--
 min(Selling_Price) AS min_selling ,
 min(Total_Revenue) AS min_revenue 
from sales --cards--

-- top 10 proudect by revenu --
SELECT TOP 10 p.Product_Name, SUM(s.Total_Revenue) AS Total_Revenue
FROM sales s
JOIN proudcts p ON s.SKU = p.SKU
GROUP BY p.Product_Name
ORDER BY Total_Revenue DESC;

-- total profit by supplier--
SELECT s.Supplier_Name,
       COUNT(o.Order_ID)   AS total_orders,
       SUM(o.Profit) AS total_profit
FROM   Orders  o
INNER JOIN Suppliers s ON o.Supplier_ID = s.Supplier_ID
GROUP BY s.Supplier_Name
ORDER BY total_profit DESC;

-- TOTAL PROFIT BY PROUDECT --
SELECT 
    P.Product_Name,
    COUNT(O.Order_ID) AS total_orders,
    SUM(O.Profit) AS total_profit
FROM Orders O
INNER JOIN proudcts P
    ON O.SKU = P.SKU
GROUP BY P.Product_Name
ORDER BY total_profit DESC;

-- TOTAL PROFIT BY category wronng -- 

SELECT P.Product_Name, COUNT(O.Order_ID) AS total_orders,
COUNT(P.category) AS category FROM Orders O
INNER JOIN proudcts P
ON O.SKU = P.SKU
GROUP BY P.Product_Name
ORDER BY category DESC;

-- sales revnue by category --
SELECT p.category, COUNT(sa.Sale_ID) AS num_sales,
SUM(sa.Total_Revenue) AS revenue FROM Sales sa
INNER JOIN proudcts p 
ON sa.SKU = p.SKU
GROUP BY p.category
ORDER BY revenue DESC;

-- COUSTMER BY TOTAL SPENT  --
SELECT 
    c.Customer_Name,
    c.Email,
    ROUND(SUM(o.Total_Revenue), 2) AS total_spent
FROM coustmer c
INNER JOIN Orders o 
    ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_Name, c.Email
ORDER BY total_spent DESC;

-- Proudect return --  

SELECT p.Category, COUNT(r.Return_ID) AS total_returns,
SUM(r.Refund_Amount) AS total_refund FROM Returns r
INNER JOIN Orders o ON r.Order_ID = o.Order_ID
INNER JOIN proudcts p ON o.SKU = p.SKU
GROUP BY p.Category
ORDER BY total_refund DESC;


-- 



SELECT customer_name , COUNT(Total_orders) AS transaction_count
FROM coustmer
GROUP BY customer_name;


SELECT * from coustmer
where Addres = 'Street 1, City 4'


select * from [dbo].[coustmer] as C 
join [dbo].[proudcts] as p
ON c.Customer_ID = c.Customer_ID