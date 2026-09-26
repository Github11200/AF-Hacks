# Expects $Sql. Runs it on ABELDent's DB as the Windows user; emits JSON.
$conn = New-Object System.Data.SqlClient.SqlConnection 'Data Source=(LOCALDB)\MSSQLLOCALDB;Initial Catalog=Abel_FictionalCA_20260925_173324;Integrated Security=True'
$conn.Open()
$cmd = $conn.CreateCommand(); $cmd.CommandText = $Sql
$da = New-Object System.Data.SqlClient.SqlDataAdapter $cmd
$ds = New-Object System.Data.DataSet
$affected = $da.Fill($ds)
$conn.Close()
if ($ds.Tables.Count -eq 0) { @{ rowsAffected = $affected } | ConvertTo-Json -Compress; return }
$cols = $ds.Tables[0].Columns | ForEach-Object ColumnName
$rows = @($ds.Tables[0].Rows | ForEach-Object { $r = $_; $o = [ordered]@{}; foreach ($c in $cols) { $v = $r[$c]; $o[$c] = if ($v -is [DBNull]) { $null } elseif ($v -is [datetime]) { $v.ToString("s") } else { $v } }; [pscustomobject]$o })
ConvertTo-Json -InputObject $rows -Depth 3 -Compress
