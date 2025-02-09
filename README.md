# Swiggy Data Analysis with Python and SQL

## Introduction
Swiggy is one of India's leading food delivery platforms, connecting millions of users with their favorite restaurants. This project aims to analyze Swiggy's data to uncover insights into user behavior, restaurant performance, and overall business trends. By leveraging SQL queries, we explore various aspects of the data, such as customer preferences, restaurant performance, and revenue trends, to provide actionable insights for business improvement.

![image](https://github.com/user-attachments/assets/e9964ba9-734d-4b4d-aa84-59f28cde2ef3)

## Dataset Overview
This dataset is a manually curated sample designed for advanced SQL practice, particularly focusing on JOIN operations. Unlike real-world Swiggy datasets found on Kaggle or other platforms, which usually contain one or two tables, this dataset includes multiple interconnected tables. The dataset was created by CampusX, a YouTube channel specializing in data science tutorials.

## Relational Schema

![Screenshot 2025-01-30 153106](https://github.com/user-attachments/assets/f66df757-9ae1-489d-96c5-4bc62298bd52)

## ER Diagram

![image](https://github.com/user-attachments/assets/361f5d15-3d09-463b-918c-4934f02f4313)

## Objective
The primary objectives of this project are:

Understand User Behavior: Identify users who have never ordered, their favorite foods, and their ordering patterns.

Analyze Restaurant Performance: Determine the top-performing restaurants, their revenue contributions, and customer satisfaction levels.

Explore Revenue Trends: Analyze month-over-month revenue growth and identify factors influencing revenue.

Identify Key Trends: Discover popular cuisines, most ordered dishes, and paired products.

Customer Retention: Calculate churn rates and identify loyal customers for targeted marketing.

## Workflow
The analysis was conducted in the following steps:

Data Collection: The dataset consists of multiple tables, including users, orders, resto, food, menu, orderdetails, and partner.

Data Exploration: Basic exploration of the dataset to understand the structure and relationships between tables.

SQL Queries: A series of SQL queries were executed to extract insights from the data.

Analysis: The results of the queries were analyzed to derive meaningful insights.

Documentation: The findings were documented in a structured format for easy understanding and future reference.

## SQL Queries and Analysis
1. Users Who Have Never Ordered
   ``` sql
   SELECT u.name 
   FROM users u 
   LEFT JOIN orders o ON u.userid = o.userid 
   WHERE o.orderid IS NULL;
   ```
   Insight: Identified users who have never placed an order, which can help in targeted marketing campaigns.

2. Average Price Per Dish
   ```sql
   SELECT f.fname, ROUND(AVG(m.price), 2) AS AvgPrice 
   FROM menu m 
   JOIN food f ON f.fid = m.fid 
   GROUP BY f.fname 
   ORDER BY AvgPrice DESC;
   ```
   Insight: Determined the average price of each dish, helping to understand pricing trends across different food items.

3. Top Restaurant in Terms of Orders for a Given Month
   ```sql
   SELECT r.name, COUNT(*) AS orderCounts 
   FROM orders o 
   JOIN resto r ON r.rid = o.rid 
   WHERE MONTHNAME(o.date) = 'June' 
   GROUP BY r.name 
   ORDER BY orderCounts DESC 
   LIMIT 1;
   ```
   Insight: Identified the top restaurant in June 2022 based on the number of orders, which can help in recognizing high-performing restaurants.

4. Restaurants with Monthly Sales > X in a Given Month
   ```sql
   SELECT r.name, SUM(o.amount) AS revenue 
   FROM orders o 
   JOIN resto r ON r.rid = o.rid 
   WHERE MONTHNAME(o.date) = 'June' 
   GROUP BY r.name 
   HAVING SUM(o.amount) > 550;
   ```
   Insight: Found restaurants with monthly sales exceeding a specific threshold, indicating high revenue-generating restaurants.

5. Orders with Order Details for a Particular Customer on a Specific Date
   ```sql
   SELECT o.orderid, f.fid, f.fname, r.name 
   FROM orders o 
   JOIN resto r ON r.rid = o.rid 
   JOIN orderdetails od ON od.orderid = o.orderid 
   JOIN food f ON f.fid = od.fid 
   WHERE o.userid = (SELECT userid FROM users WHERE name = 'Ankit') 
   AND o.date BETWEEN '2022-06-10' AND '2022-07-10';
   ```
   Insight: Retrieved detailed order information for a specific customer within a given date range, useful for customer support and personalized marketing.

6. Restaurants with Maximum Repeated Customers
   ```sql
   SELECT r.name, COUNT(*) AS repeatedCustomers 
   FROM (SELECT rid, userid FROM orders GROUP BY rid, userid HAVING COUNT(*) > 1) AS t 
   JOIN resto r ON t.rid = r.rid 
   GROUP BY r.name 
   ORDER BY repeatedCustomers DESC 
   LIMIT 1;
   ```
   Insight: Identified restaurants with the highest number of repeat customers, indicating customer loyalty.

7. Month-over-Month Revenue Growth
   ```sql
   SELECT month, revenue, previousRevenue, 
   ROUND(((revenue - previousRevenue) / previousRevenue) * 100, 2) AS MoM 
   FROM (
       WITH cte AS (
           SELECT MONTHNAME(date) AS month, SUM(amount) AS revenue 
           FROM orders 
           GROUP BY 1
       )
       SELECT month, revenue, LAG(revenue, 1) OVER (ORDER BY revenue) AS previousRevenue 
       FROM cte
   ) t;
   ```
   Insight: Calculated the month-over-month revenue growth, providing insights into business performance over time.

8. Customer's Favorite Food
   ```sql
   WITH cte AS (
       SELECT userid, fid, COUNT(*) AS frequency 
       FROM orders o 
       JOIN orderdetails od ON o.orderid = od.orderid 
       GROUP BY userid, fid
   )
   SELECT u.name, f.fname, frequency 
   FROM cte c1 
   JOIN users u ON c1.userid = u.userid 
   JOIN food f ON f.fid = c1.fid 
   WHERE frequency = (SELECT MAX(frequency) FROM cte c2 WHERE c1.userid = c2.userid);
   ```
   Insight: Identified each customer's favorite food, which can be used for personalized recommendations.

9. Loyal Customers Table
   ```sql
   CREATE TABLE IF NOT EXISTS loyalcustomers (
       userid INT PRIMARY KEY,
       name VARCHAR(255),
       discount INT
   );
   
   INSERT INTO loyalcustomers (userid, name)
   SELECT u.userid, u.name 
   FROM users u 
   JOIN orders o ON o.userid = u.userid 
   GROUP BY userid, name 
   HAVING COUNT(*) > 3;
   ```
   Insight: Created a table to store loyal customers who have placed more than 3 orders, enabling targeted discounts and promotions.

10. Apply Discount for Loyal Customers Based on Their Order Value
    ```sql
    UPDATE loyalcustomers
    SET discount = (
        SELECT SUM(amount) * 0.1 
        FROM orders o 
        WHERE loyalcustomers.userid = o.userid
    );
    ```
    Insight: This query applies a 10% discount based on the total order amount for each loyal customer.

11. Most Paired Products
    ```sql
    SELECT f1.fname AS food1, f2.fname AS food2, COUNT(*) AS frequency 
    FROM orderdetails od1 
    JOIN orderdetails od2 ON od1.orderid = od2.orderid AND od1.fid < od2.fid 
    JOIN food f1 ON od1.fid = f1.fid 
    JOIN food f2 ON f2.fid = od2.fid 
    GROUP BY 1, 2 
    HAVING COUNT(*) > 2 
    ORDER BY 3 DESC;
    ```
    Insight: Discovered the most frequently paired food items, which can be used for combo offers and menu optimization.

12. Users Who Ordered at a Restaurant 3 or More Times
    ```sql
    SELECT u.name 
    FROM users u 
    JOIN orders o ON o.userid = u.userid 
    GROUP BY 1 
    HAVING COUNT(DISTINCT o.rid) >= 3;
    ```
    Insight: Identified users who have ordered from at least 3 different restaurants, indicating diverse preferences.

13. Churn Rate of Users (Percentage of Users Who Stopped Ordering After a Specific Month)
    ```sql
    WITH ActiveBeforeMonth AS (
    SELECT DISTINCT o.userid 
    FROM orders o 
    WHERE o.date < '2022-07-01'
    ),
    ActiveAfterMonth AS (
        SELECT DISTINCT o.userid 
        FROM orders o 
        WHERE o.date > '2022-07-01'
    ),
    ChurnCount AS (
        SELECT b.userid 
        FROM ActiveBeforeMonth b 
        LEFT JOIN ActiveAfterMonth a ON b.userid = a.userid 
        WHERE a.userid IS NULL
    )
    SELECT COUNT(DISTINCT c.userid) AS ChurnedCount, 
    COUNT(DISTINCT b.userid) AS TotalActiveUsersBeforeMonth, 
    COUNT(DISTINCT c.userid) * 100 / COUNT(DISTINCT b.userid) AS ChurnRate 
    FROM ActiveBeforeMonth b 
    LEFT JOIN ChurnCount c ON b.userid = c.userid;
    ```
    Insight: Calculated the churn rate, providing insights into customer retention and areas for improvement.

14. Users Who Have Ordered at More Than 3 Different Restaurants
    ```sql
    SELECT u.name 
    FROM users u 
    JOIN orders o ON o.userid = u.userid 
    GROUP BY 1 
    HAVING COUNT(DISTINCT o.rid) > 3;
    ```
    Insight: Identified users who have ordered from more than 3 different restaurants, indicating their willingness to explore diverse cuisines.

15. Restaurants with the Highest Average Delivery Time in a Specific Month
    ```sql
    SELECT r.name AS RestoName, ROUND(AVG(o.deliverytime), 2) AS AvgDeliveryTime 
    FROM orders o 
    JOIN resto r ON r.rid = o.rid 
    WHERE o.date >= '2022-06-01' AND o.date < '2022-07-01' 
    GROUP BY 1 
    ORDER BY AvgDeliveryTime DESC 
    LIMIT 1;
    ```
    Insight: Found the restaurant with the highest average delivery time in June 2022, which can help identify bottlenecks in delivery operations.

16. Most Popular Cuisine Based on Total Orders
    ```sql
    SELECT r.cuisine, COUNT(o.orderid) AS TotalOrdersPlaced 
    FROM orders o 
    JOIN resto r ON r.rid = o.rid 
    GROUP BY 1 
    ORDER BY TotalOrdersPlaced DESC 
    LIMIT 1;
    ```
    Insight: Determined the most popular cuisine among users, which can guide menu planning and marketing strategies.

17. Percentage Contribution of Each Restaurant to Total Revenue
    ```sql
    SELECT r.name AS RestoName, SUM(o.amount) AS RestoRevenue, 
    ROUND(SUM(o.amount) / (SELECT SUM(amount) FROM orders) * 100, 2) AS PercentageContribution 
    FROM orders o 
    JOIN resto r ON r.rid = o.rid 
    GROUP BY 1 
    ORDER BY PercentageContribution DESC;
    ```
    Insight: Calculated the percentage contribution of each restaurant to Swiggy's total revenue, highlighting high-performing restaurants.

18. Users Who Have Ordered Both Veg and Non-Veg Items
    ```sql
    SELECT u.name AS Name 
    FROM users u 
    JOIN orders o ON o.userid = u.userid 
    JOIN orderdetails od ON od.orderid = o.orderid 
    JOIN food f ON f.fid = od.fid 
    WHERE f.type IN ('Veg', 'Non-veg') 
    GROUP BY 1 
    HAVING COUNT(DISTINCT f.type) = 2;
    ```
    Insight: Identified users who have ordered both veg and non-veg items, indicating diverse food preferences.

19. Restaurants with Low Customer Satisfaction but High Sales
    ```sql
    WITH restoStats AS (
    SELECT r.name AS RestoName, AVG(o.restorating) AS AvgRating, SUM(o.amount) AS TotalSales 
    FROM resto r 
    JOIN orders o ON o.rid = r.rid 
    GROUP BY 1
    ),
    lowerCustomerSatisfaction AS (
        SELECT RestoName, AvgRating, TotalSales 
        FROM restoStats 
        WHERE AvgRating = (SELECT MIN(AvgRating) FROM restoStats)
    )
    SELECT RestoName, AvgRating, TotalSales 
    FROM lowerCustomerSatisfaction 
    ORDER BY TotalSales DESC 
    LIMIT 1;
    ```
    Insight: Identified restaurants with low customer satisfaction ratings but high sales, indicating a need to improve service quality.

20. Restaurants with the Highest Number of Unique Customers in a Specific Month
    ```sql
    SELECT r.name, COUNT(DISTINCT o.userid) AS UniqueCustomers 
    FROM orders o 
    JOIN resto r ON r.rid = o.rid 
    WHERE o.date BETWEEN '2022-06-01' AND '2022-07-01' 
    GROUP BY 1 
    HAVING COUNT(DISTINCT o.userid) = (
        SELECT MAX(UniqueCustomers) 
        FROM (
            SELECT COUNT(DISTINCT userid) AS UniqueCustomers 
            FROM orders o 
            WHERE o.date BETWEEN '2022-06-01' AND '2022-07-01' 
            GROUP BY rid
        ) AS temp
    )
    ORDER BY UniqueCustomers DESC;
    ```
    Insight: Found restaurants with the highest number of unique customers in June 2022, indicating their popularity.

21. Users Who Have Never Placed an Order with a Specific Partner
    ```sql
    SELECT u.userid, u.name AS UserName 
    FROM users u 
    WHERE NOT EXISTS (
        SELECT 1 
        FROM orders o 
        JOIN partner p ON p.partnerid = o.partnerid 
        WHERE o.userid = u.userid AND p.partnername = 'Suresh'
    );
    ```
    Insight: Identified users who have never placed an order with a specific delivery partner, which can help in targeted promotions.

22. List All Food Items and Their Corresponding Restaurant Names
    ```sql
    SELECT DISTINCT(f.fname), r.name 
    FROM orders o 
    JOIN orderdetails od ON od.orderid = o.orderid 
    JOIN food f ON f.fid = od.fid 
    JOIN resto r ON r.rid = o.rid;
    ```
    Insight: This query lists all food items along with the restaurants that serve them, helping users find their favorite dishes across different restaurants.

23. Total Revenue, Number of Orders, and Average Order Value for Each Restaurant by Month
    ```sql
    SELECT r.name AS RestoName, EXTRACT(MONTH FROM o.date) AS month, EXTRACT(YEAR FROM o.date) AS year, 
    SUM(o.amount) AS Revenue, COUNT(o.orderid) AS TotalOrderPlaced, 
    AVG(o.amount) AS AvgOrderValue 
    FROM orders o 
    JOIN resto r ON r.rid = o.rid 
    GROUP BY 1, 2, 3 
    ORDER BY RestoName, month;
    ```
    Insight: Generated a monthly report showing revenue, number of orders, and average order value for each restaurant, aiding in performance tracking.

24. Users Who Have Placed Consecutive Orders on the Same Day
    ```sql
    WITH consecutiveOrders AS (
    SELECT o.userid, o.orderid, o.date, LAG(o.date) OVER (PARTITION BY userid ORDER BY date) AS previousdate 
    FROM orders o
    )
    SELECT c.userid, u.name AS UserName, c.date 
    FROM users u 
    JOIN consecutiveOrders c ON c.userid = u.userid 
    WHERE c.date = c.previousdate;
    ```
    Insight: Identified users who placed consecutive orders on the same day, indicating high engagement.

25. Restaurants with the Highest Number of Orders Containing Only Veg Items
    ```sql
    WITH OnlyVegOrders AS (
    SELECT o.orderid, o.rid 
    FROM orders o 
    JOIN orderdetails od ON od.orderid = o.orderid 
    JOIN food f ON f.fid = od.fid 
    GROUP BY 1, 2 
    HAVING SUM(CASE WHEN f.type <> 'Veg' THEN 1 ELSE 0 END) = 0
    ),
    VegOrderCounts AS (
        SELECT r.name AS RestoName, COUNT(v.orderid) AS OrdersPlaced 
        FROM OnlyVegOrders v 
        JOIN resto r ON r.rid = v.rid 
        GROUP BY 1
    )
    SELECT RestoName, OrdersPlaced 
    FROM VegOrderCounts 
    WHERE OrdersPlaced = (SELECT MAX(OrdersPlaced) FROM VegOrderCounts);
    ```
    Insight: Found restaurants with the highest number of orders containing only veg items, catering to vegetarian customers.

## Key Takeaways
1. Customer Insights: Identified users who have never ordered, their favorite foods, and their ordering patterns.

2. Restaurant Performance: Recognized top-performing restaurants and those with high customer satisfaction.

3. Revenue Trends: Analyzed month-over-month revenue growth and identified factors influencing revenue.

4. Popular Cuisines and Dishes: Discovered the most popular cuisines and frequently paired dishes.

5. Customer Retention: Calculated churn rates and identified loyal customers.

6. Delivery Performance: Analyzed delivery times and identified bottlenecks.

7. Veg vs. Non-Veg Preferences: Identified restaurants with high veg-only orders.

## Conclusion
This project provides a comprehensive analysis of Swiggy's data, offering actionable insights into user behavior, restaurant performance, and revenue trends. By leveraging SQL queries, we uncovered key trends and patterns that can inform business strategies, improve customer satisfaction, and drive revenue growth. The findings from this analysis can be used to optimize marketing campaigns, enhance customer retention, and improve overall business performance.

## Future Work
1. Advanced Analytics: Incorporate machine learning models to predict customer churn and recommend personalized offers.

2. Customer Segmentation: Segment customers based on ordering behavior for targeted marketing.

3. Real-Time Dashboards: Develop real-time dashboards to monitor key performance metrics.
 
