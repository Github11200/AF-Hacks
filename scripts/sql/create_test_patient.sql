-- Write test: one clearly-labelled fictional patient + its 1:1 inf row, mirroring app-created rows.
SET XACT_ABORT ON;
BEGIN TRAN;
-- Deleted patients leave rows behind in child tables, so the next id must clear every pid-bearing table.
DECLARE @pid int = 1 + (SELECT MAX(id) FROM (
  SELECT MAX(pid) id FROM pat WITH (UPDLOCK, HOLDLOCK) UNION ALL SELECT MAX(infpid) FROM inf
  UNION ALL SELECT MAX(apid) FROM apt UNION ALL SELECT MAX(apid) FROM aptdel UNION ALL SELECT MAX(apnpid) FROM apn
  UNION ALL SELECT MAX(cpid) FROM cnt UNION ALL SELECT MAX(rpid) FROM rcl UNION ALL SELECT MAX(PatientID) FROM AppointmentLog) m);
INSERT INTO pat (pid, plname, pfname, pinitial, pdentist, phygienist, pbirth, pgender, pmrmrs, pstatus,
  pchargeto, paptinvl, pnormunits, plnamcase, pfnamcase, pnativetongue, psince, pphone, pworkphn, paltid)
VALUES (@pid, 'ZZTEST', 'CLAUDE', '', 'T', 'M', '1990-01-01', 'F', 'Ms.', ' ',
  0, 6, 3, 1, 1, ' ', CAST(GETDATE() AS date), '5555550100', '          ', '            ');
INSERT INTO inf (infpid, infnote, infmedical, infothphn, infothphndesc, infemail, infmobile, inflocation)
VALUES (@pid, '', '', '          ', '', '', '          ', 1);
COMMIT;
SELECT pid, plname, pfname, pbirth FROM pat WHERE pid = @pid;
