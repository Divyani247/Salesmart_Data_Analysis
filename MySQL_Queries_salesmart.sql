create database salesmart_db;
show databases;
use salesmart_db;
show tables;

select* from salesmart;

-- Bussiness problems --
-- 1) find different payment mathods and no of transactions,no of quantinty sold 
select payment_method,sum(quantity) as no_of_quantity_sold, count(*) as no_of_transaction 
from salesmart
group by payment_method;

-- 2) identify the heighest rated category in each branch, displaying branch,category and avg rating

select * from(
 SELECT 
    branch,
    category,
    AVG(rating) AS avg_rating,
    RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS ran
FROM salesmart
GROUP BY branch, category) x
where ran=1;

-- 3) busiest day for each branch based on no of transactions
select* from(
SELECT 
    branch,
    DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day,
    COUNT(*) AS no_of_transaction,
    RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rn
FROM salesmart
GROUP BY branch, day) temp_table
where rn=1;

-- 4) determine the min,max,average rating of category for each city
select city,category,
min(rating)as min_rating,
max(rating) as max_rating,
avg(rating)as avg_rating
from salesmart
group by city,category;

select category,sum(total* profit_margin) as total_profit,sum(total) as total_revenue
from salesmart
group by category;


-- 5) most common payment method for each branch
with cte as (
select branch,payment_method, count(*) as total_trans,
rank() over(partition by branch order by count(*)) as rn
from salesmart
group by branch,payment_method
)
 select * from cte
 where rn =1;

-- 6) categorise sales into 3 groups morning,afternoon,evening
-- find out which of the shift and number of invoice

select * from salesmart;

SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM salesmart
GROUP BY 
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END
ORDER BY branch, num_invoices DESC;

-- 7) identify 5 branch with heighest decrease ratio in revenue compare to last year

with revenue_2022 as(
select branch, sum(total) as revenue
from salesmart
where year(STR_TO_DATE(date, '%d/%m/%y')) =2022
group by branch
),
revenue_2023 as(
select branch, sum(total) as revenue 
from salesmart
where year(str_to_date(date, '%d/%m/%y'))=2023
group by branch
)

select ls.branch, 
ls.revenue as last_yr_revenue,
cs.revenue as curr_yr_revenue,
ROUND(((ls.revenue - cs.revenue) / ls.revenue) * 100, 2) AS revenue_decrease_ratio
from revenue_2022 as ls
join revenue_2023 as cs
on ls.branch=cs.branch
where ls.revenue>cs.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;

select * from salesmart;

-- 8) top 5 branches are most profitable based on total revenue vs profit margin?
select * from(
select branch,
round(sum(total)) as total_revenue,
round(sum(profit_margin* total)) as total_profit
from salesmart
group by branch
order by total_profit desc) temp 
limit 5;

-- 9)  Which branches are consistently under-rated (<6 average rating)?
select branch, avg(rating) as avg_rating
from salesmart
group by branch
having avg_rating<6
order by avg_rating;

-- 10) Which product categories are underperforming in revenue despite high quantities sold?
select * from salesmart;

select category, sum(total) as revenue,sum(quantity) as quan_sold
from salesmart
group by category
order by quan_sold desc,revenue;

-- 11)  Which city has the highest average profit margin?
select city ,avg(profit_margin) as avg_profit_margin
from salesmart
group by city
order by avg_profit_margin desc
limit 1;

-- 12) What are the top 3 cities with the highest quantity sold in the "Sports and travel" category?
select city ,sum(quantity) as highest_quantity
from salesmart
where category = 'Sports and travel'
group by city
order by highest_quantity desc
limit 3;

-- 13) -- Q6: Calculate the total profit for each category

select category, sum(unit_price * quantity * profit_margin) as total_profit
from salesmart
group by category;

select * from salesmart;

 -- 14 )Identify the top 3 categories with the highest average unit price
 select category ,avg(unit_price) as highest_unit_price
 from salesmart
 group by category
 order by highest_unit_price desc
 limit 3;
 
