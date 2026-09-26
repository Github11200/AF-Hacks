-- Which tables reference a given patient id (in likely pid-bearing int columns)? Read-only.
DECLARE @pid int = 167, @sql nvarchar(max) = N'';
SELECT @sql += N'SELECT ''' + t.name + '.' + c.name + ''' AS col, COUNT(*) AS n FROM ' + QUOTENAME(t.name) + ' WHERE ' + QUOTENAME(c.name) + ' = @pid HAVING COUNT(*) > 0 UNION ALL '
FROM sys.columns c JOIN sys.tables t ON t.object_id = c.object_id JOIN sys.types ty ON ty.user_type_id = c.user_type_id
WHERE ty.name = 'int' AND (c.name LIKE '%pid%' OR c.name LIKE '%patient%id%' OR c.name LIKE 'apid' OR c.name LIKE '%chargeto%');
SET @sql = LEFT(@sql, LEN(@sql) - 10);
EXEC sp_executesql @sql, N'@pid int', @pid;
