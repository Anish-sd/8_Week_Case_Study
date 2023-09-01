-- A. Customer Journey

--Based off the 8 sample customers provided in the sample from the subscriptions table, 
--write a brief description about each customer’s onboarding journey.

--Try to keep it as short as possible - 
--you may also want to run some sort of join to make your explanations a bit easier!

  SELECT *
  FROM foodie_fi.SUBSCRIPTIONS S
  INNER JOIN foodie_fi.PLANS PL
  ON S.PLAN_ID = PL.PLAN_ID
  WHERE CUSTOMER_ID <=8;
  
  /* The customer once he joins the service will have a trial period of about one week.
     Then he will have to purchase a basic or a pro plan to continue the service. 
	 Basic monthly plan can be subscribed only monthly whereas the pro plan has the monthly
	 as well as the annual subscription */

--B. Data Analysis Questions
--1. How many customers has Foodie-Fi ever had?
  SELECT COUNT(DISTINCT CUSTOMER_ID) AS TOTAL_CUST
  FROM FOODIE_FI.SUBSCRIPTIONS S;
  
  -------------------------------------------------------------------------------------------------------------------------------
--2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
  SELECT MONTHS, COUNT(CUSTOMER_ID)
  FROM (SELECT EXTRACT('month' FROM start_date) AS MONTHS,*
  FROM FOODIE_FI.SUBSCRIPTIONS S
  INNER JOIN FOODIE_FI.PLANS P
  ON S.PLAN_ID = P.PLAN_ID
  WHERE PLAN_NAME = 'trial') AS MONTH_TABLE
  GROUP BY MONTHS
  ORDER BY MONTHS;

-------------------------------------------------------------------------------------------------------------------------------
--3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
  SELECT PLAN_NAME, COUNT(CUSTOMER_ID) AS PLAN_COUNT
  FROM (SELECT * 
  FROM FOODIE_FI.SUBSCRIPTIONS S
  INNER JOIN FOODIE_FI.PLANS PL
  ON S.PLAN_ID = PL.PLAN_ID
  WHERE EXTRACT('YEAR' FROM START_DATE)>2020) AS PLANS_2021
  GROUP BY PLAN_NAME;

-------------------------------------------------------------------------------------------------------------------------------
--4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
  WITH CHURN_PERC AS (
  SELECT (SELECT COUNT(DISTINCT CUSTOMER_ID) FROM FOODIE_FI.SUBSCRIPTIONS) AS TOTAL_CUST,
          COUNT(DISTINCT CUSTOMER_ID) AS CHURN_CUST
		  FROM FOODIE_FI.SUBSCRIPTIONS S
		  INNER JOIN FOODIE_FI.PLANS P
		  ON S.PLAN_ID = P.PLAN_ID
		  WHERE PLAN_NAME = 'churn'
		  GROUP BY PLAN_NAME
  )
  SELECT *, ROUND((CHURN_CUST*100/TOTAL_CUST),1)
  FROM CHURN_PERC;

-------------------------------------------------------------------------------------------------------------------------------
--5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
  WITH AFTER_TRIAL_CHURN AS (
  SELECT (SELECT COUNT(DISTINCT CUSTOMER_ID) FROM FOODIE_FI.SUBSCRIPTIONS) AS TOTAL_COUNT,
          COUNT(CUSTOMER_ID) AS AFTER_CHURN_COUNT
  		  FROM (SELECT *,ROW_NUMBER() OVER (PARTITION BY CUSTOMER_ID ORDER BY START_DATE) AS ROWSS
  		  FROM FOODIE_FI.SUBSCRIPTIONS S
  		  INNER JOIN FOODIE_FI.PLANS P
  		  ON S.PLAN_ID = P.PLAN_ID
  		  ORDER BY CUSTOMER_ID,START_DATE) AS ROW_NUM_ADD
  		  WHERE ROWSS = 2 AND PLAN_NAME = 'churn'
  )
  SELECT *, ROUND((AFTER_CHURN_COUNT*100)::NUMERIC/TOTAL_COUNT,2) AS AFTER_TRIAL_CHURN_PERC
  FROM AFTER_TRIAL_CHURN;

-------------------------------------------------------------------------------------------------------------------------------
--6. What is the number and percentage of customer plans after their initial free trial?
  WITH ROW_NUM AS (
  SELECT *,ROW_NUMBER() OVER (PARTITION BY CUSTOMER_ID ORDER BY START_DATE) AS ROWSS
  FROM FOODIE_FI.SUBSCRIPTIONS S
  INNER JOIN FOODIE_FI.PLANS P
  ON S.PLAN_ID = P.PLAN_ID
  )
  SELECT PLAN_NAME, COUNT(CUSTOMER_ID), 
  ROUND((100*COUNT(CUSTOMER_ID)::NUMERIC)/(SELECT COUNT(DISTINCT CUSTOMER_ID) FROM ROW_NUM),2) AS PERC
  FROM ROW_NUM
  WHERE ROWSS=2
  GROUP BY PLAN_NAME;
  
-------------------------------------------------------------------------------------------------------------------------------
--7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
  WITH PREVIOUS_PLAN_CTE AS (
  SELECT *,LAG(PLAN_ID, 1) OVER(PARTITION BY CUSTOMER_ID ORDER BY START_DATE) AS PREVIOUS_PLAN
  FROM FOODIE_FI.SUBSCRIPTIONS
  JOIN FOODIE_FI.PLANS USING (PLAN_ID))
  SELECT PLAN_NAME,
  COUNT(CUSTOMER_ID) AS CUSTOMER_COUNT,
  ROUND(100 *COUNT(DISTINCT CUSTOMER_ID) /
               (SELECT COUNT(DISTINCT CUSTOMER_ID) AS DISTINCT_CUSTOMERS
                FROM FOODIE_FI.SUBSCRIPTIONS), 2) AS CUSTOMER_PERCENTAGE
  FROM PREVIOUS_PLAN_CTE
  WHERE PREVIOUS_PLAN=0 
  GROUP BY PLAN_NAME;
-------------------------------------------------------------------------------------------------------------------------------
--8. How many customers have upgraded to an annual plan in 2020?
  SELECT COUNT(CUSTOMER_ID) AS UPGRADED_CUST
  FROM FOODIE_FI.SUBSCRIPTIONS S
  INNER JOIN FOODIE_FI.PLANS P
  ON S.PLAN_ID = P.PLAN_ID
  WHERE S.PLAN_ID = 3 AND EXTRACT('YEAR' FROM START_DATE)='2020';

-------------------------------------------------------------------------------------------------------------------------------
--9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
  WITH PRO_ANNUAL AS(
  SELECT *,ROW_NUMBER() OVER (PARTITION BY CUSTOMER_ID ORDER BY START_DATE) AS RN
  FROM FOODIE_FI.SUBSCRIPTIONS S
  INNER JOIN FOODIE_FI.PLANS P
  ON S.PLAN_ID = P.PLAN_ID
  WHERE CUSTOMER_ID IN (SELECT CUSTOMER_ID
  						FROM FOODIE_FI.SUBSCRIPTIONS S
  						INNER JOIN FOODIE_FI.PLANS P
  						ON S.PLAN_ID = P.PLAN_ID
  						WHERE PLAN_NAME = 'pro annual')
  AND PLAN_NAME NOT IN ('basic monthly','churn','pro monthly')
  )
  ,UPGRADE AS (
  SELECT *,LEAD(START_DATE,1) OVER (PARTITION BY CUSTOMER_ID ORDER BY RN) AS UPGRADED_DATE 
  FROM PRO_ANNUAL
  )
  SELECT ROUND(AVG(upgraded_date - start_date),2) AS AVG_UPGRADE_DAYS
  FROM UPGRADE
  WHERE UPGRADED_DATE IS NOT NULL;

-------------------------------------------------------------------------------------------------------------------------------
--10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
  WITH PRO_ANNUAL AS(
  SELECT *,ROW_NUMBER() OVER (PARTITION BY CUSTOMER_ID ORDER BY START_DATE) AS RN
  FROM FOODIE_FI.SUBSCRIPTIONS S
  INNER JOIN FOODIE_FI.PLANS P
  ON S.PLAN_ID = P.PLAN_ID
  WHERE CUSTOMER_ID IN (SELECT CUSTOMER_ID
  						FROM FOODIE_FI.SUBSCRIPTIONS S
  						INNER JOIN FOODIE_FI.PLANS P
  						ON S.PLAN_ID = P.PLAN_ID
  						WHERE PLAN_NAME = 'pro annual')
  AND PLAN_NAME NOT IN ('basic monthly','churn','pro monthly')
  )
  ,UPGRADE AS (
  SELECT *,LEAD(START_DATE,1) OVER (PARTITION BY CUSTOMER_ID ORDER BY RN) AS UPGRADED_DATE 
  FROM PRO_ANNUAL
  )
  , UPGRADE_DAYS AS (
  SELECT CUSTOMER_ID,(upgraded_date - start_date) AS UPGRADE_DAYS
  FROM UPGRADE
  WHERE UPGRADED_DATE IS NOT NULL
  )
  SELECT BINNED, AVG(UPGRADE_DAYS) FROM (SELECT CUSTOMER_ID,UPGRADE_DAYS,CASE  WHEN UPGRADE_DAYS <30 THEN '0-30'
								  	    WHEN UPGRADE_DAYS <60 THEN '31-60'
										WHEN UPGRADE_DAYS <90 THEN '61-90'
										WHEN UPGRADE_DAYS <120 THEN '91-120'
										WHEN UPGRADE_DAYS <150 THEN '121-150'
										WHEN UPGRADE_DAYS <180 THEN '151-180'
										WHEN UPGRADE_DAYS <210 THEN '181-210'
										WHEN UPGRADE_DAYS <240 THEN '211-240'
										WHEN UPGRADE_DAYS <270 THEN '241-270'
										WHEN UPGRADE_DAYS <300 THEN '271-300'
										WHEN UPGRADE_DAYS <330 THEN '301-330' END AS BINNED
										FROM UPGRADE_DAYS) AS BIN_TABLE
  GROUP BY BINNED;

-------------------------------------------------------------------------------------------------------------------------------
--11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
  WITH PRO_MONTHLY AS (
  SELECT *
  FROM FOODIE_FI.SUBSCRIPTIONS S
  WHERE PLAN_ID = 2
  )
  ,BASIC_MONTHLY AS (
  SELECT *
  FROM FOODIE_FI.SUBSCRIPTIONS S
  WHERE PLAN_ID =1
  )
  SELECT COUNT(*) AS DOWNGRADED_CUST 
  FROM PRO_MONTHLY PM
  INNER JOIN BASIC_MONTHLY BM
  ON PM.CUSTOMER_ID = BM.CUSTOMER_ID
  WHERE EXTRACT('YEAR' FROM BM.START_DATE)='2020' AND BM.START_DATE>=PM.START_DATE;

-------------------------------------------------------------------------------------------------------------------------------