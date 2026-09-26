#!/usr/bin/env bash
# Run T-SQL against ABELDent's LocalDB via the guest q.ps1; prints JSON.
# Usage: scripts/vm_sql.sh [--write|--dry-run] [--params '{"pid":1}'] "SELECT ... @pid"   (- reads SQL from stdin)
set -euo pipefail
FLAGS=""; PARAMS=""
while [[ "${1:-}" == --* ]]; do
  case "$1" in
    --write) FLAGS+=" -AllowWrite" ;;
    --dry-run) FLAGS+=" -DryRun" ;;
    --params) PARAMS=" -ParamsB64 $(printf '%s' "$2" | base64 -w0)"; shift ;;
  esac; shift
done
SQL="$1"; [[ "$SQL" == - ]] && SQL="$(cat)"
B64=$(printf '%s' "$SQL" | base64 -w0)
ssh -o BatchMode=yes -o LogLevel=ERROR abelvm \
  "powershell -NoProfile -ExecutionPolicy Bypass -File C:\\afhacks\\q.ps1 -QueryB64 $B64$PARAMS$FLAGS"
