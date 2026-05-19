create database final_depii
use final_depii

select * from customers

select * from sales

select * from proudct

select * from suppliers

select * from orders

select * from returns

select * from inventory

 

SELECT * from sales
where order_id = 'ORD-3'


SKU-123

SELECT * from orders
where SKU = 'SKU-123'


-- orders → customers
ALTER TABLE orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY (Customer_ID) REFERENCES customers(Customer_ID);

-- orders → suppliers
ALTER TABLE orders
ADD CONSTRAINT fk_orders_supplier
FOREIGN KEY (Supplier_ID) REFERENCES suppliers(Supplier_ID);

-- orders → products
ALTER TABLE orders
ADD CONSTRAINT fk_orders_product
FOREIGN KEY (SKU) REFERENCES proudct(SKU);



-- sales → orders
ALTER TABLE sales
ADD CONSTRAINT fk_sales_order
FOREIGN KEY (Order_ID) REFERENCES orders(Order_ID);

-- sales → products
ALTER TABLE sales
ADD CONSTRAINT fk_sales_product
FOREIGN KEY (SKU) REFERENCES proudct(SKU);

-- returns → orders
ALTER TABLE returns
ADD CONSTRAINT fk_returns_order
FOREIGN KEY (Order_ID) REFERENCES orders(Order_ID);

-- inventory → products
ALTER TABLE inventory
ADD CONSTRAINT fk_inventory_product
FOREIGN KEY (SKU) REFERENCES proudct(SKU);

-- clean customers
update customers set 
Customer_ID = TRIM([Customer_ID]) , 
Customer_Name = TRIM([Customer_Name]) ,
email = TRIM([email])  

-- clean sales
UPDATE sales SET 
    Selling_Price = ROUND(Selling_Price, 2),
    Total_Revenue = ROUND(Total_Revenue, 2),
    Region = UPPER(Region);

    -- clean proudect
UPDATE proudct SET 
    Product_Name = TRIM(Product_Name),
    Selling_Price = ROUND(Selling_Price, 2),
    Purchase_Price = ROUND(Purchase_Price, 2),
    Avg_Price = ROUND(Avg_Price, 2),
    category = UPPER(category);

    -- clean suppliers
    UPDATE suppliers SET 
    Supplier_Name = TRIM(Supplier_Name),
    Rating = ROUND(Rating, 2);

    -- clean orders
    UPDATE orders SET 
    Unit_Cost      = ROUND(Unit_Cost, 2),
    Selling_Price  = ROUND(Selling_Price, 2),
    Total_Revenue  = ROUND(Total_Revenue, 2),
    Total_Cost  = ROUND(Total_Cost, 2),
      Profit = ROUND(Profit, 2);
       
     -- clean Returns
    UPDATE Returns SET 
    Refund_Amount = ROUND(Refund_Amount, 2),
    Selling_Price  = ROUND(Selling_Price, 2);





-- customers
select * from [dbo].[customers]
-- kpis
SELECT 
    COUNT(*) AS Total_Customers,
    SUM(Total_Orders) AS Total_Orders,
    CONCAT(AVG(Total_Orders), '%') AS Avg_Discount,
    MAX(Total_Orders) AS Highest_Orders,
    MIN(Total_Orders) AS Lowest_Orders
FROM customers;

-- Most total_orders Used Products

SELECT Favorite_Product, SUM(Total_Orders) AS total_orders
FROM customers
GROUP BY Favorite_Product;




--sales
select * from [dbo].[sales]
-- kpi 
SELECT
  COUNT(*) AS total_orders,
  ROUND(SUM(Total_Revenue), 2) AS total_revenue,
  ROUND(AVG(Total_Revenue), 2) AS avg_order_value,
  SUM(Final_Qty) AS total_units_sold,
  SUM(Total_Revenue) / SUM(Final_Qty) AS revenue_per_unit
FROM sales;

-- sales by region --

SELECT
  Region,
  COUNT(*) AS Total_Orders,
  SUM(Final_Qty) AS Total_Qty,
  SUM(Total_Revenue) AS Total_Revenue,
  AVG(Selling_Price) AS Avg_Price
FROM sales
GROUP BY Region


-- sales by discount %%
SELECT
  Discount,
  COUNT(*) AS Total_Orders,
  ROUND(SUM(Total_Revenue), 2) AS Total_Revenue,
  ROUND(AVG(Final_Qty), 2) AS Avg_Qty
FROM sales
GROUP BY Discount
ORDER BY Discount ASC;

-- revune by region 
SELECT
  Region,
  ROUND(SUM(Total_Revenue), 2) AS Total_Revenue
FROM sales
GROUP BY Region
HAVING SUM(Total_Revenue) > 10000
ORDER BY Total_Revenue DESC;

-- proudect 
-- kpi
SELECT
  COUNT(*) AS total_skus,
  COUNT(DISTINCT Category) AS total_categories,
  SUM(Stock_Qty) AS total_stock_units,
  ROUND(AVG(Selling_Price), 2) AS avg_selling_price,
  ROUND(AVG(Purchase_Price), 2) AS avg_purchase_price,
  ROUND(
    (AVG(Selling_Price) - AVG(Purchase_Price))
    / AVG(Selling_Price) * 100, 1
  ) AS overall_margin_pct,
  ROUND(SUM(Stock_Qty * Selling_Price), 2) AS total_sell_value,
  ROUND(SUM(Stock_Qty * Purchase_Price), 2) AS total_cost_value
FROM proudct;

--average purchase price by category
SELECT
  Category,
  COUNT(*) AS total_skus,
  SUM(Stock_Qty) AS total_stock,
  AVG(Purchase_Price) AS avg_purchase_price,
  AVG(Selling_Price) AS avg_selling_price,
  AVG(Avg_Price) AS avg_market_price
FROM proudct
GROUP BY Category

--Profit margin by category
SELECT 
    Category,

    ROUND(AVG(Selling_Price - Purchase_Price), 2) AS avg_gross_profit,

    ROUND(
        (
            AVG(Selling_Price) - AVG(Purchase_Price)
        ) / NULLIF(AVG(Selling_Price), 0) * 100,
        1
    ) AS margin_pct

FROM proudct
GROUP BY Category

-- Stock value by category wrong 

SELECT
  Category,
  SUM(Stock_Qty) AS total_units,
  ROUND(SUM(Stock_Qty * Purchase_Price), 2) AS stock_cost_value,
  ROUND(SUM(Stock_Qty * Selling_Price), 2) AS stock_sell_value
FROM proudct
GROUP BY Category

-- Low stock alert by category

SELECT
  Category,
  SKU,
  Product_Name,
  Stock_Qty
FROM proudct
WHERE Stock_Qty < 300



-- order
SELECT DISTINCT Discount
FROM orders
WHERE TRY_CAST(Discount AS FLOAT) IS NULL

SELECT
    COUNT(*) AS num_order_id,    
    SUM(Ordered_Qty) AS total_Ordered_Qty,
    ROUND(SUM(unit_cost), 2) AS total_unit_cost,
AVG(
        TRY_CAST(
            REPLACE(Discount, '%', '') AS FLOAT
        )
    ) AS Avg_Discount,    ROUND(SUM(Total_Revenue), 2) AS Total_Revenue,
    ROUND(SUM(Total_cost), 2) AS sum_Total_cost, 
    ROUND(SUM(profit), 2) AS Total_profit
FROM orders;
-----------------------------------------------------------

UPDATE orders
SET Discount = REPLACE(Discount, '%', '');

ALTER TABLE orders
ALTER COLUMN Discount FLOAT;


-- region by order 
SELECT 
    Region,
    COUNT(*) AS order_count,
    SUM(Ordered_Qty) AS total_qty,
    ROUND(SUM(Total_Revenue), 2) AS total_revenue,
    ROUND(SUM(Total_Cost), 2) AS total_cost,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(AVG(Selling_Price), 2) AS avg_selling_price
FROM orders
GROUP BY Region

-- Group by Order Status

SELECT 
    Order_Status,
    COUNT(*) AS order_count,
    ROUND(SUM(Total_Revenue), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(AVG(Profit), 2) AS avg_profit
FROM orders
GROUP BY Order_Status

-- Group by Payment Method


SELECT 
    Payment_Method,
    COUNT(*) AS order_count,
    ROUND(SUM(Total_Revenue), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit
FROM orders
GROUP BY Payment_Method
ORDER BY total_revenue DESC;

-- Group by Discount
SELECT 
    Discount,
    COUNT(*) AS order_count,
    ROUND(SUM(Total_Revenue), 2) AS total_revenue,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(AVG(Ordered_Qty), 2) AS avg_qty
FROM orders
Group by Discount

-- returns

select * from [dbo].[returns]

SELECT 
    COUNT(*) AS Return_ID,
    SUM(Returned_Qty) AS Total_Return_Qty,
    MAX(Returned_Qty) AS Highest_Orders,
    MIN(Returned_Qty) AS Lowest_Orders,
    CONCAT(AVG(Discount), '%') AS Avg_Discount,
    sum(selling_price) AS total_selling_price, 
    sum(Refund_Amount) AS total_refe 

 FROM [dbo].[returns];

UPDATE [dbo].[returns]
SET Discount = REPLACE(Discount, '%', '');

ALTER TABLE [dbo].[returns]
ALTER COLUMN Discount FLOAT;

-- Group by Return
SELECT 
    Return_Reason,
    COUNT(*) AS Total_Returns,
    SUM(Returned_Qty) AS Total_Returned_Qty,
    ROUND(AVG(Refund_Amount), 2) AS Avg_Refund,
    ROUND(SUM(Refund_Amount), 2) AS Total_Refund
FROM returns
GROUP BY Return_Reason;

--- Group by Discount

SELECT 
    Discount,
    COUNT(*) AS Total_Returns,
    ROUND(AVG(Refund_Amount), 2) AS Avg_Refund,
    ROUND(SUM(Refund_Amount), 2) AS Total_Refund
FROM returns
GROUP BY Discount

--Group by Month
SELECT 
    MONTH(Return_Date) AS Return_Month,
    COUNT(*) AS Total_Returns,
    SUM(Returned_Qty) AS Total_Qty,
    ROUND(SUM(Refund_Amount), 2) AS Total_Refund
FROM returns
GROUP BY MONTH(Return_Date)

SELECT 
    Order_ID,
    COUNT(*) AS Return_Count,
    SUM(Returned_Qty) AS Qty_Returned,
    ROUND(SUM(Refund_Amount), 2) AS Total_Refund
FROM returns GROUP BY Order_ID; 

























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