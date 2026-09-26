# Read-only: extract ASCII/UTF16 printable strings from ABELDent DAL DLLs matching
# patterns relevant to patient/appointment insertion, filtered to keep output small.
$dlls = @(
  'C:\ABELDent\ABELSoft.Dental.PatientDAL.dll',
  'C:\ABELDent\ABELSoft.Dental.PatientBLL.dll',
  'C:\ABELDent\ABELSoft.Dental.SchedulingDAL.dll',
  'C:\ABELDent\ABELSoft.Dental.SchedulingBLL.dll',
  'C:\ABELDent\ABELSoft.Dental.Core.DAL.dll',
  'C:\ABELDent\ABELDentWin32.dll',
  'C:\ABELDent\ABELDentWin32Sched.dll'
)
$patterns = 'INSERT INTO\s+\[?pat\]?|INSERT INTO\s+\[?apt\]?|INSERT INTO\s+\[?inf\]?|INSERT INTO\s+\[?Patient\]?|NextPatient|NextPid|NewPatientId|GetNewPatientId|GetNextPatientId|MaxPatientId|pat_pid|PatientIdToGuidMapping|AppointmentLog|NewAppointmentId|InsertPatient|InsertAppointment|CreatePatient|CreateAppointment|AddPatient|AddAppointment'

function Get-Strings {
  param($Path, $MinLen = 6)
  if (-not (Test-Path $Path)) { "MISSING: $Path"; return }
  $bytes = [IO.File]::ReadAllBytes($Path)
  # ASCII strings
  $asciiRegex = [regex]"[\x20-\x7E]{$MinLen,}"
  $ascii = [Text.Encoding]::ASCII.GetString($bytes)
  $asciiRegex.Matches($ascii) | ForEach-Object { $_.Value }
  # UTF-16LE strings (common in .NET metadata / literals)
  $utf16 = [Text.Encoding]::Unicode.GetString($bytes)
  $asciiRegex.Matches($utf16) | ForEach-Object { $_.Value }
}

foreach ($dll in $dlls) {
  "=== $dll ==="
  if (-not (Test-Path $dll)) { "MISSING"; continue }
  Get-Strings -Path $dll | Where-Object { $_ -match $patterns } | Sort-Object -Unique | Select-Object -First 60
}
