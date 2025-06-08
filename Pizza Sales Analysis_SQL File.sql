-- Question1 Retrieve the total number of orders placed.

select count(distinct order_id) as total_order_placed from orders;



-- Question2 Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
    

-- Question3 Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;



-- Question4 Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1;



-- Question5 List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;



-- Question6 Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;




-- Question7 Determine the distribution of orders by hour of the day.

select Hour(order_time) as hours, count(order_id) as Order_Count
from orders
group by hours
order by Order_Count desc;




-- Question8 Join relevant tables to find the category-wise distribution of pizzas.

select category, count(category) as Category_Count
from pizza_types
group by category
order by Category_Count desc;




-- Question9 Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(PizzaQuantity_Ordered), 0) AS avg_pizzas_ordered_per_day
FROM
    (SELECT 
        orders.order_date,
            SUM(order_details.quantity) AS PizzaQuantity_Ordered
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS Order_Quantity;
    
    
    
    
-- Question10 Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name, sum(order_details.quantity * pizzas.price) as revenue
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by revenue desc limit 3;




-- Question11 Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category, round(sum(order_details.quantity * pizzas.price) / (select
sum(order_details.quantity * pizzas.price)
from order_details
join pizzas
on order_details.pizza_id = pizzas.pizza_id) * 100, 2)
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category;




-- Question12 Analyze the cumulative revenue generated over time.

select order_date, round(sum(revenue) over (order by order_date),2) as Cum_Revenue
from (select orders.order_date,
round(sum(order_details.quantity * pizzas.price),2) as revenue
from
orders
join order_details
on orders.order_id = order_details.order_id
join pizzas
on order_details.pizza_id = pizzas.pizza_id
group by orders.order_date) as sales;




-- Question13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category, name, revenue from
(select category, name, revenue, rank() over (partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name, round(sum(order_details.quantity * pizzas.price),2) as revenue
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn<=3;
