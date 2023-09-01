-- Pizza Metrics

--1. How many pizzas were ordered?
  SELECT COUNT(pizza_id) AS total_pizza_ordered 
  FROM pizza_runner.customer_orders;
  
-------------------------------------------------------------------------------------------------------------------------------
--2. How many unique customer orders were made?
  SELECT COUNT(DISTINCT order_id) AS unique_orders 
  FROM pizza_runner.customer_orders;

-------------------------------------------------------------------------------------------------------------------------------
--3. How many successful orders were delivered by each runner?
  SELECT runner_id, COUNT(order_id) AS successful_orders
  FROM pizza_runner.runner_orders
  WHERE pickup_time!='null'
  GROUP BY runner_id
  ORDER BY runner_id;

-------------------------------------------------------------------------------------------------------------------------------
--4. How many of each type of pizza was delivered?
  SELECT pizza_name, COUNT(co.order_id) AS orders
  FROM pizza_runner.pizza_names pn
  INNER JOIN pizza_runner.customer_orders co
  ON pn.pizza_id = co.pizza_id
  INNER JOIN pizza_runner.runner_orders ro
  ON co.order_id = ro.order_id
  WHERE pickup_time <> 'null'
  GROUP BY pizza_name;

-------------------------------------------------------------------------------------------------------------------------------
--5. How many Vegetarian and Meatlovers were ordered by each customer?
  SELECT customer_id,pizza_name,COUNT(co.pizza_id) as pizza_count
  FROM pizza_runner.customer_orders co
  LEFT JOIN pizza_runner.pizza_names pn
  ON co.pizza_id = pn.pizza_id
  WHERE pizza_name IN ('Meatlovers','Vegetarian')
  GROUP BY customer_id,pizza_name
  ORDER BY customer_id, COUNT(co.pizza_id) DESC;

-------------------------------------------------------------------------------------------------------------------------------
--6. What was the maximum number of pizzas delivered in a single order?
  SELECT ro.order_id, COUNT(pizza_id) AS pizza_count
  FROM pizza_runner.runner_orders ro
  INNER JOIN pizza_runner.customer_orders co
  ON co.order_id = ro.order_id
  WHERE pickup_time<>'null'
  GROUP BY ro.order_id
  ORDER BY COUNT(pizza_id) DESC
  LIMIT 1;

-------------------------------------------------------------------------------------------------------------------------------
--7. For each customer, how many delivered pizzas had at least 1 change and how 	 many had no changes?
  SELECT customer_id, COUNT(DISTINCT pizza_id) AS pizzas_change
  FROM pizza_runner.runner_orders ro
  LEFT JOIN pizza_runner.customer_orders co
  ON ro.order_id = co.order_id
  WHERE pickup_time<>'null' AND ((exclusions<>'null' AND LENGTH(exclusions)>0) OR (extras<>'null' AND LENGTH(extras)>0))
  GROUP BY customer_id;
  
  -------------------------------------------------------------------------------------------------------------------------------
--8. How many pizzas were delivered that had both exclusions and extras?
  SELECT SUM(CASE WHEN exclusions<>'null' AND LENGTH(exclusions)>0 AND extras<>'null' AND LENGTH(extras)>0 THEN 1 ELSE 0 END) AS count_pizzas FROM
  pizza_runner.runner_orders ro
  LEFT JOIN pizza_runner.customer_orders co
  ON ro.order_id = co.order_id
  WHERE pickup_time<>'null';

-------------------------------------------------------------------------------------------------------------------------------
--9. What was the total volume of pizzas ordered for each hour of the day?
  SELECT DATE_PART('hour',order_time) AS hours, COUNT(pizza_id) AS pizza_count
  FROM pizza_runner.customer_orders
  GROUP BY DATE_PART('hour',order_time);

-------------------------------------------------------------------------------------------------------------------------------
--10. What was the volume of orders for each day of the week?
  SELECT DATE_PART('dow',order_time) AS days, COUNT(pizza_id) AS pizza_count
  FROM pizza_runner.customer_orders
  GROUP BY DATE_PART('dow',order_time);

-------------------------------------------------------------------------------------------------------------------------------


-- Section B: Pizza Metrics

--1. How many pizzas were ordered?
  SELECT COUNT(pizza_id) AS total_pizza_ordered 
  FROM pizza_runner.customer_orders;
  
-------------------------------------------------------------------------------------------------------------------------------
--2. How many unique customer orders were made?
  SELECT COUNT(DISTINCT order_id) AS unique_orders 
  FROM pizza_runner.customer_orders;

-------------------------------------------------------------------------------------------------------------------------------
--3. How many successful orders were delivered by each runner?
  SELECT runner_id, COUNT(order_id) AS successful_orders
  FROM pizza_runner.runner_orders
  WHERE pickup_time!='null'
  GROUP BY runner_id
  ORDER BY runner_id;

-------------------------------------------------------------------------------------------------------------------------------
--4. How many of each type of pizza was delivered?
  SELECT pizza_name, COUNT(co.order_id) AS orders
  FROM pizza_runner.pizza_names pn
  INNER JOIN pizza_runner.customer_orders co
  ON pn.pizza_id = co.pizza_id
  INNER JOIN pizza_runner.runner_orders ro
  ON co.order_id = ro.order_id
  WHERE pickup_time <> 'null'
  GROUP BY pizza_name;

-------------------------------------------------------------------------------------------------------------------------------
--5. How many Vegetarian and Meatlovers were ordered by each customer?
  SELECT customer_id,pizza_name,COUNT(co.pizza_id) as pizza_count
  FROM pizza_runner.customer_orders co
  LEFT JOIN pizza_runner.pizza_names pn
  ON co.pizza_id = pn.pizza_id
  WHERE pizza_name IN ('Meatlovers','Vegetarian')
  GROUP BY customer_id,pizza_name
  ORDER BY customer_id, COUNT(co.pizza_id) DESC;

-------------------------------------------------------------------------------------------------------------------------------
--6. What was the maximum number of pizzas delivered in a single order?
  SELECT ro.order_id, COUNT(pizza_id) AS pizza_count
  FROM pizza_runner.runner_orders ro
  INNER JOIN pizza_runner.customer_orders co
  ON co.order_id = ro.order_id
  WHERE pickup_time<>'null'
  GROUP BY ro.order_id
  ORDER BY COUNT(pizza_id) DESC
  LIMIT 1;

-------------------------------------------------------------------------------------------------------------------------------
--7. For each customer, how many delivered pizzas had at least 1 change and how 	 many had no changes?
  SELECT customer_id, COUNT(DISTINCT pizza_id) AS pizzas_change
  FROM pizza_runner.runner_orders ro
  LEFT JOIN pizza_runner.customer_orders co
  ON ro.order_id = co.order_id
  WHERE pickup_time<>'null' AND ((exclusions<>'null' AND LENGTH(exclusions)>0) OR (extras<>'null' AND LENGTH(extras)>0))
  GROUP BY customer_id;
  
  -------------------------------------------------------------------------------------------------------------------------------
--8. How many pizzas were delivered that had both exclusions and extras?
  SELECT SUM(CASE WHEN exclusions<>'null' AND LENGTH(exclusions)>0 AND extras<>'null' AND LENGTH(extras)>0 THEN 1 ELSE 0 END) AS count_pizzas FROM
  pizza_runner.runner_orders ro
  LEFT JOIN pizza_runner.customer_orders co
  ON ro.order_id = co.order_id
  WHERE pickup_time<>'null';

-------------------------------------------------------------------------------------------------------------------------------
--9. What was the total volume of pizzas ordered for each hour of the day?
  SELECT DATE_PART('hour',order_time) AS hours, COUNT(pizza_id) AS pizza_count
  FROM pizza_runner.customer_orders
  GROUP BY DATE_PART('hour',order_time);

-------------------------------------------------------------------------------------------------------------------------------
--10. What was the volume of orders for each day of the week?
  SELECT DATE_PART('dow',order_time) AS days, COUNT(pizza_id) AS pizza_count
  FROM pizza_runner.customer_orders
  GROUP BY DATE_PART('dow',order_time);

-------------------------------------------------------------------------------------------------------------------------------

-- Section B: Runner and Customer Experience
--1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
  SELECT (DATE_TRUNC('week',registration_date)+interval '4 day') AS week, COUNT(runner_id)
  FROM pizza_runner.runners
  GROUP BY (DATE_TRUNC('week',registration_date)+interval '4 day')
  ORDER BY week;

-------------------------------------------------------------------------------------------------------------------------------
--2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
  SELECT runner_id,ROUND(AVG(EXTRACT(MINUTE FROM (pickup_time::timestamp - order_time))),2) AS avg_arrival_time 
  FROM pizza_runner.runner_orders ro
  INNER JOIN pizza_runner.customer_orders co
  ON ro.order_id = co.order_id
  WHERE pickup_time<>'null'
  GROUP BY runner_id
  ORDER BY runner_id;
-------------------------------------------------------------------------------------------------------------------------------
--3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
  WITH prepare_time AS (
  SELECT co.order_id,COUNT(pizza_id) AS pizza_count,MAX(EXTRACT(MINUTE FROM ((pickup_time::timestamp)-(order_time)))) AS preparation_time
  FROM pizza_runner.customer_orders co
  INNER JOIN pizza_runner.runner_orders ro
  ON co.order_id = ro.order_id
  WHERE pickup_time<>'null'
  GROUP BY co.order_id
  ORDER BY pizza_count DESC
  )
  SELECT pizza_count, ROUND(AVG(preparation_time),2) AS avg_prep_time
  FROM prepare_time
  GROUP BY pizza_count
  ORDER BY pizza_count DESC;

-------------------------------------------------------------------------------------------------------------------------------
--4. What was the average distance travelled for each customer?
  SELECT customer_id, AVG(TRIM('km' FROM distance)::DOUBLE PRECISION) AS avg_distance
  FROM pizza_runner.customer_orders co
  INNER JOIN pizza_runner.runner_orders ro
  ON co.order_id = ro.order_id
  WHERE pickup_time<>'null'
  GROUP by customer_id;

-------------------------------------------------------------------------------------------------------------------------------
--5. What was the difference between the longest and shortest delivery times for all orders?
  SELECT (MAX(REGEXP_REPLACE(duration,'minutes|mins|minute','')::DOUBLE PRECISION)-MIN(REGEXP_REPLACE(duration,'minutes|mins|minute','')::DOUBLE PRECISION)) AS difference
  FROM pizza_runner.runner_orders
  WHERE pickup_time<>'null';

-------------------------------------------------------------------------------------------------------------------------------
--6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
  SELECT runner_id,AVG((TRIM('km' FROM distance)::DOUBLE PRECISION)/((REGEXP_REPLACE(duration,'minutes|mins|minute','')::DOUBLE PRECISION)/60)) AS avg_speed
  FROM pizza_runner.runner_orders ro
  WHERE pickup_time<>'null'
  GROUP BY runner_id
  ORDER BY avg_speed DESC;

-------------------------------------------------------------------------------------------------------------------------------
--7. What is the successful delivery percentage for each runner?
  WITH success_perc AS (
  SELECT runner_id,SUM(CASE WHEN pickup_time='null' THEN 0
  		            ELSE 1 END) AS success, COUNT(order_id) AS all_orders
  FROM pizza_runner.runner_orders
  GROUP BY runner_id
  )
  SELECT runner_id, (100*success/all_orders) AS success_percentage
  FROM success_perc
  ORDER BY success_percentage DESC;

-------------------------------------------------------------------------------------------------------------------------------


-- Section C: Ingredient Optimisation

--1. What are the standard ingredients for each pizza?
  WITH top_sep AS (
  SELECT *, UNNEST(string_to_array(toppings, ', '))::INTEGER AS topps
  FROM pizza_runner.pizza_recipes pz
  )
  SELECT pizza_id,topping_name
  FROM top_sep
  LEFT JOIN pizza_runner.pizza_toppings pt
  ON top_sep.topps = pt.topping_id
  ORDER BY pizza_id;

-------------------------------------------------------------------------------------------------------------------------------
--2. What was the most commonly added extra?
  WITH common_extra AS (
  SELECT UNNEST(string_to_array(extras,', '))::INTEGER AS toppys
  FROM pizza_runner.customer_orders
  WHERE extras<>'null' AND extras IS NOT NULL
  )
  SELECT toppys AS topping_id,topping_name
  FROM common_extra
  INNER JOIN pizza_runner.pizza_toppings pt
  ON common_extra.toppys = pt.topping_id
  GROUP BY toppys,topping_name
  ORDER BY COUNT(toppys) DESC
  LIMIT 1;
  
-------------------------------------------------------------------------------------------------------------------------------
--3. What was the most common exclusion?
  WITH common_exclusion AS (
  SELECT UNNEST(string_to_array(exclusions,', '))::INTEGER AS toppys
  FROM pizza_runner.customer_orders
  WHERE exclusions<>'null' AND exclusions IS NOT NULL
  )
  SELECT toppys AS topping_id,topping_name
  FROM common_exclusion
  INNER JOIN pizza_runner.pizza_toppings pt
  ON common_exclusion.toppys = pt.topping_id
  GROUP BY toppys, topping_name
  ORDER BY COUNT(toppys) DESC
  LIMIT 1;

-------------------------------------------------------------------------------------------------------------------------------
--4. Generate an order item for each record in the customers_orders table in the format of one of the following:
     --a. Meat Lovers
     --b. Meat Lovers - Exclude Beef
     --c. Meat Lovers - Extra Bacon
     --d. Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
  WITH extra AS(	 
  WITH common_extra AS (
  SELECT order_id,pizza_id,UNNEST(string_to_array(extras,', '))::INTEGER AS toppys
  FROM pizza_runner.customer_orders
  WHERE extras<>'null' AND extras IS NOT NULL
  )
  SELECT order_id,pizza_id,STRING_AGG(DISTINCT topping_name,', ') AS extra_str
  FROM common_extra
  INNER JOIN pizza_runner.pizza_toppings pt
  ON common_extra.toppys = pt.topping_id
  GROUP BY order_id,pizza_id
  )
  ,exclusion AS (
  WITH common_exclusions AS (
  SELECT order_id,pizza_id,UNNEST(string_to_array(exclusions,', '))::INTEGER AS toppys
  FROM pizza_runner.customer_orders
  WHERE exclusions<>'null' AND exclusions IS NOT NULL
  )
  SELECT order_id,pizza_id,STRING_AGG(DISTINCT topping_name,', ') AS exc_str
  FROM common_exclusions
  INNER JOIN pizza_runner.pizza_toppings pt
  ON common_exclusions.toppys = pt.topping_id
  GROUP BY order_id,pizza_id
  )
  SELECT co.order_id,co.pizza_id,pizza_name,extra_str,exc_str 
  FROM pizza_runner.customer_orders co
  LEFT JOIN pizza_runner.pizza_names pn
  ON co.pizza_id = pn.pizza_id
  LEFT JOIN extra
  ON co.order_id = extra.order_id AND co.pizza_id = extra.pizza_id
  LEFT JOIN exclusion 
  ON co.order_id = exclusion.order_id AND co.pizza_id = exclusion.pizza_id;
  
-------------------------------------------------------------------------------------------------------------------------------
--5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
--   For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
    WITH extra AS(	 
  WITH common_extra AS (
  SELECT order_id,pizza_id,UNNEST(string_to_array(extras,', '))::INTEGER AS toppys
  FROM pizza_runner.customer_orders
  WHERE extras<>'null' AND extras IS NOT NULL
  )
  SELECT order_id,pizza_id,pt.topping_id,pt.topping_name
  FROM common_extra
  INNER JOIN pizza_runner.pizza_toppings pt
  ON common_extra.toppys = pt.topping_id
  )
  ,exclusion AS (
  WITH common_exclusions AS (
  SELECT order_id,pizza_id,UNNEST(string_to_array(exclusions,', '))::INTEGER AS toppys
  FROM pizza_runner.customer_orders
  WHERE exclusions<>'null' AND exclusions IS NOT NULL
  )
  SELECT order_id,pizza_id,pt.topping_id,pt.topping_name
  FROM common_exclusions
  INNER JOIN pizza_runner.pizza_toppings pt
  ON common_exclusions.toppys = pt.topping_id
  )
  SELECT * 
  FROM exclusion;
  
  
--6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
