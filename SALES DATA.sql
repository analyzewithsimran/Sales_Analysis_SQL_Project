create database sales_data;
use sales_data;

-- 1. Retrieve all records from the sales dataset. 
SELECT * FROM sales_data; 

-- 2. Display all unique product categories available in the dataset. 
SELECT DISTINCT Product_Category FROM sales_data; 

-- 3. Find all sales made by a specific Sales Representative (e.g., Alice). 
SELECT * FROM sales_data WHERE Sales_Rep = 'Alice'; 

-- 4. Get all transactions from the “North” region where the Sales_Amount is above 5000. 
SELECT Region, Sales_Amount FROM  sales_data
WHERE Region = "North" AND Sales_Amount >= 5000;

-- 5. List all customers who paid via “Credit Card” and are ‘Returning’ customers. 
SELECT Sales_Rep as Customer_name, Payment_Method , Customer_Type FROM sales_data
WHERE Payment_Method = "Credit Card" and Customer_Type = "Returning";

-- 6. Retrieve sales records between ‘2023-01-01’ and ‘2023-06-30’.
SELECT * FROM sales_data
WHERE Sale_Date between 01-01-2023 and 30-06-2023
ORDER BY Sale_Date asc;

-- Aggregation & Summarization (Level 2 — Intermediate Queries) 
-- 7. Calculate the total Sales_Amount for each Region.
SELECT Region, SUM(Sales_Amount) as Total_Sales
FROM sales_data
GROUP BY Region
ORDER BY Total_Sales desc;

-- 8. Find the average Unit_Price and Unit_Cost by Product_Category. 
SELECT Product_Category, AVG(Unit_Price) as Avg_unit_price, AVG(Unit_Cost) as Avg_unit_cost
FROM sales_data
GROUP BY Product_Category
ORDER BY Avg_unit_price, Avg_unit_cost desc;

-- 9. Determine the total number of units sold (Quantity_Sold) by each Sales_Rep
SELECT Sales_Rep as Customer_Name, SUM(Quantity_Sold) as Total_Unit_Sold
FROM sales_data
GROUP BY  Customer_Name
ORDER BY Total_Unit_Sold;

-- 10. Identify the highest and lowest Sales_Amount in the dataset. 
SELECT MAX(Sales_Amount) AS Highest_Sales_Amount, MIN(Sales_Amount) AS Lowest_Sales_Amount
FROM sales_data;

--  11. Find the total discount given across all transactions.
SELECT Payment_Method AS Transactions, SUM(Discount) AS Total_Discount
FROM sales_data
GROUP BY Transactions
ORDER BY Total_Discount desc;

--  12. Calculate the average Sales_Amount per month. 
-- (Hint: Use MONTH(Sale_Date) or equivalent date functionSELECT 
SELECT MONTH(Sale_Date) AS Month_Name,
AVG(Sales_Amount) AS Average_Sales_Amount
FROM sales_data
GROUP BY MONTH(Sale_Date)
ORDER BY Month_Name;

-- 13. Show the total sales and total quantity sold per Product_Category and Region. 
SELECT Product_Category, Region, SUM(Sales_Amount) AS Total_Sales,
SUM(Quantity_Sold) AS Total_Sold from sales_data
GROUP BY Product_Category, Region
ORDER BY Total_Sales, Total_Sold desc;

-- 14. Calculate profit for each transaction as 
SELECT Payment_Method, Product_ID,
Sale_Date, Quantity_Sold,
Unit_Price, Unit_Cost,(Unit_Price - Unit_Cost) * Quantity_Sold AS Profit
FROM sales_data
ORDER BY Profit DESC LIMIT 10;

-- Advanced Analysis (Level 3 — Grouping, Subqueries & Window Functions) 
-- 15. Find the best-performing Sales Representative based on total Sales_Amount. 
SELECT Sales_Rep,SUM(Sales_Amount) AS Total_Sales
FROM sales_data
GROUP BY Sales_Rep
ORDER BY Total_Sales DESC LIMIT 1;

--  16. Find the region with the highest total profit. 
SELECT Region, MAX(Sales_Amount) AS Highest_Sales_Amount
FROM sales_data
GROUP BY Region
ORDER BY Highest_Sales_Amount DESC;

# METHOD 2 BY WINDOW FUNTIONS
SELECT Sales_Rep,
SUM(Sales_Amount) AS Total_Sales,
RANK() OVER (ORDER BY SUM(Sales_Amount) DESC) AS Sales_Rank
FROM sales_data
GROUP BY Sales_Rep
ORDER BY Sales_Rank LIMIT 1;


-- 17. Get the top 5 products (Product_ID) with the highest total sales amount.
#METHOD 1 GROUP BY & ORDER BY FUNCTIONS 
SELECT Product_ID AS Products, MAX(Sales_Amount) AS Highest_Total_Sales_Amount
FROM sales_data
GROUP BY Products
ORDER BY Highest_Total_Sales_Amount DESC LIMIT 5;

#METHOD 2 BY SUBQUERY.
SELECT Product_ID, Total_Sales
FROM (SELECT Product_ID, SUM(Sales_Amount) AS Total_Sales
FROM sales_data
GROUP BY Product_ID) AS ProductSales
ORDER BY Total_Sales DESC LIMIT 5;

#METHOD 3 BY WINDOW FUNTIONS 
SELECT Product_ID, Total_Sales
FROM (SELECT Product_ID,
SUM(Sales_Amount) AS Total_Sales,
RANK() OVER (ORDER BY SUM(Sales_Amount) DESC) AS Rank_Position
FROM sales_data GROUP BY Product_ID
) AS RankedProducts
WHERE Rank_Position <= 5
ORDER BY Rank_Position;

-- 18. Find the average discount offered per Product_Category. 
#METHOD 1 BY GROUP BY & ORDER BY FUNCTIONS 
SELECT Product_Category, AVG(Discount) AS Avg_Discount
FROM sales_data
GROUP BY Product_Category
ORDER BY Avg_Discount DESC;

#METHOD 2 BY SUBQUERY 
SELECT Product_Category, Avg_Discount 
FROM (SELECT Product_Category, AVG(Discount) AS Avg_Discount
FROM sales_data
GROUP BY Product_Category) CategoryDiscounts
ORDER BY Avg_Discount DESC;

#METHOD 3 BY WINDOW FUNCTIONS
SELECT DISTINCT Product_Category,
AVG(Discount) OVER (PARTITION BY Product_Category) AS Average_Discount
FROM sales_data
ORDER BY Average_Discount DESC;

-- 19. Identify which Sales_Channel (Online vs Retail) generates more revenue.
#METHOD 1 BY GROUP BY AND ORDER BY FUNCTIONS 
SELECT Sales_Channel, SUM(Sales_Amount) AS Total_Revenue
FROM sales_data
GROUP BY Sales_Channel
ORDER BY Total_Revenue DESC;

#METHOD 2 BY SUBQUERY FUNCTIONS
SELECT Sales_Channel, Total_Revenue
FROM (SELECT Sales_Channel,SUM(Sales_Amount) AS Total_Revenue
FROM sales_data
GROUP BY Sales_Channel
) AS ChannelRevenue
ORDER BY Total_Revenue DESC LIMIT 1;

#METHOD 3 BY WINDOW FUNCTIONS
SELECT Sales_Channel, SUM(Sales_Amount) AS Total_Revenue,
RANK() OVER (ORDER BY SUM(Sales_Amount) DESC) AS Revenue_Rank
FROM sales_data
GROUP BY Sales_Channel
ORDER BY Revenue_Rank;

-- 20. For each Sales_Rep, calculate their average Sales_Amount per transaction. 
#METHOD 1 BY GROUP BY & ORDER BY FUNCTIONS
SELECT Sales_Rep, AVG(Sales_Amount) AS Avg_Sales_Per_Transaction
FROM sales_data
GROUP BY Sales_Rep
ORDER BY Avg_Sales_Per_Transaction DESC;

#METHOD 2 BY WINDOW FUNCTIONS
SELECT DISTINCT Sales_Rep,
AVG(Sales_Amount) OVER (PARTITION BY Sales_Rep) AS Avg_Sales_Per_Transaction
FROM sales_data
ORDER BY Avg_Sales_Per_Transaction DESC;

-- 21. Rank Sales Representatives by total revenue using a window function.
SELECT Sales_Rep,
SUM(Sales_Amount) AS Total_Revenue,
RANK() OVER (ORDER BY SUM(Sales_Amount) DESC) AS Revenue_Rank
FROM sales_data
GROUP BY Sales_Rep
ORDER BY Revenue_Rank;

-- 22.  Find the percentage contribution of each Region to total sales. (Hint: Use subquery or window sum for total.) 
#METHOD BY SUBQUERY FUNCTIONS
SELECT Region, SUM(Sales_Amount) AS Total_Sales,
(SUM(Sales_Amount) * 100.0 / (SELECT SUM(Sales_Amount) FROM sales_data)) AS Percentage_Contribution
FROM sales_data
GROUP BY Region
ORDER BY Percentage_Contribution DESC;

-- 23. Display monthly sales trends (Month vs Total Sales). 
SELECT MONTH(Sale_Date) AS Month_Number,
MONTHNAME(Sale_Date) AS Month_Name,
SUM(Sales_Amount) AS Total_Sales
FROM sales_data
GROUP BY MONTH(Sale_Date), MONTHNAME(Sale_Date)
ORDER BY MONTH(Sale_Date);

-- 24.  Identify any Region-Sales_Rep combinations where the total discount given exceeds 20% of total sales. 
#METHOD 1 BY BASIC QUERY
SELECT Region, Sales_ReP,
SUM(Discount) AS Total_Discount,
SUM(Sales_Amount) AS Total_Sales,
(SUM(Discount) / SUM(Sales_Amount)) * 100 AS Discount_Percentage
FROM sales_data
GROUP BY Region, Sales_Rep
HAVING (SUM(Discount) / SUM(Sales_Amount)) * 100 > 20
ORDER BY Discount_Percentage DESC;

#METHOD 2 BY SUBQUERY
SELECT Region, Sales_Rep,
Total_Discount,
Total_Sales, (Total_Discount / Total_Sales) * 100 AS Discount_Percentage
FROM (SELECT Region,
Sales_Rep,
SUM(Discount) AS Total_Discount,
SUM(Sales_Amount) AS Total_Sales 
FROM sales_data 
GROUP BY Region, Sales_Rep
) AS RegionRepSummary
WHERE (Total_Discount / Total_Sales) * 100 > 20
ORDER BY Discount_Percentage DESC;

-- 25. Compare the average sales amount between New and Returning customers. 
#METHOD 1 BY GROUP BY & ORDER BY FUNCTIONS
SELECT Customer_Type,  -- values like 'New' or 'Returning'
AVG(Sales_Amount) AS Avg_Sales_Amount
FROM sales_data
GROUP BY Customer_Type
ORDER BY Avg_Sales_Amount DESC;

#METHOD 2 BY SUBQUERY FUNCTIONS
SELECT Customer_Type, Avg_Sales_Amount
FROM (SELECT Customer_Type,
AVG(Sales_Amount) AS Avg_Sales_Amount
FROM sales_data 
GROUP BY Customer_Type
) AS CustomerAverages
ORDER BY Avg_Sales_Amount DESC;

#METHOD 3 BY WINDOW FUNCTIONS 
SELECT DISTINCT Customer_Type,
AVG(Sales_Amount) OVER (PARTITION BY Customer_Type) AS Avg_Sales_Amount
FROM sales_data
ORDER BY Avg_Sales_Amount DESC;


-- 26. Bonus (Challenge) Determine the correlation between Discount and Sales_Amount (Hint: Explore COVAR_POP() or analyze trends). 
SELECT ROUND(Discount, 1) AS Discount_Level, 
AVG(Sales_Amount) AS Avg_Sales
FROM sales_data
GROUP BY ROUND(Discount, 1)
ORDER BY Discount_Level;

-- 27.  Find the top-performing month for each Sales Representative. 
WITH MonthlySales AS (SELECT Sales_Rep,
MONTH(Sale_Date) AS Sale_Month,
YEAR(Sale_Date) AS Sale_Year,
SUM(Sales_Amount) AS Total_Sales,
RANK() OVER (PARTITION BY Sales_Rep ORDER BY SUM(Sales_Amount) DESC) AS Sales_Rank
FROM sales_data
GROUP BY Sales_Rep, YEAR(Sale_Date), MONTH(Sale_Date))
SELECT Sales_Rep, Sale_Year, Sale_Month, Total_Sales
FROM MonthlySales
WHERE Sales_Rank = 1;

-- 28. Find the most frequently sold Product_Category for each Region. 
WITH CategoryFrequency AS (SELECT Region, Product_Category, COUNT(*) AS Total_Sales,
RANK() OVER (PARTITION BY Region ORDER BY COUNT(*) DESC) AS Rank_in_Region 
FROM sales_data
GROUP BY Region, Product_Category)
SELECT Region,
Product_Category,
Total_Sales
FROM CategoryFrequency
WHERE Rank_in_Region = 1;

-- Create a summary table showing each Region, total sales, total profit, and average discount. 
CREATE VIEW Region_Summary AS
SELECT Region, SUM(Sales_Amount) AS Total_Sales,
SUM((Unit_Price - Unit_Cost) * Quantity_Sold) AS Total_Profit, 
AVG(Discount) AS Avg_Discount
FROM sales_data
GROUP BY Region;

SELECT * FROM Region_Summary;





