-- Create Table
SELECT *INTO Sales.Customer_NoIndex FROM Sales.Customer
SELECT *INTO Sales.Customer_Clustered_Index FROM Sales.Customer
SELECT *INTO Sales.Customer_NonClustered_Index FROM Sales.Customer

-- Create Index
CREATE INDEX Idx_Customer_Index_CustomerID 
ON Sales.Customer_NonClustered_Index(CustomerID)
CREATE CLUSTERED INDEX Idx_Customer_Index_CustomerID 
ON Sales.Customer_Clustered_Index(CustomerID)

-- Test Query
SELECT * FROM Sales.Customer_NoIndex where CustomerID = 50
SELECT * FROM Sales.Customer_NonClustered_Index where CustomerID = 50
SELECT * FROM Sales.Customer_Clustered_Index where CustomerID = 50
