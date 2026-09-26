#!/usr/bin/env bash
# Run a local PowerShell script inside the ABELDent VM (copied to C:\afhacks\_cmd.ps1, run with -File).
set -euo pipefail
scp -q -o BatchMode=yes -o LogLevel=ERROR "$1" abelvm:C:/afhacks/_cmd.ps1
ssh -o BatchMode=yes -o LogLevel=ERROR abelvm "powershell -NoProfile -ExecutionPolicy Bypass -File C:\\afhacks\\_cmd.ps1"
