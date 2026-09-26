#!/usr/bin/env bash
# Push guest-side scripts (scripts/vm/guest/*.ps1) into C:\afhacks on the VM.
set -euo pipefail
cd "$(dirname "$0")/vm/guest"
ssh -o BatchMode=yes -o LogLevel=ERROR abelvm 'if not exist C:\afhacks mkdir C:\afhacks'
scp -q -o BatchMode=yes -o LogLevel=ERROR ./*.ps1 abelvm:C:/afhacks/
