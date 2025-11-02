-- ==================================
-- FILTERS & AGGREGATION
-- ==================================

USE coffeeshop_db;


-- Q1) Compute total items per order.
--     Return (order_id, total_items) from order_items.

Select order_id, sum(quantity) as total_items
from order_items
group by order_id;

-- Q2) Compute total items per order for PAID orders only.
--     Return (order_id, total_items). Hint: order_id IN (SELECT ... FROM orders WHERE status='paid').

select oi.order_id, sum(oi.quantity) as total_items, status
from orders o
inner join order_items oi
on o.order_id = oi.order_id
where status = 'paid'
group by o.order_id;  

-- Q3) How many orders were placed per day (all statuses)?
--     Return (order_date, orders_count) from orders.

select date(order_datetime) as order_date, count(customer_id) as orders_count
from orders
group by order_date;


-- Q4) What is the average number of items per PAID order?
--     Use a subquery or CTE over order_items filtered by order_id IN (...).
SELECT 
    COUNT(*) * 1.0 / COUNT(DISTINCT oi.order_id) AS avg_items_per_paid_order
FROM order_items oi
WHERE oi.order_id IN (
    SELECT o.order_id
    FROM orders o
    WHERE o.status = 'PAID')
    ;

-- Q5) Which products (by product_id) have sold the most units overall across all stores?
--     Return (product_id, total_units), sorted desc.

select p.product_id, sum(oi.quantity) as total_units
from products p
inner join order_items oi
on p.product_id = oi.product_id
group by p.product_id 
order by total_units desc;


-- Q6) Among PAID orders only, which product_ids have the most units sold?
--     Return (product_id, total_units_paid), sorted desc.
--     Hint: order_id IN (SELECT order_id FROM orders WHERE status='paid').
SELECT 
    oi.product_id,
    SUM(oi.quantity) AS total_units_paid
FROM order_items oi
WHERE oi.order_id IN (
    SELECT o.order_id
    FROM orders o
    WHERE o.status = 'PAID'
)
GROUP BY oi.product_id
ORDER BY total_units_paid DESC;

-- Q7) For each store, how many UNIQUE customers have placed a PAID order?
--     Return (store_id, unique_customers) using only the orders table.

select store_id, count(distinct customer_id) as unique_customers
from orders
where status = 'paid' 
group by store_id;

-- Q8) Which day of week has the highest number of PAID orders?
--     Return (day_name, orders_count). Hint: DAYNAME(order_datetime). Return ties if any.

select dayname(order_datetime) as day_name, count(order_id) as orders_count
from orders
where status = 'paid'
group by dayname(order_datetime)
order by orders_count desc
limit 1;

-- Q9) Show the calendar days whose total orders (any status) exceed 3.
--     Use HAVING. Return (order_date, orders_count).
SELECT 
    Date(order_datetime) as order_date,
    count(*) as orders_count
FROM orders
GROUP BY DATE(order_datetime)
--HAVING COUNT(*) > 3;  --answer is zero here.. there aren't any orders that exceed 3.. i thought my query wasn't working


-- Q10) Per store, list payment_method and the number of PAID orders.
--      Return (store_id, payment_method, paid_orders_count).

select 
	store_id, 
	payment_method,
    count(*) as paid_orders_count
from orders
where status = 'paid'
group by store_id, payment_method
order by store_id;


-- Q11) Among PAID orders, what percent used 'app' as the payment_method?
--      Return a single row with pct_app_paid_orders (0–100).
SELECT 
    ROUND(100.0 * SUM(payment_method = 'app') / COUNT(*), 2) AS pct_app_paid_orders
FROM orders
WHERE status = 'paid';

-- Q12) Busiest hour: for PAID orders, show (hour_of_day, orders_count) sorted desc.

SELECT 
    HOUR(order_datetime) AS hour_of_day,
    COUNT(*) AS orders_count
FROM orders
WHERE status = 'paid'
GROUP BY HOUR(order_datetime)
ORDER BY orders_count DESC;
-- ================
