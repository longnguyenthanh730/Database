SELECT *INTO dbo.DimAccount_NoIndex FROM dbo.DimAccount
SELECT *INTO dbo.DimAccount_Clustered_Index FROM dbo.DimAccount
SELECT *INTO dbo.DimAccount_NonClustered_Index FROM dbo.DimAccount

CREATE INDEX Idx_DimAccount_Index_AccountKey ON dbo.DimAccount_NonClustered_Index(AccountKey)
CREATE CLUSTERED INDEX Idx_DimAccount_Index_AccountKey ON dbo.DimAccount_Clustered_Index(AccountKey)

SELECT * FROM dbo.DimAccount_NoIndex where AccountKey = 47
SELECT * FROM dbo.DimAccount_NonClustered_Index where AccountKey = 47
SELECT * FROM dbo.DimAccount_Clustered_Index where AccountKey = 47


