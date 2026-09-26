// T-SQL against ABELDent's legacy schema. See docs/abeldent-db.md for table semantics.
// Values always bind as @params; validation failures THROW 'VALIDATION: ...' (see db.ts).

export const LIST_PROVIDERS = `
SELECT RTRIM(did) AS id, dname AS name FROM dnt
WHERE dinactive = 0 AND RTRIM(did) NOT IN ('', '$', '?') ORDER BY did`;

const PATIENT_COLUMNS = `
  p.pid AS id, p.plname AS lastName, p.pfname AS firstName, p.pbirth AS birthDate, p.pgender AS gender,
  NULLIF(RTRIM(p.pphone), '') AS phone, NULLIF(RTRIM(i.infmobile), '') AS mobile, NULLIF(i.infemail, '') AS email,
  RTRIM(p.pdentist) AS dentistId, p.pinactive AS inactive`;

export const SEARCH_PATIENTS = `
SELECT TOP 50 ${PATIENT_COLUMNS}
FROM pat p LEFT JOIN inf i ON i.infpid = p.pid
WHERE p.pnonpatient = 0 AND (@q = '' OR p.plname LIKE @q + '%' OR p.pfname LIKE @q + '%' OR p.pphone LIKE '%' + @q + '%')
ORDER BY p.plname, p.pfname`;

export const GET_PATIENT = `
SELECT ${PATIENT_COLUMNS} FROM pat p LEFT JOIN inf i ON i.infpid = p.pid WHERE p.pid = @pid`;

// Deleted patients leave rows in child tables, so the next id must clear every pid-bearing table.
// pat + inf are always created together (1:1), mirroring ABELDent-created rows.
export const CREATE_PATIENT = `
SET XACT_ABORT ON;
BEGIN TRAN;
IF NOT EXISTS (SELECT 1 FROM dnt WHERE RTRIM(did) = @dentistId) THROW 50002, 'VALIDATION: Unknown dentist', 1;
DECLARE @pid int = 1 + (SELECT MAX(id) FROM (
  SELECT MAX(pid) id FROM pat WITH (UPDLOCK, HOLDLOCK) UNION ALL SELECT MAX(infpid) FROM inf
  UNION ALL SELECT MAX(apid) FROM apt UNION ALL SELECT MAX(apid) FROM aptdel UNION ALL SELECT MAX(apnpid) FROM apn
  UNION ALL SELECT MAX(cpid) FROM cnt UNION ALL SELECT MAX(rpid) FROM rcl UNION ALL SELECT MAX(PatientID) FROM AppointmentLog) m);
INSERT INTO pat (pid, plname, pfname, pinitial, pdentist, phygienist, pbirth, pgender, pmrmrs, pstatus,
  pchargeto, paptinvl, pnormunits, plnamcase, pfnamcase, pnativetongue, psince, pphone, pworkphn, paltid)
VALUES (@pid, UPPER(@lastName), UPPER(@firstName), '', @dentistId, '', @birthDate, @gender,
  CASE @gender WHEN 'F' THEN 'Ms.' WHEN 'M' THEN 'Mr.' ELSE '' END, ' ',
  0, 6, 3, 1, 1, ' ', CAST(GETDATE() AS date), LEFT(@phone + SPACE(10), 10), SPACE(10), SPACE(12));
INSERT INTO inf (infpid, infnote, infmedical, infothphn, infothphndesc, infemail, infmobile, inflocation)
VALUES (@pid, '', '', SPACE(10), '', @email, LEFT(@mobile + SPACE(10), 10), 1);
COMMIT;
SELECT ${PATIENT_COLUMNS} FROM pat p LEFT JOIN inf i ON i.infpid = p.pid WHERE p.pid = @pid;`;

// atime is a time-of-day on the 1899-12-30 zero date; durations are in scheduler units (sys.sunitmins).
const APPOINTMENT_COLUMNS = `
  a.aidentifier AS id, a.apid AS patientId, RTRIM(p.pfname) + ' ' + RTRIM(p.plname) AS patientName,
  CONVERT(char(10), a.adate, 23) AS date, CONVERT(char(5), a.atime, 108) AS start,
  a.atimereq * u.mins AS durationMinutes, RTRIM(a.achair) AS chair, RTRIM(a.adid) AS providerId,
  a.astatus AS statusCode, s.apsdesc AS status, a.apwork AS work`;

const APPOINTMENT_FROM = `
FROM apt a
CROSS JOIN (SELECT TOP 1 sunitmins AS mins FROM sys WHERE sunitmins > 1) u
LEFT JOIN pat p ON p.pid = a.apid
LEFT JOIN aps s ON s.apsid = a.astatus`;

export const LIST_APPOINTMENTS = `
SELECT ${APPOINTMENT_COLUMNS} ${APPOINTMENT_FROM}
WHERE a.adate = @date AND a.apid > 0 ORDER BY a.atime, a.achair`;

export const CREATE_APPOINTMENT = `
SET XACT_ABORT ON;
DECLARE @atime datetime = CAST('1899-12-30' AS datetime) + CAST(CAST(@start AS time) AS datetime);
DECLARE @unit int = (SELECT TOP 1 sunitmins FROM sys WHERE sunitmins > 1);
DECLARE @units smallint = CEILING(@durationMinutes * 1.0 / @unit);
BEGIN TRAN;
IF NOT EXISTS (SELECT 1 FROM pat WHERE pid = @patientId) THROW 50001, 'VALIDATION: Unknown patient', 1;
IF NOT EXISTS (SELECT 1 FROM dnt WHERE RTRIM(did) = @providerId) THROW 50002, 'VALIDATION: Unknown provider', 1;
IF NOT EXISTS (SELECT 1 FROM apt WHERE RTRIM(achair) = @chair) THROW 50005, 'VALIDATION: Unknown chair', 1;
IF DATEDIFF(MINUTE, 0, CAST(@start AS time)) % @unit <> 0 THROW 50003, 'VALIDATION: Start is off the scheduler grid', 1;
-- Overlap: an existing [atime, atime + units) in the same chair intersects the new slot
IF EXISTS (SELECT 1 FROM apt WITH (UPDLOCK, HOLDLOCK) WHERE adate = @date AND RTRIM(achair) = @chair
  AND atime < DATEADD(MINUTE, @units * @unit, @atime) AND DATEADD(MINUTE, atimereq * @unit, atime) > @atime)
  THROW 50004, 'VALIDATION: Slot overlaps an existing appointment', 1;
DECLARE @id uniqueidentifier = NEWID();
INSERT INTO apt (apid, adate, achair, atime, astatus, atimereq, apxfee, apwork, apwrk2, adid, apallocate,
  aconfstat, alabstat, ashortstat, afuture, aduedate, aidentifier, UpdateInfo)
VALUES (@patientId, @date, @chair, @atime, ' ', @units, 0, @work, '', @providerId, CAST(@units AS varchar(10)),
  ' ', ' ', ' ', SPACE(4), @date, @id, 0);
COMMIT;
SELECT ${APPOINTMENT_COLUMNS} ${APPOINTMENT_FROM} WHERE a.aidentifier = @id;`;
