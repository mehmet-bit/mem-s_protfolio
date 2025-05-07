
use project

select *from [dbo].[neworderr_data]

--Write a query to distinct all cities where have been shipped.
--select distinct city from orders_data

--Calculate the total selling price and profits for all orders.

--select [Order_Id], sum(quantity*Unit_Selling_Price) as 'Total_Selling_Price',
--cast(sum(quantity*unit_profit)

--Select all the cities have been shipped.
Select distinct city from neworderr_data

--Order the Total Profit values by descending order.

SELECT 
    [Order Id], 
    SUM([Total_Profit]) AS Total_Profit,
    SUM([Unit_Profit]) AS Unit_Profit
FROM neworderr_data
GROUP BY [Order Id]
ORDER BY Total_Profit DESC;


--Write a query to find all orders from the 'Technology' category
--that were shipped using 'Second class' ship mode, ordered by order date.
select [Order Id],[Order Date]
from neworderr_data
where category = 'Technology' and  [Ship Mode] = 'Second Class'
order by [order date]


--Write a query to find the average order value
select cast(avg(quantity*Unit_selling_price) as decimal(10,2)) as AOV
from neworderr_data


--find the city with the highest total quantity of products ordered.
select top 2 city, sum(quantity) as 'Total Quantity'
from neworderr_data
group by city order by [Total Quantity] desc

--Use a window function to rank orders in each region by quantity in descending order.
select [Order Id], region, quantity as 'Total_Quantity',
dense_rank() over (partition by region order by quantity desc) as rnk
from neworderr_data
order by region, rnk


--Write a query to list all orders placed in the first quarter of any year (January-March), including the  total cost for these orders.
--select *from orders_data where [order id] = 137

select [Order Id], [Order Date], month([Order Date]) as month from neworderr_data

SELECT 
    [Order Id], 
    SUM(Quantity * unit_selling_price) AS [Total Value]
FROM neworderr_data
WHERE MONTH([Order Date]) IN (1, 2, 3)
GROUP BY [Order Id]
ORDER BY [Total Value] DESC;


--Q1. find top 10 highest profit generating products
select top 10 [product id], sum([Total_Profit]) as profit
from [neworderr_data]
group by [product id]
order by profit desc

--now the question could also be for top n products acc to revenue/sales

--find top 3 highest selling products in each region.

with cte as (
select region, [product id], sum(quantity*Unit_selling_price) as sales
, row_number() over(partition by region order by sum(quantity*Unit_selling_price) desc) as rn
from [neworderr_data]
group by region, [product id]
)
select *
from cte 
where rn<=3

;

with cte as (
select region, [product id], sum(quantity*Unit_selling_price) as sales
from [neworderr_data]
group by region, [product id]
)
select * from (
select *
,row_number() over(partition by region order by sales desc) as rn
from cte) A
where rn<=3



--Find month over month growth comparison for 2022 and 2023 sales eg :jan 2022 vs jan 2023

with cte as (
select year([order date]) as order_year , month([order date]) as order_month,
sum(quantity*Unit_selling_price) as sales
from [neworderr_data]
group by year([order date]), month([order date])
--order by year(order_date),month(order_date)
)
select order_month
,round(sum(case when order_year=2022 then sales else 0 end),2) as sales_2022
,round(sum(case when order_year=2023 then sales else 0 end),2) as sales_2023
from cte
group by order_month
order by order_month

--now we can also calculate of growth

--for each category which month had the highest sales

with cte as (
 select category ,format([order date],'yyyy-MM') as order_year_month
 ,sum(quantity*Unit_selling_price) as sales,
 row_number() over(partition by category order by sum(quantity*Unit_selling_price) desc) as rn
from neworderr_data
group by category,format([order date],'yyyy-MM')
--order by category,format(order_date,'yyyyMM')
)
select category as category, order_year_month as 'Order Year-Month', sales as [Total Sales]
from cte
where rn=1


--which sub category had highest growth by sales in 2023 compare to 2022
;


with cte as (
 select [sub category] as sub_category ,year([order date]) as order_year,
 sum(quantity*Unit_selling_price) as sales
from neworderr_data
group by [sub category],year([order date])
--order by year(order_date),month(order_date)
  )
, cte2 as (
select sub_category
,round(sum(case when order_year=2022 then sales else 0 end),2) as sales_2022
,round(sum(case when order_year=2023 then sales else 0 end),2) as sales_2023
from cte
group by sub_category
)
--select * from cte2
select top 5 sub_category as 'Sub Category',sales_2022 as 'Sales in 2022',
sales_2023 as 'Sales in 2023'
,(sales_2023-sales_2022) as 'Diff in Amount'
from cte2
order by (sales_2023-sales_2022) desc
