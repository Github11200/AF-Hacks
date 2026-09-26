#!/usr/bin/env bash
# Run a PowerShell script inside the WinApps VM; its stdout lands in .vm-tmp/<name>.out
# Usage: scripts/vm_exec.sh scripts/vm/foo.ps1 [timeout_s]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PS1="$(realpath "$1")"; TIMEOUT="${2:-90}"
NAME="$(basename "$PS1" .ps1)"
TMP="$ROOT/.vm-tmp"; mkdir -p "$TMP"
OUT="$TMP/$NAME.out"; DONE="$TMP/$NAME.done"; rm -f "$OUT" "$DONE"

# \\tsclient\home maps to $HOME via +home-drive
win() { echo "\\\\tsclient\\home\\${1#$HOME/}" | tr '/' '\\'; }
BAT="$TMP/$NAME.bat"
printf 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%s" > "%s" 2>&1\r\ntype NUL > "%s"\r\ntsdiscon\r\n' \
  "$(win "$PS1")" "$(win "$OUT")" "$(win "$DONE")" > "$BAT"

# Credentials come from WinApps config; password is piped, never on argv
source <(grep -E '^RDP_(USER|PASS)=' ~/.config/winapps/winapps.conf)
{ printf '%s\n' /cert:tofu "/u:$RDP_USER" "/p:$RDP_PASS" /v:127.0.0.1:3389 +home-drive \
    "/app:program:C:\\Windows\\System32\\cmd.exe,cmd:/C $(win "$BAT")"; } \
  | xfreerdp3 /args-from:stdin &> "$TMP/$NAME.rdp.log" &
PID=$!
for ((i=0; i<TIMEOUT; i++)); do [[ -f "$DONE" ]] && break; kill -0 $PID 2>/dev/null || break; sleep 1; done
kill $PID 2>/dev/null || true
[[ -f "$DONE" ]] || { echo "timed out / failed; see $TMP/$NAME.rdp.log" >&2; tail -5 "$TMP/$NAME.rdp.log" >&2; exit 1; }
cat "$OUT"
