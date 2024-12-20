SQL SERVER NOTES
 
-- Format of comment
_________________________________________________________________________________

Creating tables, updating them, delete (with PK and FK involved), renaming the table
_________________________________________________________________________________

-- We will create 3 tables named Customers, Bikes, and Orders
 
-- Creating Customers Table.
 
CREATE TABLE Customers (
CustomerID INT PRIMARY KEY IDENTITY(1, 1),
FirstName VARCHAR(50),
LastName VARCHAR(50)
);
 

-- Creating Bikes Table
 
CREATE TABLE Bikes (
BikeID INT PRIMARY KEY IDENTITY(1, 1),
Brand VARCHAR(50),
Model VARCHAR(50),
Price DECIMAL(10, 2),
QuantityAvailable INT
);
 
 
-- Creating Orders Table
 
CREATE TABLE Orders (
OrderID INT PRIMARY KEY IDENTITY(1, 1),
CustomerID INT,
BikeID INT,
OrderDate DATE,
Quantity INT,
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
FOREIGN KEY (BikeID) REFERENCES Bikes(BikeID)
);

-- Inserting some data into these tables
 
INSERT INTO Customers (FirstName, LastName) VALUES
('John', 'Doe'),
('Jane', 'Smith');
 
 
INSERT INTO Bikes (Brand, Model, Price, QuantityAvailable) VALUES
('Giant', 'Talon 29', 799.99, 10),
('Trek', 'Marlin 5', 549.99, 15);
 
 
INSERT INTO Orders (CustomerID, BikeID, OrderDate, Quantity) VALUES
(1, 1, '2024-02-22', 2),
(2, 2, '2024-02-23', 1);
 
 
-- Checking the tables values one by one
 
SELECT * FROM Customers;
 
SELECT * FROM Bikes;
 
SELECT * FROM Orders;


------------------------------------------------------------------------------
 
-- Perform DELETE operations
 
-- Since to have data integrity as we are using PK and FK in the tables 
-- We have to check before deleting every time
 
 
-- Delete a customer
-- Before deleting a customer we should check if there are any orders associated 
-- with that customer. If there are, we need to decide whether to also delete 
-- those orders or update their references.
 
 
-- Check for orders associated with the customer
 
SELECT * FROM Orders WHERE CustomerID = 1;
 

-- If no orders are associated, we can delete safely
 
DELETE FROM Customers WHERE CustomerID = 1;
 
-- This query will not work because it is dependent due to foreign key and primary key constraint with the table Orders, So, we have to first delete things in the Orders table.
 
 
 
-- If you want to delete a customer you cannot do it directly, because that customer has purchased some order, so in orders table that OrderID or transaction is linked to CustomerID or name or any other way, so if you delete that Customer, so what will that Order will refer to? Which customer has bought that? Because you have deleted that Customer detail, so it will point to nothing, so to avoid this either first refer that Order to some other thing by Updating that Table first or maybe delete that order first by that customer and then delete the customer data. 
Similarly, if the customer table is linked with multiple tables so you have to first do this work in those tables first and then delete the customer table.

-- First, delete the associated Orders
 
DELETE FROM Orders WHERE CustomerID = 1;
 
 
-- Now, you can safely delete the Customer data
 
DELETE FROM Customers WHERE CustomerID = 1;
 
 
-- Similarly delete on other tables.
 
 
------------------------------------------------------------------------------
 

 
-- Altering the table
 
alter table orders
add foreign key (ord_id) references customer(cust_id);
 
alter table orders 
drop constraint ord_id;

-- Renaming the table
 
EXEC sp_rename 'Bikes', 'Bike';
 
EXEC sp_rename 'Bike', 'Bikes';
 





_________________________________________________________________________________


STORED PROCEDURE


 
DATABASE: ADVENTURE WORKS DB WAREHOUSE



 
USE AdventureWorksDW2017;
 
SELECT * FROM DimProduct;
 
SELECT * FROM DimProductSubcategory;
 
SELECT * FROM DimProductCategory;
 
 
-- DimProduct (ProductSubcategoryKey) is linked with DimProductSubcategory (ProductSubcategoryKey)  
 
-- Trying out left join
 
SELECT P.EnglishProductName, PSC.EnglishProductSubcategoryName
FROM DimProduct P
INNER JOIN DimProductSubcategory PSC
ON
P.ProductSubcategoryKey = PSC.ProductSubcategoryKey
ORDER BY P.DaysToManufacture;
 
 
 
------------------------------------------------------------------------------
 
-- Creating a basic SP on select statement
SELECT DISTINCT(StandardCost) FROM DimProduct;
 
SELECT ProductKey, EnglishProductName, StandardCost, DealerPrice
FROM DimProduct
ORDER BY DealerPrice DESC;
 
-- Making this select query as stored procedure 
 
-- GO statement begins a new batch
GO
 
-- SP must start with a batch
CREATE PROC spProductList
AS
BEGIN
SELECT ProductKey, EnglishProductName, StandardCost, DealerPrice
FROM DimProduct
ORDER BY DealerPrice DESC
END




-- SP with a single parameter
 
GO
 
CREATE PROC spProductListParam (@MinPrice AS INT)
AS
BEGIN
SELECT ProductKey, EnglishProductName, StandardCost, DealerPrice
FROM DimProduct
WHERE DealerPrice > @MinPrice
ORDER BY DealerPrice DESC
END
 


 
-- SP with multiple parameters
 
GO
 
CREATE PROC spProductListMultiParam 
(
@MinPrice AS INT, 
@MaxPrice AS INT
)
AS
BEGIN
SELECT ProductKey, EnglishProductName, StandardCost, DealerPrice
FROM DimProduct
WHERE 
DealerPrice >= @MinPrice
AND
DealerPrice <= @MaxPrice
ORDER BY 
DealerPrice DESC
END
 



-- SP with multiple parameters and text
 
GO
 
CREATE PROC spProductListTextParam 
(
@MinPrice AS INT, 
@MaxPrice AS INT,
@Title AS VARCHAR(MAX) 
)
AS
BEGIN
SELECT ProductKey, EnglishProductName, StandardCost, DealerPrice
FROM DimProduct
WHERE 
DealerPrice >= @MinPrice
AND
DealerPrice <= @MaxPrice
AND
EnglishProductName LIKE '%' + @Title + '%'
ORDER BY 
DealerPrice DESC
END


-- Creating optional and default values for parameters
-- If you provide default value in SP then in the execute statement you don't have to give its paramater value 
-- Here the default value is set to 0 or null for MinPrice
-- Since we don't know the max price for how high it can go so we set it as null
-- Now we have to handle NULL in where clause for every variable where it is set to NULL
 
CREATE PROC spProductListOptParam 
(
@MinPrice AS INT = 0, 
@MaxPrice AS INT = NULL,
@Title AS VARCHAR(MAX) 
)
AS
BEGIN
SELECT ProductKey, EnglishProductName, StandardCost, DealerPrice
FROM DimProduct
WHERE
(@MinPrice IS NULL OR DealerPrice >= @MinPrice)
AND
(@MaxPrice IS NULL OR DealerPrice <= @MaxPrice)
AND
EnglishProductName LIKE '%' + @Title + '%'
ORDER BY 
DealerPrice DESC
END


-- SP on FactInternetSales on year
GO
DECLARE @Yr AS INT;
SET @Yr = 2013;
 
SELECT SalesOrderNumber, YEAR(ShipDate) AS Yr
FROM 
FactInternetSales
WHERE YEAR(ShipDate) > @Yr;


Execution
USE AdventureWorksDW2017;
 
EXECUTE dbo.spProductList;
 
EXECUTE dbo.spProductListParam 2100;
 
 
-- Always name your parametrs to avoid confusion
EXECUTE dbo.spProductListMultiParam @MinPrice = 800, @MaxPrice = 1200;
 
EXECUTE spProductListTextParam @MinPrice = 0, @MaxPrice = 1900, @Title = 'helmet';
 
 
-- Executing default and optional SP
-- All three will work because it is upto us if we want to give MinPrice and MaxPrice 
-- Bcz we have set its default value but title is mandatory because it is not set by default so we ahve to give the title
EXECUTE dbo.spProductListOptParam @Title = 'helmet';
 
EXECUTE dbo.spProductListOptParam @Title = 'helmet', @MinPrice = 0;
 
EXECUTE dbo.spProductListOptParam @Title = 'helmet', @MinPrice = 0, @MaxPrice = 1900;







______________________________________________________________________________
-------------------------------------------------------------------------------
WINDOW FUNCTIONS
-------------------------------------------------------------------------------
 
 
1.	OVER and PARTITION BY
2.	RANK
3.	DENSE_RANK
4.	ROW_NUMBER
5.	FIRST_VALUE
6.	LAST_VALUE
7.	FRAMES
8.	NTH_VALUE
9.	LAG
10.	LEAD
11.	Ranking
12.	Cumulative Sum
13.	Cumulative Average
14.	Running Average
15.	Percent of total


Window functions work sort of group by but group by returns the single value for each groups and window functions return the value for all rows in the table.

DATA FOR OUR EXAMPLES
 
CREATE TABLE marks_table (
student_id INTEGER PRIMARY KEY IDENTITY(1, 1),
    student_name VARCHAR(255),
    branch VARCHAR(255),
    marks INTEGER
);
 
 
INSERT INTO marks_table (student_name,branch,marks) 
VALUES 
('Nitish','EEE',82),
('Rishabh','EEE',91),
('Anukant','EEE',69),
('Rupesh','EEE',55),
('Shubham','CSE',78),
('Ved','CSE',43),
('Deepak','CSE',98),
('Arpan','CSE',95),
('Vinay','ECE',95),
('Ankit','ECE',88),
('Anand','ECE',81),
('Rohit','ECE',95),
('Prashant','MECH',75),
('Amit','MECH',69),
('Sunny','MECH',39),
('Gautam','MECH',51);
 
 
SELECT * FROM marks_table;
 

SELECT branch, AVG(marks) AS 'average'
FROM marks
GROUP BY branch;
 

Now we will group it by student name as well.
 
 
SELECT student_name, branch, AVG(marks) AS 'average'
FROM marks_table
GROUP BY student_name, branch;

 

-- Now we will do the same thing with the help of window function
-- We will use first use OVER and then also PARTITION BY
-- As you can see the last column `average marks` is same for every student
-- which means it is the average of all the marks, it has not done any groupint
-- If you want to group and then calculate average then use PARTITION BY
 
SELECT *, AVG(marks) OVER() AS 'average marks'
FROM marks_table;
 
Since in above you did not specify anything in OVER so it assumed the whole data as a window to calculate the average.
 
------------------------------------------------------------------------------
 
-- Now every student marks should show with its branch average only not all
 
SELECT *, AVG(marks) OVER(PARTITION BY branch) AS 'average by branch'
FROM marks_table;
 
As you can see average is different now for CSE and ECEC and others.
------------------------------------------------------------------------------
 
-- Now we will get min and max marks from entire data with window function
 
SELECT *,
MIN(marks) OVER() AS 'min marks',
MAX(marks) OVER() AS 'max marks'
from marks_table;
 
-- Now we will get min and max marks of branch as well from entire data 
 
SELECT *,
MIN(marks) OVER() AS 'min marks',
MIN(marks) OVER(PARTITION BY branch) AS 'min branch marks',
MAX(marks) OVER() AS 'max marks',
MAX(marks) OVER(PARTITION BY branch) AS 'max branch marks'
from marks_table
ORDER BY student_id;

 

------------------------------------------------------------------------------
 
-- Find all the students who have marks higher than the avg marks of their respective branch
 
-- Step 1
-- We will get the branch average for every student (their branch average only)
 
SELECT *,
AVG(marks) OVER (PARTITION BY branch) AS 'branch avg'
FROM marks_table;
 
-- Step 2
-- Since in step 1 we have normal marks as well as branch avg marks
-- So we just have to filter out by comparing the marks with average branch marks column
-- we will use the table as step one and use where condition
 
SELECT * FROM
(SELECT *,
AVG(marks) OVER (PARTITION BY branch) AS 'branch avg'
FROM marks_table) t
WHERE t.marks > t."branch avg";

 
Now you will see only those students who have scored marks higher than their respective branch average marks.





------------------------------------------------------------------------------

RANK, DENSE_RANK, ROW_NUMBER
 
-- RANK
-- We have to rank each students based on their marks in their branch only not all
 
-- First we will do the ranking on whole data
 
SELECT * ,
RANK() OVER(ORDER BY marks DESC) AS 'rank' 
FROM marks_table;

 
We have ranked the data based on column marks. Where we can see Deepak is the college topper.
 
-- Now we will include branch wise ranks
 
SELECT * ,
RANK() OVER(PARTITION BY branch ORDER BY marks DESC) AS 'branch wise rank' 
FROM marks_table;
 
Look at Vinay and Rohit in ECE, they both have same marks so RANK() function has assigned the same rank to both of them.
One more interesting thing is after one, rank two should come at Ankit but he has been assigned with rank 3 because RANK() function has use one two times.
 
 
-- DENSE_RANK
 
-- DENSE_RANK
 
SELECT * ,
RANK() OVER(PARTITION BY branch ORDER BY marks DESC) AS 'branch wise rank',
DENSE_RANK() OVER(PARTITION BY branch ORDER BY marks DESC) AS 'branch wise DENSE_RANK' 
FROM marks_table;
 
-- ROW_NUMBER
 
-- We have take the whole data as a window and assinging row numbers to it and it is order dependent
 
SELECT *,
ROW_NUMBER() OVER(ORDER BY student_id  ASC) AS 'row_number'
FROM marks_table;
 
-- Now assigning row number branch wise
 
SELECT *,
ROW_NUMBER() OVER(PARTITION BY branch ORDER BY student_id  ASC) AS 'row_number branch wise'
FROM marks_table;
 


-- Use of row number example
 
SELECT *,
CONCAT( branch, ' - ', ROW_NUMBER() OVER(PARTITION BY BRANCH ORDER BY student_id)) AS 'branch_code_for_stud'
FROM marks_table;
 


--------------------------------------------------------------------
-- Now first see the orders table
 
SELECT * FROM orders_zomato;

 

-- Now find top 2 customers for every month with WF
-- For this we have to group by on two things first is month then the users
-- We have to extract months first
 
SELECT date, MONTH(date), FORMAT(date, 'MMMM') AS 'Month Name'  FROM orders_zomato;
 
-- You cannot use Alias name in group by, you have to write the whole function
 
SELECT FORMAT(date, 'MMMM') AS 'Month_Name',
user_id,
SUM(amount) AS 'sum_amt'
FROM orders_zomato
GROUP BY FORMAT(date, 'MMMM'), user_id
ORDER BY 'Month_Name' DESC;
 

-- Now we will rank the customers on the basis of sum amount of each month
 
SELECT FORMAT(date, 'MMMM') AS 'Month_Name', user_id, SUM(amount) AS 'sum_amt',
RANK() OVER(PARTITION BY FORMAT(date, 'MMMM') ORDER BY SUM(amount) DESC) AS 'Rank'
FROM orders_zomato
GROUP BY FORMAT(date, 'MMMM'), user_id
ORDER BY 'Month_Name' DESC;
 

-- Now we will use this above query data as a subquery 
-- because we have to filter out the top 2 customers only
 
SELECT * FROM
(SELECT FORMAT(date, 'MMMM') AS 'Month_Name', user_id, SUM(amount) AS 'sum_amt',
RANK() OVER(PARTITION BY FORMAT(date, 'MMMM') ORDER BY SUM(amount) DESC) AS 'Rank'
FROM orders_zomato
GROUP BY FORMAT(date, 'MMMM'), user_id) temp
WHERE temp.Rank < 3
ORDER BY temp.Month_Name DESC, temp.Rank ASC;
 

----------------------------------------------------------------------------------------------------------------------------------------------
 
FIRST VALUE, LAST VALUE
 
-- FIRST_VALUE()
 
SELECT * FROM marks_table;
 

-- We need to get the name of the student with highest marks with WF
 
SELECT * ,
FIRST_VALUE(student_name) OVER(ORDER BY marks DESC),
FIRST_VALUE(marks) OVER(ORDER BY marks DESC)
FROM marks_table;
 

-- LAST_VALUE()
 
SELECT * ,
LAST_VALUE(student_name) OVER(ORDER BY marks DESC),
LAST_VALUE(marks) OVER(ORDER BY marks DESC)
FROM marks_table;
 

-- It does not show us the results like the first value
-- lowest marks should be the same for everyone but the out varies every time
-- This occurs due to the concept of frames
-- It does not show us 39 for every row like it did for the first value 98.
 


FRAMES
 


So the last row creates a window like:
91, only window so the answer is 91
 
91
89
Here last value is 89 so the answer changes to 89. Note 39 is still not there.
Now,
91
89
88
Now the last value is 88, so the answer will be 88.
 
This also occurs in the first value but since the data is sorted so we get 98.
98
Only window so we get 98.
98
91
Now we get 98 because it is first value, so whatever below windows are created we will get 98 only.

The default frame is ROW BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW. Which is working in the above example.

 

1st row and last row.
Means you will consider the entire data because you have selected the first and last value as your frame.
 
 
Now to get the lowest mark
 
SELECT * ,
LAST_VALUE(marks) OVER(ORDER BY marks DESC 
ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM marks_table;

 

-- Find the name and marks for every branch topper
-- The result should have only the toppers of all the branches only
 
SELECT * ,
FIRST_VALUE(student_name) OVER(PARTITION BY branch ORDER BY marks DESC),
FIRST_VALUE(marks) OVER(PARTITION BY branch ORDER BY marks DESC)
FROM marks_table;
 

LEAD AND LAG
-- LAG()
 
SELECT *,
LAG(marks) OVER(ORDER BY student_id)
FROM marks_table;
 

-- LEAD()
 
SELECT *,
LEAD(marks) OVER(ORDER BY student_id)
FROM marks_table;
 

-- Now we will see the lead and lag marks branch wise
 
SELECT *,
LAG(marks) OVER(PARTITION BY branch ORDER BY student_id) AS 'Lag_Mark',
LEAD(marks) OVER(PARTITION BY branch ORDER BY student_id) AS 'Lead_Mark'
FROM marks_table;
 


-- Find the MoM (month on month) growth of Zomato

 

SELECT FORMAT(date, 'MMMM'), SUM(amount)
FROM orders_zomato
GROUP BY FORMAT(date, 'MMMM')
ORDER BY FORMAT(date, 'MMMM') DESC;

 

 

 

SELECT FORMAT(date, 'MMMM'), SUM(amount),
(SUM(amount) - LAG(SUM(amount)) OVER(ORDER BY FORMAT(date, 'MMMM') DESC)) / LAG(SUM(amount)) OVER(ORDER BY FORMAT(date, 'MMMM') DESC)
FROM orders_zomato
GROUP BY FORMAT(date, 'MMMM')
ORDER BY FORMAT(date, 'MMMM') DESC;
 









------------------------------------------------------------------
JOINS
------------------------------------------------------------------
 
What are SQL joins?
In SQL (Structured Query Language), a join is a way to combine data from two or more 
database tables based on a related column between them. Joins are used when we want to 
query information that is distributed across multiple tables in a database, and the 
information we need is not contained in a single table. By joining tables together, 
we can create a virtual table that contains all of the information we need for our query.
 

Cross Joins -> Cartesian Products
In SQL, a cross join (also known as a Cartesian product) is a type of join that 
returns the Cartesian product of the two tables being joined. In other words, 
it returns all possible combinations of rows from the two tables. 
Cross joins are not commonly used in practice, but they can be useful in certain 
scenarios, such as generating test data or exploring all possible combinations of 
items in a product catalogue. However, it's important to be cautious when using 
cross joins with large tables, as they can generate a very large result set, 
which can be resource-intensive and slow to process.
 

Inner Joins
In SQL, an inner join is a type of join operation that combines data from two or 
more tables based on a specified condition. The inner join returns only the rows 
from both tables that satisfy the specified condition, i.e., the matching rows. 
When you perform an inner join on two tables, the result set will only contain 
rows where there is a match between the joining columns in both tables. If there 
is no match, then the row will not be included in the result set.
 

Left Join
A left join, also known as a left outer join, is a type of SQL join operation 
that returns all the rows from the left table (also known as the "first" table) 
and matching rows from the right table (also known as the "second" table). 
If there are no matching rows in the right table, the result will contain NULL values 
in the columns that come from the right table. In other words, a left join combines 
the rows from both tables based on a common column, but it also includes all the rows 
from the left table, even if there are no matches in the right table. This is useful 
when you want to include all the records from the first table, but only some records 
from the second table.
 

Right Join
A right join, also known as a right outer join, is a type of join operation in SQL 
that returns all the rows from the right table and matching rows from the left table. 
If there are no matches in the left table, the result will still contain all the rows 
from the right table, with NULL values for the columns from the left table.
 

Full Outer Join
A full outer join, sometimes called a full join, is a type of join operation in SQL 
that returns all matching rows from both the left and right tables, as well as any 
non-matching rows from either table. In other words, a full outer join returns all 
the rows from both tables and matches rows with common values in the specified columns 
and fills in NULL values for columns where there is no match.
 

 

SQL Set Operations

1.	UNION: The UNION operator is used to combine the results of two or more SELECT 
statements into a single result set. The UNION operator removes duplicate rows between 
the various SELECT statements. 

2.	UNION ALL: The UNION ALL operator is similar to the UNION operator, but it does 
not remove duplicate rows from the result set.

3.	INTERSECT: The INTERSECT operator returns only the rows that appear in both result 
sets of two SELECT statements.

4.	EXCEPT: The EXCEPT or MINUS operator returns only the distinct rows that appear 
in the first result set but not in the second result set of two SELECT statements.

 

 

Self Joins
A self join is a type of join in which a table is joined with itself. 
This means that the table is treated as two separate tables, with each row in the table 
being compared to every other row in the same table. Self joins are used when you want 
to compare the values of two different rows within the same table. For example, 
you might use a self join to compare the salaries of two employees who work in the 
same department, or to find all pairs of customers who have the same billing address.
 
 
---------------------------------------------------------------------

Joins hands on code

----------------------------------------------------------------------
----------------------------------------------------------------------

INNER JOIN

SELECT * FROM membership t1
INNER JOIN users t2
ON t1.user_id = t2.user_id;
 
----------------------------------------------------------------------
----------------------------------------------------------------------

LEFT JOIN

SELECT * FROM membership t1
LEFT JOIN users t2
ON t1.user_id = t2.user_id;

----------------------------------------------------------------------
----------------------------------------------------------------------

RIGHT JOIN

SELECT * FROM membership t1
RIGHR JOIN users t2
ON t1.user_id = t2.user_id;
 
----------------------------------------------------------------------
----------------------------------------------------------------------

FULL OUTER JOIN

SELECT * FROM membership t1
FULL OUTER JOIN users t2
ON t1.user_id = t2.user_id;
 
----------------------------------------------------------------------
----------------------------------------------------------------------

CROSS JOIN

SELECT * FROM users t1
CROSS JOIN
Groups t2;
 
----------------------------------------------------------------------
----------------------------------------------------------------------

SET OPERATIONS
 
DATA
 
Person1 table
 
Person2 table
 


UNION
It does not contain duplicates
 


UNION ALL
It contains duplicates.
 


INTERSECT
 


EXCEPT
 


If tables person1 and person2 are reversed for except then:
 
 

----------------------------------------------------------------------
----------------------------------------------------------------------

Jugaad for Full Outer Join
Take left outer join
UNION
Take right outer join

----------------------------------------------------------------------
----------------------------------------------------------------------

SELF JOIN

SELECT * FROM users1_joins t1
JOIN users1_joins t2
ON t1.emergency_contact = t2.user_id;

 
----------------------------------------------------------------------
----------------------------------------------------------------------

QUERY EXECUTION ORDER

F (FROM)
J (JOIN)
G (GROUP)
H (HAVING)
S (SELECT)
D (DISTINCT)
0 (ORDER)
 

----------------------------------------------------------------------
----------------------------------------------------------------------

JOINING ON MORE THAN ONE COLUMNS
 

Usually, we perform join only on basis of class id of student and class.
But what if we want hod of student which can be different in every year,
So now we have to first join on class id and also join on enrolment year and class year.

 

Normal Join
SELECT * FROM students_joins t1
JOIN class_joins t2
ON t1.class_id = t2.class_id;

 

Join with two columns.
SELECT * FROM students_joins t1
JOIN class_joins t2
ON t1.class_id = t2.class_id
AND t1.enrollment_year = t2.class_year;

 

JOIN MORE THAN 2 TABLES
 
Data overview:

 


-- In order details we need name of customer
-- Since there is no common column b/w order details and users, so no direct join
-- We have to use another table to reach our goal
-- Order_details -> merge with Orders, then merge with -> users

 

-- First Join
 
SELECT * FROM order_details_joins_flipkart t1
JOIN orders_joins_flipkart t2
ON t1.order_id = t2.order_id;

 

-- Main Join
 
SELECT * FROM order_details_joins_flipkart t1
JOIN orders_joins_flipkart t2
ON t1.order_id = t2.order_id
JOIN users_joins_flipkart t3
ON t3.user_id = T2.user_id;

 

----------------------------------------------------------------------------------------------------------------------------------------------
 
-- Find order_id, name, city by joining users and orders
 
SELECT t1.order_id, t2.name, t2.city 
FROM orders_joins_flipkart t1
JOIN users_joins_flipkart t2
ON t1.user_id = t2.user_id;

 

-- Find order_id, product category by joining order_details and category
 
SELECT order_id, category
FROM order_details_joins_flipkart t1
JOIN category_joins_flipkart t2
ON t1.category_id = t2.category_id;

 

-- Find orders placed in Pune
 
SELECT * FROM orders_joins_flipkart t1
JOIN users_joins_flipkart t2
ON t1.user_id = t2.user_id
WHERE t2.city = 'Pune';


 

-- Find all profitable orders
 
-- Since a single order has multiple orders with each of its profit and loss
-- So we have to group by on order id and sum on profit
-- And also we need only those who has sum > 0 since only profitable items are needed
 
SELECT * FROM orders_joins_flipkart t1
JOIN order_details_joins_flipkart t2
ON t1.order_id = t2.order_id;

 


SELECT t1.order_id, SUM(t2.profit) FROM orders_joins_flipkart t1
JOIN order_details_joins_flipkart t2
ON t1.order_id = t2.order_id
GROUP BY t1.order_id
HAVING SUM(t2.profit) > 0 ;
 




-- Find the customer who has placed maximum number of orders
 
SELECT TOP(1) 
t2.name , COUNT(*) FROM orders_joins_flipkart t1
JOIN users_joins_flipkart t2
ON t1.user_id = t2.user_id
GROUP BY t2.name
ORDER BY COUNT(*) DESC ;
 

-- Which is the most profitable category
 
SELECT TOP(1)
t2.category, SUM(t1.profit) FROM order_details_joins_flipkart t1
JOIN category_joins_flipkart t2
ON t1.category_id = t2.category_id
GROUP BY t2.category
ORDER BY SUM(t1.profit) DESC ;

 

-- Which is the most profitable state
 
SELECT * FROM orders_joins_flipkart t1
JOIN order_details_joins_flipkart t2
ON t1.order_id = t2.order_id
JOIN users_joins_flipkart t3
ON t1.user_id = t3.user_id;

 

SELECT TOP(1)
t3.state, SUM(t2.profit) FROM orders_joins_flipkart t1
JOIN order_details_joins_flipkart t2
ON t1.order_id = t2.order_id
JOIN users_joins_flipkart t3
ON t1.user_id = t3.user_id
GROUP BY t3.state
ORDER BY SUM(t2.profit) DESC;

 

-- Find all categories with profit higher than 3000
 
SELECT t2.category, SUM(profit) 
FROM order_details_joins_flipkart T1
JOIN category_joins_flipkart t2
ON t1.category_id = t2.category_id
GROUP BY t2.category
HAVING SUM(profit) > 3000;

 

----------------------------------------------------------------------
----------------------------------------------------------------------




















----------------------------------------------------------------------
----------------------------------------------------------------------

SORTING AND GROUPING

----------------------------------------------------------------------
----------------------------------------------------------------------


 
SELECT * FROM smartphones_campusx;
 

-- Find top 5 samsung phones with biggest screen size
 
SELECT TOP(5)
model, screen_size, price FROM smartphones_campusx
WHERE
brand_name = 'samsung'
ORDER BY screen_size DESC;
 


-- Get me the phones with total cameras in desc order
-- We don't have total cameras in data, we have front and rear so we will add them
 
SELECT model, num_rear_cameras, num_front_cameras, 
num_rear_cameras + num_front_cameras AS 'Total Cameras'  
FROM smartphones_campusx
ORDER BY 'Total Cameras' DESC;
 



----------------------------------------------------------------------

-- Find the phone with 2nd or 6rd largest battery
 
SELECT model, battery_capacity
FROM smartphones_campusx
ORDER BY battery_capacity DESC;
 
 
 
 

----------------------------------------------------------------------------------------------------------------------------------------------
 
-- Find the name and rating of worst rated apple phone
 
SELECT TOP(1)
model, rating
FROM smartphones_campusx
WHERE brand_name = 'apple' 
ORDER BY rating ASC;
 


SELECT TOP(1)
model, rating
FROM smartphones_campusx
WHERE brand_name = 'apple' AND rating IS NOT NULL
ORDER BY rating ASC;
 

-- Best apple phone rating wise
 
SELECT TOP(1)
model, rating
FROM smartphones_campusx
WHERE brand_name = 'apple' AND rating IS NOT NULL
ORDER BY rating DESC;
 

-- Sorting based on two columns
 
SELECT *
FROM smartphones_campusx
ORDER BY brand_name ASC, price DESC;
 


----------------------------------------------------------------------------------------------------------------------------------------------

GROUPING DATA
 
SELECT * FROM smartphones_campusx;
 

Group data like this below figure:
 

-- Group smaprtphones by brand and get the count
 
SELECT brand_name, COUNT(*) AS 'num_phones'
FROM smartphones_campusx
GROUP BY brand_name
ORDER BY 'num_phones' DESC;
 

-- Now we will get the average price as well
 
SELECT TOP (5)
brand_name, COUNT(*) AS 'num_phones', AVG(price) AS 'avg_price'
FROM smartphones_campusx
GROUP BY brand_name
ORDER BY 'num_phones' DESC;

 

-- Group smartphones on whether they have fast_charging_available & get the average price and rating
 
SELECT fast_charging_available,
AVG(price) AS 'avg_price',
AVG(rating) AS 'avg_rating'
FROM smartphones_campusx
GROUP BY fast_charging_available;
 
-- o/p will be 0 and 1, 0 means false, 1 means true
-- If you group on has_nfc and has_5g, both columns has 2 values only true & false
-- So the o/p will have cartesian product of each column which is grouped, i.e. 2 * 2 = 4
-- 0 0, 0 1, 1 0, 1 1. will be the combinations of group by on has_nfc and has_5g.

 

-- Group smartphones by brand and processor and get the count of models
-- And the average primary camera resolution (rear)
 
SELECT brand_name, processor_brand,
COUNT(*) AS 'num_phones',
ROUND(AVG(primary_camera_rear), 0) AS 'avg_cam_resolution'
FROM smartphones_campusx
GROUP BY brand_name, processor_brand
ORDER BY brand_name;
 

-- Find top 5 most costly phone brands
 
SELECT TOP(5)
brand_name,
AVG(price) AS 'avg_price'
FROM smartphones_campusx
GROUP BY brand_name
ORDER BY 'avg_price' DESC;
 

-- Which brand makes the smallest screen smartphones
 
SELECT TOP(1)
brand_name,
ROUND(AVG(screen_size), 0) AS 'avg_screen_size'
FROM smartphones_campusx
GROUP BY brand_name
ORDER BY 'avg_screen_size' ASC;
 

-- Group smartphones by the brand, and find the brand with the highest number of models
-- that have both NFC and an IR blaster
 
SELECT * 
FROM smartphones_campusx
WHERE has_nfc = 'True' AND has_ir_blaster = 'True';
 

SELECT brand_name, COUNT(*) AS 'count'
FROM smartphones_campusx
WHERE has_nfc = 'True' AND has_ir_blaster = 'True'
GROUP BY brand_name;
 

-- Find all Samsung 5G enables smartphones and find out the avg price for NFC and Non-NFC phones
 
SELECT has_nfc, AVG(price) AS 'avg_price'
FROM smartphones_campusx
WHERE brand_name = 'Samsung'
GROUP BY has_nfc;
 


HAVING CLAUSE
 
 
-- What WHERE does for SELECT the same thing HAVING does for Group BY to filter
 
 
-- Calculate average price of phones but the phone count of each brand must be above 40
 
SELECT brand_name,
COUNT(*) AS 'count',
AVG(price) AS 'avg_price'
FROM smartphones_campusx
GROUP BY brand_name
HAVING COUNT(*) > 40
ORDER BY 'avg_price' DESC;
 

-- Find the top 3 brands with the highest avg ram that have a refresh rate of at least 90 Hz and 
-- fast charging available and don't consider brands which have less than 10 phones
 
SELECT TOP(3)
brand_name,
ROUND(AVG(ram_capacity), 4) AS 'avg_ram'
FROM smartphones_campusx
WHERE refresh_rate >= 90 AND fast_charging_available = 1
GROUP BY brand_name
HAVING COUNT(*) > 10
ORDER BY 'avg_ram' DESC;
 

-- Find the avg price of all the phone brands with avg rating > 70 
-- and num_phones more 10 among all 5g enabled phones
 
SELECT brand_name,
AVG(price)  AS 'avg_price'
FROM smartphones_campusx
WHERE has_5g = 1
GROUP BY brand_name
HAVING AVG(rating) > 70 AND COUNT(*) > 10 ;
 

----------------------------------------------------------------------------------------------------------------------------------------------


CASE 
 
-- CASE WHEN STATEMENT
 
SELECT * FROM emp;
 

SELECT *, 
CASE
WHEN emp_age > 20 THEN 'Kids'
WHEN emp_age >= 20 and emp_age <= 40 THEN 'Adult'
ELSE 'Old'
END AS emp_age_bucket
FROM emp;
 

-- Now using CASE WHEN in join queries
 
SELECT * FROM emp;
SELECT * FROM dept;
 
 
 

-- We will give raise based on department on salary AS 20%, 15% & 25% 
 
SELECT emp.emp_name, emp.salary, dept.dep_name,
 
CASE
WHEN dep_name = 'Analytics' THEN salary + salary * 0.2
WHEN dep_name = 'IT' THEN salary + salary * 0.15
ELSE salary + salary * 0.25
END AS new_salary 
 
FROM emp 
INNER JOIN dept 
ON
emp.department_id = dept.dep_id;
 



----------------------------------------------------------------------


SUBQUERY

 

exec sp_rename 'movies_PQ', 'movies';
 
UPDATE MOVIES 
SET score = ROUND(score, 2);
 
 
 
SELECT * FROM movies;
 

-- Find the movie with highest rating with subquery
 
SELECT MAX(score) FROM movies;
 

SELECT * FROM movies
WHERE score = 9.3;
 

SELECT * FROM movies
WHERE score = (SELECT MAX(score) FROM movies);
 

 

-- INDEPENDENT SUBQUERY : Scalar Subquery
 
-- Find the movie with highest profit ( gross means revenue)
 
-- profit will be gross - budget
 
SELECT * FROM movies
WHERE (gross - budget) = (SELECT MAX(gross - budget) FROM movies);
 

-- Another way
 
SELECT TOP(1)
* FROM movies
ORDER BY (gross - budget) DESC;
 

----------------------------------------------------------------------





IMPORTANT CONCEPTS
 
BUSINESS INTELLIGENCE 
 
 
First watch the video of how to make a calendar table in SQL.
 
DATE FUNCTIONS
 
There are three popular date functions:
1. DATEPART
2. DATEADD
3. DATEDIFF
 
DATEPART
 

 


DATEADD
 
 


Again, you can add these options in DATEADD as well like in DATEPART.



DATEDIFF
 

Again, you can add these options in DATEADD as well like in DATEPART.

 
Examples:
 

----------------------------------------------------------------------




# TRICKY INTERVIEW QUESTIONS
 
1. Find duplicates in a table in SQL Server.
Ans.
USING GROUP BY:
SELECT 
Email, 
COUNT(*) AS CountOfDuplicates
FROM  Employees
GROUP BY Email
HAVING COUNT(*) > 1;
 
 
USING CTE
WITH DuplicateEmails AS (
SELECT *, 
COUNT(*) OVER (PARTITION BY Email) AS CountOfDuplicates
FROM Employees
)
SELECT * FFROM DuplicateEmails 
WHERE CountOfDuplicates > 1;


2. Delete duplicate records from a table.
Ans.
USING GROUP BY:
 
DELETE FROM Employees
WHERE EmployeeID IN (
SELECT EmployeeID 
FROM (
SELECT EmployeeID,
ROW_NUMBER() OVER(PARTITION BY Email ORDER BY EmployeeID) AS RowNum
FROM  Employees
) AS DuplicateRecords
WHERE RowNum > 1;
);
 
USING CTE
WITH DuplicateRecordsCTE AS (
SELECT EmployeeID, Email,
ROW_NUMBER() OVER(PARTITION BY Email ORDER BY EmployeeID) AS RowNum
FROM Employees
)
DELETE FROM DuplicateRecordsCTE 
WHERE RowNum > 1;
 
----------------------------------------------------------------------------------------------------------------------------------------------
 
 
 
 
 
 
 
3. Find 4th or Nth highest salary of an employee.
Ans.
USING OFFSET-FETCH to find 4th highest salary, OFFSET MEANS SKIP
SELECT DISTINCT Salary FROM Employees
OREDR BY Salary DESC
OFFSET 3 ROWS FETCH NEXT 1 ROW ONLY;
USING OFFSET-FETCH to find 3rd highest salary
SELECT DISTINCT Salary FROM Employees
OREDR BY Salary DESC
OFFSET 2 ROWS FETCH NEXT 1 ROW ONLY;
 
HIGHEST SALARY
SELECT TOP 1 Salary
FROM Employees
ORDER BY Salary DESC;
 
 
SELECT DISTINCT Salary FROM Employees
OREDR BY Salary DESC
OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY;
 
 
If we write offset 0 fetch next 2 rows:
Offset 0 means skip 0 rows and fetch 2 means get me 2 rows, i.e. it will not skip anything and will give you first and second highest salaries.
 
If we write offset 1 fetch next 2 rows:
Offset 1 means skip 1 row and fetch 2 means get me 2 rows, i.e. it will skip the first row which was the highest salary and will give you the next two rows after skipping, which are second and third highest rows.
 
 
 
 
USING ROW_NUMBER AND SUBQUERY
SELECT Salary 
FROM (
SELECT Salary,
ROW_NUMBER( )  OVER ( ORDER BY Salary DESC) AS RowNum
FROM Employees
) AS SalaryRanks
WHERE RowNum = 4;
 
----------------------------------------------------------------------------------------------------------------------------------------------
 
4. Copy a table in SQL Server.
Ans.
SELECT *
INTO New_Table
FROM ABC;
 
----------------------------------------------------------------------------------------------------------------------------------------------


