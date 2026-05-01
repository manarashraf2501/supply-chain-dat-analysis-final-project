create database final_dep2
use final_dep2

select * from custmers

select * from sales

select * from proudect

select * from suppliers

select * from orders

select * from returen_old

select * from inventory



 alter table returen
add constraint fk_returen_order
foreign key (Order_ID) references orders; 

 alter table inventory
add constraint fk_inventory_p
foreign key (SKU) references proudect; 

 alter table orders
add constraint fk_orders_p
foreign key (SKU) references proudect;

 alter table sales
add constraint fk_sales_p
foreign key (SKU) references proudect;

 alter table orders
add constraint fk_orders_s
foreign key (Supplier_ID) references suppliers;

 alter table orders
add constraint fk_orders_c
foreign key (Customer_ID) references custmers;

 alter table returen
 alter column Return_ID nvarchar(50)  not null ;
 
 alter table returen_old
add constraint Pk_returen
primary key (Return_ID) nvarchar(50) ;
  
  
 drop table returen

 update custmer set Customer_ID =      TRIM([Customer_ID]) , Customer_Name = TRIM([Customer_Name])

  
  
  select sum(total_orders) as sum, avg(total_orders) as avg, min(total_orders) as min , max(total_orders) as max  from custmers
select count(Customer_Name) from custmers

select DISTINCT city from sales

select city , min(rating) as min_revenu 
from sales 
group by city
order by city desc

  
  SELECT * FROM talabt AS t 
JOIN custmers AS c
  ON t.Customer_ID = c.Customer_ID; -- Join on the shared ID, not the Order ID

  select count(city) from sales

  select count(city) from

  drop table sales


  select  ROUND (unit_cost,3) as revnue from talabt 
  
SELECT 
    [supplier_id],
    [supplier_name],
    [phone],
    [email],
    TRIM([Address]) AS Address,
    UPPER([city]) AS CITY,
    UPPER([COUNTRY]) AS COUNTRY,
    ROUND([rating], 2) AS rating,
    [on_time_delivery]
INTO suppliers_new 
FROM suppliers;

select* from suplpiers
alter table suppliers 
alter column Rating int 
select Rating 
from suppliers

select  * from suppliers_new

EXEC sp_rename 'returen', 'returen_old';

drop table suppliers

update custmer set Customer_ID =      TRIM([Customer_ID]) , Customer_Name = TRIM([Customer_Name])
