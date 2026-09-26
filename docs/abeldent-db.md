# ABELDent DB notes (v15.1, fictional sample DB)

- Engine: SQL Server LocalDB `(LOCALDB)\MSSQLLOCALDB`, DB name from `C:\ABELDent\localConfiguration.config` (currently `Abel_FictionalCA_20260925_173324`). Windows auth, named-pipe only (no TCP).
- Access: `scripts/vm_sync.sh` pushes `scripts/vm/guest/*.ps1` to `C:\afhacks`; `scripts/vm_sql.sh [--write] "SQL"` runs via SSH (`abelvm`). Read-only + always-rollback unless `--write`. Pattern ported from colombus `lab/vm/guest/q.ps1`.
- App API: `client/lib/abeldent` (typed functions) + `/api/abeldent/{providers,patients,patients/:id,appointments}`; POSTs accept `?dryRun=1` (runs, then rolls back). Tests: `cd client && pnpm test`; HTTP smoke: `scripts/api_smoke.sh`.
- Backup before writes: `scripts/vm_backup.sh` → `C:\AbelBackups\*.bak`.
- No FKs, no sequences; integrity is enforced in ABELDent's .NET DAL (`AddPatientCommand`, `SchedulingMgr.AddAppointmentAsync`). Direct writes must validate themselves.
- Every table has a `<table>_ThrowErrorIfPrimaryKeyUpdated` trigger: never UPDATE a PK.

## Core tables
| Table | Meaning | Key | Notes |
|---|---|---|---|
| `pat` | patients | `pid` int (not identity) | Deleted patients leave child rows (apt, apn, aptdel, AppointmentLog, cnt, rcl), so next pid = 1 + max over all of them (see `client/lib/abeldent/sql.ts`). Names upper-case. |
| `inf` | patient contact prefs | `infpid` = `pat.pid` | always 1:1 with `pat`; create together |
| `apt` | appointments | (`adate`,`achair`,`atime`) | `apid`=pid, `adid`=`dnt.did`, `achair` `'1 '..'4 '`, `atime` time-of-day on 1899-12-30, 10-min grid (`sys.sunitmins`), `atimereq` in units, `aidentifier` GUID |
| `aps` | appt statuses | `apsid` | ' ' Unconfirmed, P Preconfirmed, Y Confirmed, A Arrived, S Seated, W Waiting, B Billed, D Departed |
| `apn` | appt notes | pid,date,col,time,type,line | |
| `dnt` | providers | `did` | |
| `AppointmentLog` | appt audit | | app-written, no trigger → raw inserts won't populate it |

Unused here (0 rows): `Patient`, `PatientAccount`, `PatientIdToGuidMapping`. `ClinicalPatient` is created lazily (`LegacyPID` = zero-padded pid).

## Open questions
- Confirm ABELDent's own pid allocator matches ours (create one in the GUI, diff).
- `AppointmentLog.ChangeType` codes.

## Verified
- Direct insert of `pat` + `inf` (test patient ZZTEST/CLAUDE, pid 168) shows in Patient Search and opens cleanly in ABELDent.
- Direct insert of `apt` (pid 168, 2026-09-28 chair 2 10:30, 3 units, provider T) renders in the Scheduler. Scheduler columns = `achair`, each labelled with a default provider (1 T, 2 M, 3 K, 4 D); the booking shows a red edge marker, likely provider/column mismatch (unconfirmed).
