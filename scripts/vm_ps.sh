#!/usr/bin/env bash
# Run a local PowerShell script inside the ABELDent VM over SSH. Usage: scripts/vm_ps.sh file.ps1
set -euo pipefail
# EncodedCommand keeps multi-line pipelines intact (stdin mode runs line by line)
ENC=$( { echo "\$ProgressPreference='SilentlyContinue'"; cat "$1"; } | iconv -f UTF-8 -t UTF-16LE | base64 -w0)
# sshd intermittently refuses exec under concurrent load (exit 255); retry briefly
for try in 1 2 3; do
  rc=0; ssh -o BatchMode=yes -o LogLevel=ERROR abelvm "powershell -NoProfile -ExecutionPolicy Bypass -EncodedCommand $ENC" || rc=$?
  [[ $rc -ne 255 ]] && exit $rc; sleep $try
done
exit 255
