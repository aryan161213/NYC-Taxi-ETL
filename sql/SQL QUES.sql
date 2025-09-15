--Q1. List all trips that happened in January 2023.
--SELECT * FROM nyc_cleaned
--WHERE EXTRACT(MONTH FROM tpep_dropoff_date)=1 AND EXTRACT(YEAR FROM tpep_dropoff_date)=2023
--Q2. Retrieve all trips where payment_type = 'Cash' and fare_amount > 50.
--SELECT * FROM nyc_cleaned 
--WHERE "PaymentDesc"='Cash' And fare_amount>50
--ORDER BY fare_amount;
--Q3. Show the total number of trips per pickup_borough, ordered by highest trips first.
--SELECT "BoroughPickup",COUNT(*)as total_number_of_trips
--From nyc_cleaned 
--GROUP BY "BoroughPickup"
--Order BY total_number_of_trips DESC LIMIT 10
--Q4. Get the top 3 pickup zones by total revenue (SUM(total_amount)).

--SELECT "PickupZone", SUM(total_amount) as total_revenue 
--FROM nyc_cleaned
--Group BY "PickupZone"
--Order BY total_revenue DESC LIMIT 5

--Q5. Find the maximum, minimum, and average tip_amount for trips in Manhattan.
--SELECT MIN(tip_amount) as MINTABLE,MAX(tip_amount) as MAXTABLE,AVG(tip_amount) as AVGTABLE
--FROM nyc_cleaned 
--where "BoroughPickup"='Manhattan'
--Group by "PickupZone"
--ORDER BY AVGTABLE DESC LIMIT 5
--Q6. Calculate tip percentage (tip_amount / total_amount * 100) for each trip and show the top 10 trips with the highest tip percentage.
--SELECT * ,(tip_amount / total_amount * 100) as tip_percentage from nyc_cleaned 
--Order BY tip_percentage DESC limit 10
--Q7. Find all trips where trip duration > 120 minutes but distance < 5 miles (possible anomalies).
--SELECT * from nyc_cleaned 
--where trip_duration>120 AND trip_distance < 5 
--Q8. Show monthly revenue growth percentage compared to the previous month

/*SELECT 
    TO_CHAR(DATE_TRUNC('month', tpep_dropoff_date), 'Mon YYYY') AS month_name,
    SUM(total_amount) AS revenue,
    ROUND(
        ((SUM(total_amount) - LAG(SUM(total_amount)) OVER (ORDER BY DATE_TRUNC('month', tpep_dropoff_date))) 
        / NULLIF(LAG(SUM(total_amount)) OVER (ORDER BY DATE_TRUNC('month', tpep_dropoff_date)), 0) * 100)::numeric
    , 2) AS revenue_growth_percentage
FROM nyc_cleaned
GROUP BY DATE_TRUNC('month', tpep_dropoff_date)
ORDER BY DATE_TRUNC('month', tpep_dropoff_date);
*/
/*Q9. Find the hour of the day with the highest average fare amount.
SELECT avg(fare_amount)as average,EXTRACT(Hour from tpep_dropoff_time) from nyc_cleaned 
where fare_amount>0
GROUP BY EXTRACT(Hour from tpep_dropoff_time)
ORDER BY average DESC LIMIT 10*/
--Q11. Rank each borough by total revenue using a window function (RANK()).


/*	SELECT "BoroughPickup",SUM(total_amount) as "Revenue",
	RANK() over(ORDER BY SUM(total_amount)DESC) as rev_rank
	FROM nyc_cleaned
	GROUP by "BoroughPickup"
*/
--Q12. Calculate the 7-day moving average revenue based on pickup_date.
/*SELECT tpep_pickup_date,
ROUND(
	CAST(
	AVG(SUM(total_amount)) OVER 
	(
	ORDER BY tpep_pickup_date
	ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
	)as numeric
	),2
	) as moving_average
from nyc_cleaned
GROUP by tpep_pickup_date
order by tpep_pickup_daAte
*/
/*Q13. For each company, find:
 • Total revenue
 • Number of trips
 • Rank companies by average fare per trip.
*/
--SELECT DISTINCT("Company_Serve"),SUM(total_amount)as revenue from nyc_cleaned GROUP by "Company_Serve"

--SELECT DISTINCT("Company_Serve"),COUNT(*) from nyc_cleaned
--GROUP BY"Company_Serve"



/*	SELECT 
    "Company_Serve",
    ROUND(CAST(AVG(fare_amount) AS numeric), 2) AS Average,
    RANK() OVER (ORDER BY AVG(fare_amount) DESC) AS rank
FROM nyc_cleaned
GROUP BY "Company_Serve"
ORDER BY rank;
*/

--Q14. Detect duplicate trips (same pickup_datetime, dropoff_datetime, and fare_amount).


/*SELECT COUNT(*),old_tpep_pickup_datetime,old_tpep_dropoff_datetime,fare_amount from nyc_cleaned
GROUP BY old_tpep_pickup_datetime,old_tpep_dropoff_datetime,fare_amount
HAVING COUNT(*)>1
*/

--Q15. Find the top 5% of trips by (fare / distance) ratio to spot possible overcharging.
/*with ranking_table 
as(
	SELECT 
		fare_amount/trip_distance as ratio,
		PERCENT_RANK() over (ORDER BY fare_amount/trip_distance DESC)as percentile
	from nyc_cleaned
)
SELECT * from ranking_table 
where percentile >= 0.95
*/

--q17.Identify pickup zones where at least 80% of total revenue is generated from trips paid by credit card.
/*with "Pure_aggregation"
AS(
	SELECT 
		"PickupZone",SUM(total_amount) as "Revenue","PaymentDesc" 
	from nyc_cleaned
	WHERE "PaymentDesc"='Credit Card'
	GROUP by "PickupZone","PaymentDesc"
	
),
"WINDOWING" 
AS(
		SELECT "PickupZone","Revenue",
		PERCENT_RANK() OVER (ORDER BY "Revenue" DESC ) AS percentile	
		From "Pure_aggregation"
		GROUP BY "Revenue","PickupZone"


)
SELECT * from "WINDOWING" where percentile>=0.80;
*/
--Q18 – Borough Contribution to Tips Determine which borough has the highest tip-to-total-revenue ratio (tips ÷ total revenue).
/*with ranking1
as(
	SELECT 
		"BoroughPickup",SUM(total_amount)as "Revenue",SUM(tip_amount) as "Total_Tips"

	from nyc_cleaned
	GROUP BY "BoroughPickup","tip_amount"
),
ranking_2 
as(
	SELECT 
		"BoroughPickup","Total_Tips","Revenue","Total_Tips"*1.0/"Revenue" as tip_ratio,
		RANK() OVER (ORDER BY "Total_Tips"*1.0/"Revenue" DESC) as  work
	from ranking1
)
SELECT * FROM ranking_2
ORDER BY work
*/

--Q20 – Peak Hours by Borough For each borough, find the top 3 busiest hours of the day based on trip count to help plan fleet availability during peak demand


/*with ranking_1
AS(
	SELECT COUNT(*)as trip_count,"BoroughPickup",EXTRACT(HOUR FROM tpep_dropoff_time) as "HourTime" from nyc_cleaned 
	GROUP BY "BoroughPickup","HourTime"
),
ranking_2
AS(
	SELECT 
		trip_count,"BoroughPickup","HourTime",
		RANK() OVER(PARTITION BY "BoroughPickup" ORDER BY(trip_count)DESC) as rank
		from ranking_1
)
SELECT * from ranking_2 
where rank<=3
ORDER BY "BoroughPickup",rank 
*/
