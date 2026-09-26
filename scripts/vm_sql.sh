#!/usr/bin/env bash
# Run T-SQL against ABELDent's LocalDB, print JSON rows. Usage: scripts/vm_sql.sh "SELECT ..."  (or - for stdin)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
SQL="$1"; [[ "$SQL" == - ]] && SQL="$(cat)"
# Base64 the SQL so no quoting survives the ssh/powershell hops
B64=$(printf '%s' "$SQL" | base64 -w0)
TMP=$(mktemp --suffix=.ps1); trap 'rm -f "$TMP"' EXIT
{ echo "\$Sql = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$B64'))"; cat "$ROOT/vm/sql.ps1"; } > "$TMP"
"$ROOT/vm_ps.sh" "$TMP"
