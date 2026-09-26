# Locate ABELDent install and its database engine (no data read).
"== Installed programs"
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue |
  Where-Object { $_.DisplayName -match 'ABEL|SQL|Sybase|Postgre|Firebird|Pervasive|Actian|Btrieve' } |
  Select-Object DisplayName, DisplayVersion, InstallLocation | Format-Table -AutoSize | Out-String -Width 250
"== Services"
Get-CimInstance Win32_Service | Where-Object { $_.Name -match 'ABEL|SQL|MSSQL|Sybase|postgres|Firebird|Pervasive|psql' -or $_.PathName -match 'ABEL' } |
  Select-Object Name, State, StartMode, PathName | Format-Table -AutoSize | Out-String -Width 300
"== Listening TCP"
Get-NetTCPConnection -State Listen | ForEach-Object { "{0}:{1}  {2}" -f $_.LocalAddress, $_.LocalPort, (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName } | Sort-Object -Unique
"== ABEL dirs"
Get-ChildItem 'C:\', 'C:\Program Files', 'C:\Program Files (x86)', 'C:\ProgramData' -Directory -ErrorAction SilentlyContinue | Where-Object Name -match 'ABEL' | ForEach-Object FullName
