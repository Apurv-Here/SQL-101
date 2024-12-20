"""
list with definitions and examples for your notes:

1. DDL: Data Definition Language

Definition: Commands used to define and manage database structures.

Examples: CREATE, ALTER, DROP




2. DML: Data Manipulation Language

Definition: Commands used to manipulate data stored in database objects.

Examples: INSERT, UPDATE, DELETE




3. DCL: Data Control Language

Definition: Commands used to manage access permissions to the database.

Examples: GRANT, REVOKE




4. TCL: Transaction Control Language

Definition: Commands used to manage transactions in the database.

Examples: BEGIN TRANSACTION, COMMIT, ROLLBACK




5. DQL: Data Query Language

Definition: Commands used specifically for querying the database.

Examples: SELECT


----------------------------------------------------------------------------------------

Data Definition Language (DDL)

CREATE: Creates a new table, view, or other database objects.

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    DateOfBirth DATE
);


ALTER: Modifies an existing database object.

ALTER TABLE Employees
ADD Email VARCHAR(100);
DROP: Deletes a database object.


DROP TABLE Employees;




Data Manipulation Language (DML)

DML commands are used to manipulate data stored in database objects.


INSERT: Adds new records to a table.

INSERT INTO Employees (EmployeeID, FirstName, LastName, DateOfBirth)
VALUES (1, 'John', 'Doe', '1990-01-01');
UPDATE: Modifies existing records in a table.


UPDATE Employees
SET Email = 'john.doe@example.com'
WHERE EmployeeID = 1;


DELETE: Removes existing records from a table.

DELETE FROM Employees
WHERE EmployeeID = 1;



Data Control Language (DCL)

DCL commands manage access permissions to the database.

GRANT: Gives privileges to users.

GRANT SELECT, INSERT ON Employees TO UserA;


REVOKE: Removes privileges from users.

REVOKE SELECT, INSERT ON Employees FROM UserA;



Transaction Control Language (TCL)

TCL commands manage transactions in the database.

BEGIN TRANSACTION: Starts a transaction.

BEGIN TRANSACTION;


COMMIT: Saves the changes made in the transaction.

COMMIT;


ROLLBACK: Reverts the changes made in the transaction.

ROLLBACK;



Data Query Language (DQL)

DQL commands are used for querying the database.

SELECT: Retrieves data from the database (often considered part of DML, but specifically used for querying).

SELECT FirstName, LastName FROM Employees WHERE EmployeeID = 1;



----------------------------------------------------------------------------------------












"""


