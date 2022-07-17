--2
-- Connection 1
/* Leave the above line to easily see that this query window
belongs to Connection 1. */
CREATE DATABASE TestDB;
GO
ALTER DATABASE TestDB SET READ_COMMITTED_SNAPSHOT ON;
GO
USE TestDB;
GO
CREATE SCHEMA Test;
GO
CREATE TABLE Test.TestTable (
Col1 INT NOT NULL
,Col2 INT NOT NULL
);
INSERT Test.TestTable (Col1, Col2) VALUES (1,10);
INSERT Test.TestTable (Col1, Col2) VALUES (2,20);
INSERT Test.TestTable (Col1, Col2) VALUES (3,30);
INSERT Test.TestTable (Col1, Col2) VALUES (4,40);
INSERT Test.TestTable (Col1, Col2) VALUES (5,50);
INSERT Test.TestTable (Col1, Col2) VALUES (6,60);
--3
--Connection 2
>/* Leave the above line to easily see that this query window
belongs to Connection 2. */
USE TestDB;
--4
--Connection 3
/* Leave the above line to easily see that this query window
belongs to Connection 3. */
USE TestDB;
--5
-- Connection 2
BEGIN TRAN;
UPDATE Test.TestTable SET Col2 = Col2 + 1
WHERE Col1 = 1;
--6
-- Connection 1
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRAN;
SELECT * FROM Test.TestTable
WHERE Col1 = 1;
--7
SELECT
resource_type
,request_mode
,request_status
FROM sys.dm_tran_locks
WHERE resource_database_id = DB_ID('TestDB')
AND request_mode IN ('S', 'X')
AND resource_type <> 'DATABASE';
--8
SELECT * FROM sys.dm_tran_version_store
WHERE database_id = DB_ID('TestDB');
--9
--Connection 2
COMMIT TRAN;
--10
SELECT * FROM Test.TestTable
WHERE Col1 = 1;
--11
USE master;
DROP DATABASE TestDB;