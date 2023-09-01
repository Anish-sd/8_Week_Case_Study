-- Danny's Diner SQL Case Study

-- 1. What is the total amount each customer spent at the restaurant?

SELECT customer_id, SUM(price) AS total_price
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m
ON s.product_id = m.product_id
GROUP BY customer_id;

-------------------------------------------------------------------------------------------------------------------------------
-- 2. How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(DISTINCT order_date) AS no_days
FROM dannys_diner.sales s
GROUP BY customer_id;

-------------------------------------------------------------------------------------------------------------------------------
-- 3. What was the first item from the menu purchased by each customer?

WITH order_rank AS (
SELECT customer_id, order_date,product_name,RANK() OVER (PARTITION BY customer_id ORDER BY order_date ASC) AS rnk
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m
ON s.product_id = m.product_id
)
  
SELECT customer_id, order_date, product_name
FROM order_rank
WHERE rnk = 1;

-------------------------------------------------------------------------------------------------------------------------------
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

WITH most_ordered AS (
  SELECT product_id, COUNT(product_id)
  FROM dannys_diner.sales s
  GROUP BY product_id
  ORDER BY COUNT(product_id) DESC
  LIMIT 1
)
SELECT customer_id,product_name, COUNT(s.product_id) AS order_count
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m
ON s.product_id = m.product_id
WHERE s.product_id = (SELECT product_id FROM most_ordered)
GROUP BY customer_id,product_name
ORDER BY customer_id;

-------------------------------------------------------------------------------------------------------------------------------
-- 5. Which item was the most popular for each customer?

WITH popular_food AS (
  SELECT customer_id, product_id, COUNT(product_id) AS order_count, RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(product_id) DESC) AS rnk
  FROM dannys_diner.sales s
  GROUP BY customer_id, product_id
)
SELECT customer_id,product_name FROM popular_food
INNER JOIN dannys_diner.menu m
ON popular_food.product_id = m.product_id
WHERE rnk =1
ORDER BY customer_id;

-------------------------------------------------------------------------------------------------------------------------------
-- 6. Which item was purchased first by the customer after they became a member?

WITH after_join AS (
  SELECT s.customer_id, order_date,product_name, join_date, RANK() OVER (PARTITION BY s.customer_id ORDER BY (order_date - join_date)) AS rnk
  FROM dannys_diner.sales s
  LEFT JOIN dannys_diner.menu m
  ON s.product_id = m.product_id
  LEFT JOIN dannys_diner.members mem
  ON s.customer_id = mem.customer_id
  WHERE order_date > join_date
)
SELECT customer_id,product_name,order_date,join_date FROM after_join
WHERE rnk = 1;

-------------------------------------------------------------------------------------------------------------------------------
-- 7. Which item was purchased just before the customer became a member?

WITH before_join AS (
  SELECT s.customer_id, order_date,product_name, join_date, RANK() OVER (PARTITION BY s.customer_id ORDER BY (join_date - order_date)) AS rnk
  FROM dannys_diner.sales s
  LEFT JOIN dannys_diner.menu m
  ON s.product_id = m.product_id
  LEFT JOIN dannys_diner.members mem
  ON s.customer_id = mem.customer_id
  WHERE order_date < join_date
)
SELECT customer_id,product_name,order_date,join_date FROM before_join
WHERE rnk = 1;

-------------------------------------------------------------------------------------------------------------------------------
-- 8. What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id,COUNT(s.product_id) AS items,SUM(price) AS total_amount
FROM dannys_diner.sales s
INNER JOIN dannys_diner.members mem
ON s.customer_id = mem.customer_id
INNER JOIN dannys_diner.menu m
ON s.product_id = m.product_id
WHERE order_date < join_date
GROUP BY s.customer_id;

-------------------------------------------------------------------------------------------------------------------------------
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH pointsss AS (
SELECT customer_id,product_name,price, (CASE WHEN product_name='sushi' THEN price*20 ELSE price*10 END) AS points 
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m
ON s.product_id = m.product_id
)
SELECT customer_id, SUM(points)
FROM pointsss
GROUP BY customer_id
ORDER BY customer_id;

-------------------------------------------------------------------------------------------------------------------------------
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT s.customer_id, SUM(CASE WHEN order_date BETWEEN mem.join_date AND (mem.join_date+integer'6') THEN price*10*2
                          WHEN product_name = 'sushi' THEN price*10*2
                          ELSE price*10 END) AS points
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m
ON s.product_id = m.product_id
INNER JOIN dannys_diner.members mem
ON mem.customer_id = s.customer_id
GROUP BY s.customer_id;

-------------------------------------------------------------------------------------------------------------------------------
