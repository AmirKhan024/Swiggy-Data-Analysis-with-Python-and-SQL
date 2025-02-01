-- swiggy case study

select * from users;
select * from orders;
select * from food;
select * from orderdetails;
select * from resto;
select * from menu;
select * from partner;

-- ------------------------------------------------------------------------------------------------------------------------------------------

-- 1.find users who have never ordered;
-- using joins
select * from users u left outer join orders o on u.userid = o.userid where o.orderid is NULL;
-- using subquery
select * from users where userid not in (select userid from orders);

-- ------------------------------------------------------------------------------------------------------------------------------------------

-- 2.find average price per dish
select f.fname, avg(price) as 'Avg Price' from menu m join food f on m.fid = f.fid group by fname;

-- ------------------------------------------------------------------------------------------------------------------------------------------

-- 3.find top restaurant in terms of orders for a given month
-- DATA CLEANING :-
	describe orders;
	-- the date column has the 'text' datatype, so first we need to convert it into 'date' datatype 
	-- and then convert it into mysql standart date format
	alter table orders add column temp_date date;
	 SET SQL_SAFE_UPDATES = 0;  
	update orders set temp_date = str_to_date(date,'%d-%m-%Y');
	 SET SQL_SAFE_UPDATES = 1;
	 alter table orders drop column date ;
	 alter table orders change column temp_date date DATE;
     
select r.name,count(*) as ordercounts from orders o join resto r on o.rid = r.rid 
where monthname(date) = 'June' group by r.name order by count(*) desc limit 1;

-- ------------------------------------------------------------------------------------------------------------------------------------------

-- 4.restaurants with monthly sales > x
select r.name, sum(amount) as revenue from orders o join resto r on o.rid = r.rid 
where monthname(date) ='June' group by r.name having sum(amount) > 500;

-- ------------------------------------------------------------------------------------------------------------------------------------------

-- 5.Show all orders with order details for a particular customer in a particular date.
select f.fname,od.fid,r.name, o.orderid from orders o join resto r on o.rid = r.rid join orderdetails od on od.orderid =o.orderid 
join food f on f.fid = od.fid
where userid = (select userid from users where name = 'Ankit') and (date>'2022-06-10' and date<'2022-07-10');

-- ------------------------------------------------------------------------------------------------------------------------------------------ 

 -- 6.Find restaurants with max repeated customers
 select r.name,count(*) as 'repeatedcustomers' from 
 ( select rid,userid, count(*) as visits from orders o group by rid,userid having count(*)>1) as  t
join resto r on t.rid = r.rid
 group by r.name order by repeatedcustomers desc limit 1  ;
 
-- ------------------------------------------------------------------------------------------------------------------------------------------

-- 7.Month over Month revenue growth of swiggy
select month, round((((revenue-previous)/previous)*100),1) as MoM_Percentage from 
(
	with sales as (select monthname(date) as 'month' , sum(amount) as revenue from orders group by month)
	select month, revenue, lag(revenue,1) over (order by revenue) as previous from sales
) t;

-- ------------------------------------------------------------------------------------------------------------------------------------------

-- 8. Find Customer's fav food
with temp as (select userid,fid, count(*) as frequency from orders o join orderdetails od on o.orderid = od.orderid group by userid,fid)
select u.name,f.fname,frequency from temp t1 
join users u on t1.userid =u.userid join food f on t1.fid = f.fid
where frequency = (select max(frequency) from temp t2 where t2.userid = t1.userid);

-- ------------------------------------------------------------------------------------------------------------------------------------------

-- 9. Create a Loyal Customers Table with Users Who Have Placed More Than 3 Orders
create table loyalcustomers(
	userid int,
    name varchar(100),
    discount int
);

Insert into loyalcustomers (userid,name)
select u.userid, u.name from users u join orders o on u.userid = o.userid group by userid,name  having count(*) > 3;

-- ------------------------------------------------------------------------------------------------------------------------------------------

-- 10. Apply Discount for Loyal Customers Based on Their Order Value
update loyalcustomers 
set discount = (select sum(amount)*0.1 from orders where loyalcustomers.userid = orders.userid);

-- ------------------------------------------------------------------------------------------------------------------------------------------

-- 11.Most paired products 
select f1.fname,f2.fname , count(*) as totalcount from orderdetails od1 join orderdetails od2 on od1.orderid = od2.orderid and od1.fid<od2.fid
join food f1 on od1.fid = f1.fid join food f2 on f2.fid = od2.fid group by f1.fname,f2.fname having count(*) > 1 order by totalcount desc;
 
-- ------------------------------------------------------------------------------------------------------------------------------------------

-- 12.List all food items and their corresponding restaurant names 
select distinct(f.fname),r.name from orders o join orderdetails od on o.orderid = od.orderid 
join food f on f.fid =od.fid join resto r on r.rid = o.rid;

-- ------------------------------------------------------------------------------------------------------------------------------------------

-- 13. Find users who have placed orders at more than 3 different restaurants

select u.name from users u join orders o on o.userid = u.userid group by name having count(distinct(o.rid)) >=3;

-- ------------------------------------------------------------------------------------------------------------------------------------------

 
 
