"""

-------------------------------------------------------------------------

SELECT TOP 10 
CustomerID, SUM(OrderAmount) AS TotalOrderAmount
FROM Sales
WHERE YEAR(OrderDate) = 2023
GROUP BY CustomerID
HAVING SUM(OrderAmount) > 1000
ORDER BY TotalOrderAmount DESC;


-------------------------------------------------------------------------


The order of execution for a query is different from the written order. 
Here’s the logical order of execution:

1. FROM: Specifies the tables involved in the query and performs joins.

2. WHERE: Filters rows based on specified conditions.

3. GROUP BY: Groups rows based on specified columns.

4. HAVING: Filters groups based on specified conditions.

5. SELECT: Selects the columns to be returned in the result set.

6. ORDER BY: Sorts the result set based on specified columns.

7. TOP: Limits the number of rows returned in the result set.


-------------------------------------------------------------------------



SELECT 
    CustomerID, 
    SUM(OrderAmount) AS TotalOrderAmount,
    CASE 
        WHEN SUM(OrderAmount) > 2000 THEN 'High Spender'
        WHEN SUM(OrderAmount) BETWEEN 1000 AND 2000 THEN 'Medium Spender'
        ELSE 'Low Spender'
    END AS SpendingCategory
FROM Sales
WHERE YEAR(OrderDate) = 2023
GROUP BY CustomerID
HAVING SUM(OrderAmount) > 1000;


-------------------------------------------------------------------------



-- Select statement with CASE WHEN clause to categorize salaries
SELECT 
    EmployeeID, 
    FirstName, 
    LastName, 
    Salary,
    CASE 
        WHEN Salary < 30000 THEN 'Low Salary'
        WHEN Salary BETWEEN 30000 AND 60000 THEN 'Medium Salary'
        ELSE 'High Salary'
    END AS SalaryCategory
FROM Employees;


-------------------------------------------------------------------------

    

-- Select statement with WHERE, GROUP BY, HAVING, and SUM(CASE WHEN) clauses

SELECT 
    CustomerID, 
    SUM(OrderAmount) AS TotalOrderAmount,
    SUM(CASE 
        WHEN OrderAmount > 2000 THEN OrderAmount 
        ELSE 0 
    END) AS HighSpenderTotal,
    SUM(CASE 
        WHEN OrderAmount BETWEEN 1000 AND 2000 THEN OrderAmount 
        ELSE 0 
    END) AS MediumSpenderTotal,
    SUM(CASE 
        WHEN OrderAmount < 1000 THEN OrderAmount 
        ELSE 0 
    END) AS LowSpenderTotal
FROM Sales
WHERE YEAR(OrderDate) = 2023
GROUP BY CustomerID
HAVING SUM(OrderAmount) > 1000;


-------------------------------------------------------------------------


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



-------------------------------------------------------------------------


-- Create a clustered index on the EmployeeID column
CREATE CLUSTERED INDEX IX_Employees_EmployeeID
ON Employees (EmployeeID);



-- Create a non-clustered index on the LastName column
CREATE NONCLUSTERED INDEX IX_Employees_LastName
ON Employees (LastName);



-------------------------------------------------------------------------



-- Create a simple view example

CREATE VIEW EmployeeSummary AS
SELECT 
    EmployeeID, 
    FirstName + ' ' + LastName AS FullName, 
    Department
FROM Employees;


-------------------------------------------------------------------------


-- Create a temporary table example
CREATE TABLE #TempEmployees (
    EmployeeID INT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Department VARCHAR(50),
    Salary DECIMAL(10, 2)
);

-- Insert some sample data into the temporary table
INSERT INTO #TempEmployees (EmployeeID, FirstName, LastName, Department, Salary)
VALUES
(1, 'John', 'Doe', 'HR', 50000.00),
(2, 'Jane', 'Smith', 'IT', 60000.00),
(3, 'Mike', 'Johnson', 'Finance', 55000.00);

-- Select data from the temporary table
SELECT * FROM #TempEmployees;

-- Drop the temporary table when done
DROP TABLE #TempEmployees;



-- Create a global temporary table example
CREATE TABLE ##GlobalTempEmployees (
    EmployeeID INT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Department VARCHAR(50),
    Salary DECIMAL(10, 2)
);

-- Insert some sample data into the global temporary table
INSERT INTO ##GlobalTempEmployees (EmployeeID, FirstName, LastName, Department, Salary)
VALUES
(1, 'John', 'Doe', 'HR', 50000.00),
(2, 'Jane', 'Smith', 'IT', 60000.00),
(3, 'Mike', 'Johnson', 'Finance', 55000.00);



-------------------------------------------------------------------------

-- TRIGGER Example

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Department VARCHAR(50),
    Salary DECIMAL(10, 2)
);


CREATE TABLE Employees_Log (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Department VARCHAR(50),
    Salary DECIMAL(10, 2),
    ActionTime DATETIME DEFAULT GETDATE()
);


-- Create an AFTER INSERT trigger
CREATE TRIGGER trg_AfterInsert_Employees
ON Employees
AFTER INSERT
AS
BEGIN
    INSERT INTO Employees_Log (EmployeeID, FirstName, LastName, Department, Salary)
    SELECT EmployeeID, FirstName, LastName, Department, Salary
    FROM inserted;
END;


-------------------------------------------------------------------------




















"""