
-- Number of sales in each state 

Select state,Count(*) as sales_in_state
from PortfolioProject..car_prices$ 
Group by state

-- We notice that when we run the query above, there are alphanumeric values that aren't states. The problem is in the csv itself; we notice that every state that has that alphanumeric value
-- have a body called navitgation. The most likely posibility is that this navitgation was supposed to be a part of trim (the column before body) but a comma is seperating it. Even if we fix the csv itself
-- we find that sales date isn't even listed in the csv so it would be pointless. The only thing we can do is get rid of these rows. Let's do this by creating a temp table.

DROP TABLE IF EXISTS #new_car_data
SELECT year as manufactured_year,make,model,trim as car_trim ,body,transmission,vin,state,condition,odometer,color,interior,seller,mmr,sellingprice,saledate, SUBSTRING(saledate,12,4) as sale_year, SUBSTRING(saledate,5,3) as sale_monthname,SUBSTRING(saledate,9,2) as sale_day,
Case SUBSTRING(saledate,5,3)
	When 'Jan' Then 1
	When 'Feb' Then 2
	When 'Mar' Then 3
	When 'Apr' Then 4
	When 'May' Then 5
	When 'Jun' Then 6
	When 'Jul' Then 7
	When 'Aug' Then 8
	When 'Sep' Then 9
	When 'Oct' Then 10
	When 'Nov' Then 11
	When 'Dec' Then 12
	Else NULL
	End as sale_month
INTO #new_car_data
FROM PortfolioProject..car_prices$
WHERE body != 'Navitgation'
AND saledate !=''

Select state,Count(*) as sales_in_state
from #new_car_data
Group by state

-- What cars are the most popular? 

Select make,model,count(*) as number_sold
From #new_car_data
Group by make,model
Order by count(*) desc


-- What is the average selling sprice of cars in each state?

Select state, Avg(sellingprice) as avg_selling_price
from #new_car_data
Group by state
order by avg_selling_price ASC;


-- What are the number of sales each month 
Select sale_month,Count(*) as cars_sold
from #new_car_data
group by sale_month
order by sale_month ASC;


--What are the top 5 selling models within each body type?

Select make,
model,
body,
num_sales,
body_rank
FROM(
Select make,model,body,Count(*) as num_sales, Rank() OVER (Partition by body Order by Count(*) Desc) as body_rank
From #new_car_data
Group by make,model,body
) as s
Where body_rank <=5
Order by body ASC, num_sales Desc


-- Find car sales where they are higher than the average for that model and by how much

Select 
make,
model,
vin,
sale_year,
sale_month,
sale_day,
sellingprice,
avg_model,
sellingprice/avg_model as price_ratio
	From(
	Select 
	make,
	model,
	vin,
	sale_year,
	sale_month,
	sale_day,
	sellingprice,
	AVG(sellingprice) OVER(Partition By make,model) as avg_model
	From #new_car_data
	) as s
	Where sellingprice > avg_model 
	Order by sellingprice/avg_model Desc

-- Report on different car makes

Select make, count(Distinct model) as num_models, Count(*) as num_sales, Min(sellingprice) as min_price, Max(sellingprice) as max_price,
Avg(sellingprice) as avg_price
From #new_car_data
group by make
order by avg_price DESC

-- Which cars were sold multiple times?
Select
manufactured_year,
make,
model,
car_trim,
body,
transmission,
vin,
state,
condition,
odometer,
color,
interior,
seller,
mmr,
sellingprice,
saledate, 
sale_year,
sale_monthname,
sale_day,
vin_sales
	From(
	Select 
	manufactured_year,
	make,
	model,
	car_trim,
	body,
	transmission,
	vin,
	state,
	condition,
	odometer,
	color,
	interior,
	seller,
	mmr,
	sellingprice,
	saledate, 
	sale_year,
	sale_monthname,
	sale_day,
	Count(*) OVER (Partition by vin) as vin_sales
	from #new_car_data
	) as s
where vin_sales > 1