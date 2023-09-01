SET search_path TO data_bank;

--A. Customer Nodes Exploration

--1. How many unique nodes are there on the Data Bank system?
  SELECT COUNT(DISTINCT node_id)
  FROM customer_nodes;

-------------------------------------------------------------------------------------------------------------------------------
--2. What is the number of nodes per region?
  SELECT cn.region_id,region_name, COUNT(DISTINCT node_id) AS node_count
  FROM customer_nodes cn
  INNER JOIN regions r
  ON cn.region_id = r.region_id
  GROUP BY cn.region_id,region_name
  ORDER BY node_count DESC;
-------------------------------------------------------------------------------------------------------------------------------
--3. How many customers are allocated to each region?
  SELECT cn.region_id,region_name,COUNT(DISTINCT customer_id) AS cust_count
  FROM customer_nodes cn
  INNER JOIN regions r
  ON cn.region_id = r.region_id
  GROUP BY cn.region_id,region_name
  ORDER BY cust_count DESC;

-------------------------------------------------------------------------------------------------------------------------------
--4. How many days on average are customers reallocated to a different node?
  SELECT ROUND(AVG(sum_relocation_days),2) AS average_relocation_days 
  FROM (SELECT customer_id,node_id,SUM(end_date - start_date) AS sum_relocation_days
  		FROM customer_nodes
  		WHERE end_date<>'9999-12-31'
  		GROUP BY customer_id,node_id) AS sum_nodes;
  
-------------------------------------------------------------------------------------------------------------------------------
--5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
  WITH CTE AS (
  SELECT region_name,sum_relocation_days,ROW_NUMBER() OVER (PARTITION BY region_name ORDER BY sum_relocation_days) AS rnk
  FROM (SELECT customer_id,region_name,node_id,SUM(end_date - start_date) AS sum_relocation_days
  		FROM customer_nodes cn
		INNER JOIN regions r
		ON cn.region_id = r.region_id
  		WHERE end_date<>'9999-12-31'
  		GROUP BY region_name,customer_id,node_id) AS sum_nodes
  )
  ,MAX_RANK AS (
  SELECT region_name, MAX(rnk) AS max_rank
  FROM CTE
  GROUP BY region_name
  )
  SELECT CTE.region_name,
  CASE WHEN RNK = ROUND(max_rank/2.0) THEN 'Median'
       WHEN RNK = ROUND(max_rank*0.80,0) THEN '80th percentile'
	   WHEN RNK = ROUND(max_rank*0.95,0) THEN '95th percentile'
  END AS METRIC,
  sum_relocation_days AS days
  FROM CTE
  INNER JOIN MAX_RANK
  ON CTE.region_name = MAX_RANK.region_name
  WHERE RNK IN (ROUND(max_rank/2.0),
			    ROUND(max_rank*0.8,0),
			    ROUND(max_rank*0.95,0)
			   );
  
  -------------------------------------------------------------------------------------------------------------------------------
--B. Customer Transactions

--1. What is the unique count and total amount for each transaction type?
  SELECT txn_type AS transaction_type,SUM(txn_amount) AS total_amount, COUNT(*) AS unique_count
  FROM customer_transactions
  GROUP BY txn_type;
  
-------------------------------------------------------------------------------------------------------------------------------  
--2. What is the average total historical deposit counts and amounts for all customers?
  WITH cust_avg_amt AS (
  SELECT customer_id, COUNT(customer_id) AS deposit_count, ROUND(AVG(txn_amount),2) AS total_amount
  FROM customer_transactions
  WHERE txn_type = 'deposit'
  GROUP BY customer_id
  )
  SELECT ROUND(AVG(total_amount),2) AS avg_historical_amt 
  FROM cust_avg_amt;

-------------------------------------------------------------------------------------------------------------------------------
--3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
  WITH CTE AS (
  SELECT EXTRACT('MONTH' FROM txn_date) AS txn_month,
  		 customer_id,
         SUM(CASE WHEN txn_type='deposit' THEN 1 ELSE 0 END) AS deposit_counts,
		 SUM(CASE WHEN txn_type<>'deposit' THEN 1 ELSE 0 END) AS purchase_or_withdrawal
  FROM customer_transactions
  GROUP BY EXTRACT('MONTH' FROM txn_date), customer_id
  ORDER BY customer_id
  )
  SELECT txn_month, COUNT(customer_id)
  FROM CTE
  WHERE deposit_counts>1 AND purchase_or_withdrawal = 1
  GROUP BY txn_month;

-------------------------------------------------------------------------------------------------------------------------------
--4. What is the closing balance for each customer at the end of the month?
  WITH BALANCES AS (
  SELECT DATE_TRUNC('MONTH',txn_date) AS txn_month,
         txn_date,
		 customer_id,
         SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE -(txn_amount) END)AS BALANCE
  FROM customer_transactions
  GROUP BY DATE_TRUNC('MONTH',txn_date),txn_date,customer_id
  ORDER BY txn_month,txn_date
  )
  ,LAST_DATE AS 
  (SELECT *,SUM(BALANCE) OVER (PARTITION BY customer_id ORDER BY txn_date) AS running_sum,
         ROW_NUMBER() OVER (PARTITION BY customer_id, txn_month ORDER BY txn_date DESC) AS rn
  FROM BALANCES
  ORDER BY txn_date
  )
  SELECT customer_id,
         ((txn_month + interval '1 month')- interval '1 day') AS month_end,
		 running_sum AS closing_balance 
  FROM LAST_DATE
  WHERE rn =1;

-------------------------------------------------------------------------------------------------------------------------------
--5. What is the percentage of customers who increase their closing balance by more than 5%?
WITH BALANCES AS (
  SELECT DATE_TRUNC('MONTH',txn_date) AS txn_month,
         txn_date,
		 customer_id,
         SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE -(txn_amount) END)AS BALANCE
  FROM customer_transactions
  GROUP BY DATE_TRUNC('MONTH',txn_date),txn_date,customer_id
  ORDER BY txn_month,txn_date
  )
  ,LAST_DATE AS 
  (SELECT *,SUM(BALANCE) OVER (PARTITION BY customer_id ORDER BY txn_date) AS running_sum,
         ROW_NUMBER() OVER (PARTITION BY customer_id, txn_month ORDER BY txn_date DESC) AS rn
  FROM BALANCES
  ORDER BY txn_date
  )
  , CLOSING_BALANCES AS 
  (SELECT ((txn_month + interval '1 month')- interval '1 day') AS month_end,
		  running_sum AS closing_balance,(txn_month - interval '1 day') AS previous_month_end,*
  FROM LAST_DATE
  WHERE rn =1
  )
  , PERC_CONDITION AS
  (SELECT CB_1.customer_id,
         CB_1.month_end,
		 CB_1.previous_month_end,
		 CB_1.CLOSING_BALANCE AS month_end_balance,
		 CB_2.CLOSING_BALANCE AS previous_month_balance,
		 (CASE WHEN (CB_2.CLOSING_BALANCE/CB_1.CLOSING_BALANCE)>0.05 THEN 1 ELSE 0 END) AS perc_condition 
  FROM CLOSING_BALANCES CB_1
  INNER JOIN CLOSING_BALANCES CB_2
  ON CB_1.MONTH_END = CB_2.PREVIOUS_MONTH_END
  WHERE CB_1.CLOSING_BALANCE<>0
  )
  SELECT ROUND((100*SUM(perc_condition)::NUMERIC/COUNT(customer_id)),2) AS PERC_PEOPLE
  FROM PERC_CONDITION;
  
  -------------------------------------------------------------------------------------------------------------------------------