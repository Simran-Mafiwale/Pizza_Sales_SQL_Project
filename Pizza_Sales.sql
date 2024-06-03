
CREATE DATABASE Pizza_Sales;

-- Import csv files.

CREATE TABLE Pizza_orders(
Order_id int Primary key,
Order_date date,
Order_time time 
)

create table Order_details_pizza(
Order_details_id int primary key,
Order_id int,
Pizza_id nvarchar(100),
Quantity int
)

select * from Order_details_pizza
select * from pizzas
select * from Pizza_orders
select * from pizza_types

--Retrieve the total number of orders placed.

SELECT
	COUNT(Order_id) AS Total_Orders
FROM 
	Pizza_orders;
	
--Calculate the total revenue generated from pizza sales.

SELECT
	Round(SUM(odp.Quantity * p.price),2) As Total_Revenue
FROM
	Order_details_pizza as odp
JOIN
	pizzas as p
ON
	odp.Pizza_id = p.pizza_id;

--Identify the highest-priced pizza

SELECT 
	TOP 1 
		PT.name, P.price
FROM 
	pizza_types  AS PT
JOIN
	pizzas AS P
ON	
	PT.pizza_type_id = P.pizza_type_id
ORDER BY 
	P.price DESC;

--Identify the most common pizza size ordered.

SELECT 
	P.size, 
	COUNT(ODP.Order_details_id) AS Order_count
FROM 
	Pizzas as P
JOIN
	Order_details_pizza AS ODP
ON 
	P.pizza_id = ODP.Pizza_id
GROUP BY 
	P.size
ORDER BY 
	Order_count DESC;

--List the top 5 most ordered pizza types along with their quantities.

SELECT 
	TOP 5 
	PT.name, 
	SUM(ODP.Quantity) as Quantity
FROM
	pizza_types AS PT
JOIN 
	pizzas AS P
ON	
	P.pizza_type_id = PT.pizza_type_id
JOIN
	Order_details_pizza AS ODP
ON 
	ODP.Pizza_id = P.Pizza_id
GROUP BY 
	PT.name
ORDER BY 
	Quantity DESC;

--Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
	PT.category, 
	SUM(ODP.Quantity) Total_quantity
FROM 
	pizza_types AS PT
JOIN 
	pizzas AS P
ON	
	PT.pizza_type_id = P.pizza_type_id
JOIN 
	Order_details_pizza AS ODP
ON 
	ODP.Pizza_id = P.pizza_id
GROUP BY 
	PT.category;

--Determine the distribution of orders by hour of the day.

SELECT 
    DATEPART(HOUR, time) AS Hour,
    COUNT(order_id) AS OrderCount
FROM 
    Pizza_orders
GROUP BY 
    DATEPART(HOUR, time)
ORDER BY 
    COUNT(order_id) DESC;

--Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
	category, COUNT(name) AS Total
FROM
	pizza_types
GROUP BY 
	category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
	AVG(Quantity) AS AVERAGE_PIZZA_ORDERED_PER_DAY 
FROM
	(
		SELECT 
			PO.date, SUM(ODP.Quantity) AS Quantity
		FROM
			Pizza_orders AS PO
		JOIN 
			Order_details_pizza AS ODP
		ON 
			PO.order_id = ODP.Order_id
		GROUP BY 
			PO.date
			) AS OQ;

--Determine the top 3 most ordered pizza types based on revenue.

SELECT 
	TOP 3 
	PT.name, SUM(ODP.Quantity * P.price) AS REVENUE
FROM 
	pizza_types AS PT 
JOIN 
	pizzas AS P
ON 
	PT.pizza_type_id = P.pizza_type_id
JOIN 
	Order_details_pizza AS ODP
ON 
	P.pizza_id = ODP.Pizza_id
GROUP BY 
	PT.name
ORDER BY 
	REVENUE DESC;

--Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
	PT.category, 
	ROUND(SUM(ODP.Quantity * P.price)/(
			SELECT 
				ROUND(SUM(ODP.Quantity * P.price),2) AS TOTAL_SALES
			FROM 
				Order_details_pizza AS ODP
			JOIN
				pizzas AS P
			ON 
				ODP.Pizza_id = P.pizza_id) * 100, 2) AS REVENUE
FROM 
	pizza_types AS PT
JOIN
	pizzas AS P
ON	
	PT.pizza_type_id = P.pizza_type_id
JOIN 
	Order_details_pizza AS ODP
ON 
	ODP.Pizza_id = P.pizza_id
GROUP BY 
	PT.category
ORDER BY 
	REVENUE DESC;

--Analyze the cumulative revenue generated over time.

SELECT 
	DATE, 
	SUM(REVENUE) OVER (ORDER BY DATE) AS CUMM_REVENUE
FROM 
	(
	SELECT	
		PO.date, SUM(ODP.Quantity * P.price) AS REVENUE
	FROM 
		Order_details_pizza AS ODP
	JOIN 
		pizzas AS P
	ON 
		ODP.Pizza_id = P.pizza_id
	JOIN 
		Pizza_orders AS PO
	ON 
		PO.order_id = ODP.Order_id
	GROUP BY 
		PO.date
		) 
		AS REVENUE_GENERATED;

--Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT 
	NAME, REVENUE
FROM
	(	
	SELECT 
		category, name, REVENUE,
		RANK() OVER(PARTITION BY CATEGORY ORDER BY REVENUE DESC) AS RANK
	FROM 
		 (
			SELECT 
				PT.category, PT.name, SUM(ODP.Quantity  * P.price) AS REVENUE
			FROM 
				pizza_types AS PT
			JOIN 
				pizzas AS P
			ON	
				PT.pizza_type_id = P.pizza_type_id
			JOIN
				Order_details_pizza AS ODP 
			ON 
				P.pizza_id = ODP.Pizza_id
			GROUP BY 
				PT.category, PT.name) 
			AS PIZZA) 
				AS RANKS
WHERE 
	RANK <=3 ;