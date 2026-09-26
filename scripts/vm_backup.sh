#!/usr/bin/env bash
# Full backup of ABELDent's DB inside the VM (run before any direct writes).
set -euo pipefail
cd "$(dirname "$0")"
ssh -o BatchMode=yes -o LogLevel=ERROR abelvm 'if not exist C:\AbelBackups mkdir C:\AbelBackups'
./vm_sql.sh "DECLARE @f nvarchar(260) = 'C:\AbelBackups\Abel_' + FORMAT(GETDATE(),'yyyyMMdd_HHmmss') + '.bak';
BACKUP DATABASE [Abel_FictionalCA_20260925_173324] TO DISK=@f WITH COPY_ONLY, INIT; SELECT @f AS backup_file"
