CREATE DATABASE KMS_analysis
USE KMS_analysis


-- Q1. Product catgory with highest sales

select top 1 product_category, sum(sales) as total_sales 
from orders
group by product_category
order by total_sales desc



-- Q2. Top 3 and Bottom 3 Regions in Terms of Sales

SELECT region, total_sales, 'Top 3' AS sales_rank
from (
select top 3 region, sum(sales) as total_sales from orders
group by region
order by total_sales desc) as top_regions
union
select region,total_sales, 'Bottom 3' as sales_rank
from (
select top 3 region, sum(sales) as total_sales from orders
group by region
order by total_sales asc) as bottom_regions

--Q3. Total Sales of Appliances in Ontario

 select product_sub_category, region, sum(sales) as total_sales_appliance from orders
 where product_sub_category = 'Appliances' and region = 'Ontario'
 group by product_sub_category, region

 with customer_totals as (
    select 
        customer_name, 
        sum(sales) as total_sales,
        count(order_id) as total_orders, 
        avg(discount) as avg_discount,
        avg(order_quantity) as order_quantity
    from orders
    group by customer_name
),

-- Rank orders by most recent date per customer
recent_customer_info as (
    select
        customer_name, 
        region,
        customer_segment,
        row_number() over (partition by customer_name order by order_date desc) as rn
    from Orders
)

-- Main query: Top 10 customers with lowest total sales
select top 10
    ct.customer_name,
    ct.total_sales,
    ct.total_orders,
    ct.avg_discount,
    ct.order_quantity,
    rci.customer_segment,
    rci.region
from customer_totals ct
join recent_customer_info rci on ct.customer_name = rci.customer_name
where rci.rn = 1
order by ct.total_sales asc;

--Top 10 customers

with  customer_totals as (
    select 
        customer_name, 
        sum(sales) as total_sales,
        count(order_id) as total_orders, 
        avg(discount) as avg_discount,
        avg(order_quantity) as order_quantity
    from orders
    group by customer_name
),

-- Rank orders by most recent date per customer
recent_customer_info as (
    select 
        customer_name, 
        region,
        customer_segment,
        row_number() over (partition by Customer_Name order by Order_Date desc) as rn
    from orders
)

-- Main query: Top 10 customers with lowest total sales
select top 10
    ct.customer_name,
    ct.total_sales,
    ct.total_orders,
    ct.avg_discount,
    ct.order_quantity,
    rci.customer_segment,
    rci.region
from customer_totals ct
join recent_customer_info rci on ct.customer_name = rci.customer_name
where rci.rn = 1
order by ct.total_sales desc

--Q5. KMS incurred the most shipping cost using which shipping method?

select top 1 ship_mode, sum(shipping_cost) as shipping_cost from orders
group by ship_mode
order by shipping_cost desc

--Q6. Who are the most valuable customers, and what products or services do they typically purchase?

select o.customer_name, o.product_name, sum(o.sales) as product_sales
from orders o
join(
		select top 10 customer_name
		from orders
		group by customer_name
		order by sum(sales) desc)top_customers 
		on o.customer_name = top_customers.customer_name
group by o.customer_name, o.product_name
order by o.customer_name, product_sales desc

--Q7. Which small business customer had the highest sales?--

select top 1 customer_name, customer_segment, sum(sales) as total_sales from orders
where customer_segment = 'Small Business'
group by customer_name, customer_segment
order by sum(sales) desc

--Q8. Which Corporate Customer placed the most number of orders in 2009 – 2012? --

select top 2 customer_name, count(distinct order_id) as total_orders
from orders
where customer_segment = 'Corporate' and year(order_date) between 2009 and 2012
group by customer_name
order by total_orders desc

--Q9. Which consumer customer was the most profitable one?--

select top 1 customer_name, count(Order_ID) as total_orders, sum(profit) as total_profit 
from orders
where customer_segment = 'Consumer'
group by customer_name
order by total_profit desc

--Q10. Which customer returned items, and what segment do they belong to?--

select distinct o.customer_name, o.customer_segment,s.return_status
from orders o
join order_status s
on o.order_id = s.order_id
where s.return_status = 'returned'

--Q11. If the delivery truck is the most economical but the slowest shipping method and 
--Express Air is the fastest but the most expensive one, do you think the company 
--appropriately spent shipping costs based on the Order Priority? Explain your answer

select ship_mode, order_priority, 
count(*) as total_orders,
sum(shipping_cost) as total_shipping_cost,
avg(shipping_cost) as avg_shipping_cost
from orders
group by ship_mode, order_priority
order by ship_mode, order_priority

--I don't think the company appropriately spent shipping cost,
--according to the data, delivery truck which is the slowest was assigned critical and high priority orders,
--the data also shows delivery truck to be the most expensive.
--The funds spent using delivery truck for high priority orders would have been better spent on express air,
--and delivery truck should have been assigned for low priority orders.

