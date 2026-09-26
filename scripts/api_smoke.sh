#!/usr/bin/env bash
# Smoke-test the ABELDent API over HTTP against a running `next dev` (default :3000). Read-only + dryRun.
B="${1:-http://localhost:3000}/api/abeldent"
req() { printf '%-58s ' "$1 $2"; curl -s -o /tmp/claude-api.out -w '%{http_code} ' -X "$1" -H 'content-type: application/json' ${3:+-d "$3"} "$B$2"; head -c 150 /tmp/claude-api.out; echo; }
req GET /providers
req GET "/patients?q=ZZTEST"
req GET /patients/168
req GET /patients/99999
req GET "/appointments?date=2026-09-28"
req POST "/appointments?dryRun=1" '{"patientId":168,"date":"2026-09-28","start":"10:40","durationMinutes":30,"chair":"2","providerId":"T"}'
req POST "/appointments?dryRun=1" '{"patientId":168,"date":"2026-09-28","start":"11:05","durationMinutes":30,"chair":"2","providerId":"T"}'
req POST "/patients?dryRun=1" '{"lastName":"Zzdry","firstName":"Run","birthDate":"2000-02-02","gender":"M","dentistId":"NOPE"}'
