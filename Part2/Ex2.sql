--1
--2
CREATE DATABASE TestDB;
GO
USE TestDB;
GO
CREATE SCHEMA Test;
GO
CREATE TABLE Test.Accounts (
AccountNumber INT PRIMARY KEY);
CREATE TABLE Test.AccountTransactions (
TransactionID INT IDENTITY PRIMARY KEY
,AccountNumber INT NOT NULL REFERENCES Test.Accounts
,CreatedDateTime DATETIME NOT NULL DEFAULT
CURRENT_TIMESTAMP
,Amount DECIMAL(19, 5) NOT NULL
);
GO
CREATE PROC Test.spAccountReset
AS
BEGIN
SET NOCOUNT ON;
DELETE Test.AccountTransactions;
DELETE Test.Accounts;
INSERT Test.Accounts (AccountNumber) VALUES (1001);
INSERT Test.AccountTransactions (AccountNumber, Amount)
VALUES (1001, 100);
INSERT Test.AccountTransactions (AccountNumber, Amount)
VALUES (1001, 500);
INSERT Test.AccountTransactions (AccountNumber, Amount)
VALUES (1001, 1400);
SELECT AccountNumber, SUM(Amount) AS Balance
FROM Test.AccountTransactions
GROUP BY AccountNumber;
END
--3
USE TestDB;
GO
CREATE PROC Test.spAccountWithdraw
@AccountNumber INT
,@AmountToWithdraw DECIMAL(19, 5)
AS
BEGIN
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRY
IF(@AmountToWithdraw <= 0)
RAISERROR('@AmountToWithdraw must be > 0.', 16, 1);
BEGIN TRAN;
-- Verify that the account exists...
IF NOT EXISTS(
SELECT *
FROM Test.Accounts
WHERE AccountNumber = @AccountNumber
)
RAISERROR('Account not found.', 16, 1);
-- Verify that the account will not be overdrawn...
IF (@AmountToWithdraw > (
SELECT SUM(Amount)
FROM Test.AccountTransactions
WITH(SERIALIZABLE)
WHERE AccountNumber = @AccountNumber)
)
RAISERROR('Not enough funds in account.',
16, 1);
-- ** USED TO TEST CONCURRENCY PROBLEMS **
RAISERROR('Pausing procedure for 10 seconds...',
10, 1)
WITH NOWAIT;
WAITFOR DELAY '00:00:30';RAISERROR('Procedure continues...', 10, 1) WITH
NOWAIT;
-- Make the withdrawal...
INSERT Test.AccountTransactions (AccountNumber,Amount)
VALUES (@AccountNumber, -@AmountToWithdraw);
-- Return the new balance of the account:
SELECT SUM(Amount) AS BalanceAfterWithdrawal
FROM Test.AccountTransactions
WHERE AccountNumber = @AccountNumber;
COMMIT TRAN;
END TRY
BEGIN CATCH
DECLARE @ErrorMessage NVARCHAR(2047);
SET @ErrorMessage = ERROR_MESSAGE();
RAISERROR(@ErrorMessage, 16, 1);
-- Should also use ERROR_SEVERITY() andERROR_STATE()...
IF(XACT_STATE() <> 0)
ROLLBACK TRAN;
END CATCH
END
--4
--Connection 1
/* Leave the above line to easily see that this query window
belongs to Connection 1. */
USE TestDB;
GO
--Reset/generate the account data
EXEC Test.spAccountReset;
--5
--Connection 2
/* Leave the above line to easily see that this query window
belongs to Connection 2. */
USE TestDB;
GO
--6
SELECT SUM(Amount) AS BalanceBeforeWithdrawal
FROM Test.AccountTransactions
WHERE AccountNumber = 1001;
GO
EXEC Test.spAccountWithdraw @AccountNumber = 1001,
@AmountToWithdraw = 2000;
--7
USE master;
GO
DROP DATABASE TestDB