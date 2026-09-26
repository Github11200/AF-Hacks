# Locate ABELDent's LocalDB instance, database files and connection config (secrets masked).
"== LocalDB instances"
& sqllocaldb info | ForEach-Object { $_; & sqllocaldb info $_ }
"== DB files"
Get-ChildItem C:\ABELDent, $env:LOCALAPPDATA\Microsoft\Microsoft*SQL*Server*Local*DB, C:\ProgramData -Recurse -Include *.mdf, *.ldf -ErrorAction SilentlyContinue |
  Select-Object FullName, @{n='MB';e={[int]($_.Length/1MB)}} | Format-Table -AutoSize | Out-String -Width 250
"== C:\ABELDent top level"
Get-ChildItem C:\ABELDent | Select-Object Mode, Name | Format-Table -AutoSize | Out-String -Width 200
"== Connection config (passwords masked)"
Get-ChildItem C:\ABELDent -Recurse -Include *.config, *.ini, *.xml, *.json -ErrorAction SilentlyContinue |
  Select-String -Pattern 'Data Source|Server=|Initial Catalog|Database=|localdb|connectionString' |
  ForEach-Object { "{0}:{1}: {2}" -f $_.Path, $_.LineNumber, ($_.Line.Trim() -replace '(?i)(password|pwd)\s*=\s*[^;"]*', '$1=***') } | Select-Object -First 40
