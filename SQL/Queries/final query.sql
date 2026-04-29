create database final
use final
 select * from suppliers 
 select * from sales
 select * from orders
 select * from customers
 select * from  [returns]
 select * from products


 --suppliers table
 -- transforming columns 
  select*, concat ('+',Phone) as Phone_num, round ([Rating],2) as Rate
  into Supp
  from suppliers 
  select* from Supp
  alter table Supp
 drop column Phone, Rating 
 select* from Supp

  -- sales table 
  --  transforming total revenue, selling price columns 
   select*,  round (Total_Revenue,2) as Revenue, round (Selling_Price,2) as Sell_Price
   into new_sales 
   from sales
   alter table new_sales 
   drop column Total_Revenue, Selling_price
   select*
   from new_sales



-- customers table 
-- transforming phone column 
  select*, concat ('+',Phone) as phone_num
  into Customer
  from customers
  alter table Customer
  drop column Phone 
  select* from Customer
-- retuns table 
-- tranforming refund amount column 
  select*, round (Refund_Amount,2)as Refund_values
  into return_products
  from [returns] 
  alter table return_products
  drop column Refund_Amount
  select* from return_products

-- products table 
--  transforming Purchase_Price, Selling_Price, Avg_Price columns 
   select*, round (Purchase_Price,2) as buying_Price, round (Selling_Price,2) as Sell_Price, round (Avg_Price,2) as Average_Price
   into our_Products
   from products
   alter table our_Products
   drop column Purchase_Price, Selling_Price, Avg_Price
   select* from our_Products



-- order table 
-- tranforming columns 
select*, round (Unit_Cost,2) as Cost_per_unit, round (Selling_Price,2) as Sell_Price, round (Total_Revenue,2) as Revenue, round (Total_Cost,2) as Cost, round (Profit,2) as Profitt
   into orders_table
   from orders
   alter table orders_table
   drop column Unit_Cost,Selling_Price,Total_Revenue,Total_Cost,Profit
   Update orders_table
   set Profitt = 0 where Profitt is null
   select* from orders_table
   where Profitt is null --checked 















 -- checking on nulls 
 select* 
 from suppliers
 where Phone is null 
 or City is null
 or Country is null 
 or Rating is null
 or Supplier_Name is null


 select* 
 from sales
 where SKU is null 
 or Quantity_Sold is null
 or Selling_Price is null 
 or Total_Revenue is null
 or Sale_Date is null
 or Region is null

  select* 
 from customers
 where Customer_name is null 
 or Phone is null
 or Favorite_Product is null 
 or Last_Purchase_Date is null
 or Total_Orders is null

   select* 
 from [returns]
 where Order_ID is null 
 or Return_Date is null
 or Return_Reason is null 
 or Refund_Amount is null

 
    select* 
 from products
 where Product_Name is null 
 or Category is null
 or Purchase_Price is null 
 or Selling_Price is null
 or Avg_Price is null 
 or Stock_Qty is null


 select* 
 from orders 
 where Profit is null


 -- handling nulls 
 select coalesce (Profit,0) as Profit
 from orders




 -- modeling 
 alter table Supp 
 add constraint pk_supp
 primary key (Supplier_ID)

 alter table orders_table 
 add constraint fk_order_supp
 foreign key (Supplier_ID) references Supp

 alter table our_products
 add constraint pk_product
 primary key (SKU)

 alter table orders_table 
 add constraint fk_order_product
 foreign key (SKU) references our_products

  alter table orders_table
 add constraint pk_order
 primary key (Order_ID)

 alter table return_products
 add constraint fk_return_product
 foreign key (Order_ID) references orders_table

 
 alter table return_products
 add constraint pk_return
 primary key (Return_ID)
 
  
 alter table new_sales
 add constraint pk_sales
 primary key (Sale_ID)

  alter table new_sales
 add constraint fk_sales_products
 foreign key (SKU) references our_products



  
 alter table Customer
 add constraint pk_customer
 primary key (Customer_ID)

  alter table orders_table
 add constraint fk_orders_customer
 foreign key (Customer_ID) references Customer















