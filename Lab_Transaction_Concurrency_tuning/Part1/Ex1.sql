-- Exce
--1
--2
SELECT @@SPID;
GO
CREATE DATABASE TestDB;
GO
USE TestDB;
GO CREATE SCHEMA Test;
GO
CREATE TABLE Test.TestTable (
       Col1 INT NOT NULL,
	   Col2 INT NOT NULL );
INSERT Test.TestTable (Col1, Col2) VALUES (1, 10);
INSERT Test.TestTable (Col1, Col2) VALUES (2, 20);
INSERT Test.TestTable (Col1, Col2) VALUES (3, 30);
INSERT Test.TestTable (Col1, Col2) VALUES (4, 40);
INSERT Test.TestTable (Col1, Col2) VALUES (5, 50);
INSERT Test.TestTable (Col1, Col2) VALUES (6, 60);
--3
SELECT @@SPID;
GO
USE TestDB;
--4
USE TestDB;
--5
-- Connection 1
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRAN;
    SELECT * FROM Test.TestTable 
	WHERE Col1 =1;
--6
SELECT
resource_type
,request_mode
,request_status
FROM sys.dm_tran_locks
WHERE resource_database_id = DB_ID('TestDB')
AND request_session_id = 58
AND request_mode IN ('S', 'X')
AND resource_type <> 'DATABASE';
--7
---Connection 1
COMMIT TRAN;
--8
-- Connection 2
BEGIN TRAN;
UPDATE Test.TestTable SET Col2 = Col2 + 1
WHERE Col1 = 1;
--9
-- Connection 1
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRAN;SELECT * FROM Test.TestTable
WHERE Col1 = 1;
-- This SELECT statement will be blocked!
--10
SELECT
resource_type
,request_mode
,request_status
FROM sys.dm_tran_locks
WHERE resource_database_id = DB_ID('TestDB')
AND request_session_id = 58
AND request_mode IN ('S', 'X')
AND resource_type <> 'DATABASE';
--11
--Connection 2
COMMIT TRAN;
--12
SELECT
resource_type
,request_mode
,request_status
FROM sys.dm_tran_locks
WHERE resource_database_id = DB_ID('TestDB')
AND request_session_id = 58
AND request_mode IN ('S', 'X')
AND resource_type <> 'DATABASE';
--13
USE master; 
DROP DATABASE TestDB;