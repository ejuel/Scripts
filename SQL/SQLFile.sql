-- C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\SqlWorkbenchProjectItems\Sql\SQLFile.sql

DECLARE @MinRows int = 0
DECLARE @MaxRows int = 0
DECLARE @RowsImpacted int = 0

declare @TableName nvarchar(100) = ''
declare @ColumnName nvarchar(100) = ''

if(@MaxRows > 0 AND @MinRows <= @MaxRows)
BEGIN
	BEGIN tran
--Insert custom SQL here:


--End of custom SQL
SET @RowsImpacted += @@ROWCOUNT --Note: If running multiple queries, add this line between each one

	IF(@RowsImpacted >= @MinRows AND @RowsImpacted <= @MaxRows)
		BEGIN 
			COMMIT Tran
			PRINT '### Committed transaction (Total rows: '+cast(@RowsImpacted as varchar(20))+') ###'
		END
	ELSE
		BEGIN
			rollback tran
			PRINT '### Rolled back transaction (expected '+
			CASE WHEN @MinRows = @MaxRows THEN cast(@MinRows as varchar(20))
			ELSE cast(@MinRows as varchar(20)) + '-'+cast(@MaxRows as varchar(20))
			END
			+' but query(s) impacted '
			+cast(@RowsImpacted as varchar(20))+' rows) ###'
		END
END
ELSE
BEGIN

SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) as [Row]
, * 

FROM (

	SELECT      'Table' AS [Area], s.name + '.' + t.name AS [TableOrViewName],
				c.name  AS [ColumnName]
            
	FROM        sys.columns c
	JOIN        sys.tables  t   ON c.object_id = t.object_id
	  INNER JOIN sys.schemas s
	  ON s.schema_id = t.schema_id
	WHERE       (t.name LIKE '%' + @TableName + '%' OR @TableName = '')
	  AND (c.name LIKE '%' + @ColumnName + '%' OR @ColumnName = '')
	UNION ALL
	SELECT 'View' AS [Area], [ViewName] = s.name + '.' + v.name, c.name as [ColumnName]
	  FROM sys.views AS v
	  INNER JOIN sys.schemas AS s
	  ON v.schema_id = s.schema_id
	  JOIN sys.columns c on c.object_id = v.object_id
	  WHERE (v.name LIKE '%' + @TableName + '%' OR @TableName = '')
	  AND (c.name LIKE '%' + @ColumnName + '%' OR @ColumnName = '')
) as a
  
ORDER BY    TableOrViewName, ColumnName
END