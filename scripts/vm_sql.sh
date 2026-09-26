#!/usr/bin/env bash
# Run T-SQL against ABELDent's LocalDB via the guest q.ps1; prints JSON.
# Usage: scripts/vm_sql.sh [--write] "SELECT ..."   (use - to read SQL from stdin)
set -euo pipefail
WRITE=""; [[ "${1:-}" == --write ]] && { WRITE="-AllowWrite"; shift; }
SQL="$1"; [[ "$SQL" == - ]] && SQL="$(cat)"
B64=$(printf '%s' "$SQL" | base64 -w0)
ssh -o BatchMode=yes -o LogLevel=ERROR abelvm \
  "powershell -NoProfile -ExecutionPolicy Bypass -File C:\\afhacks\\q.ps1 -QueryB64 $B64 $WRITE"
