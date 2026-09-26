-- Columns + triggers for core ABELDent tables (schema only)
SELECT t.name tbl, c.column_id id, c.name col, ty.name type, c.max_length len, c.is_nullable nul, c.is_identity ident,
  (SELECT TOP 1 1 FROM sys.index_columns ic JOIN sys.indexes i ON i.object_id=ic.object_id AND i.index_id=ic.index_id WHERE i.is_primary_key=1 AND ic.object_id=c.object_id AND ic.column_id=c.column_id) pk,
  OBJECT_DEFINITION(c.default_object_id) dflt
FROM sys.tables t JOIN sys.columns c ON c.object_id=t.object_id JOIN sys.types ty ON ty.user_type_id=c.user_type_id
WHERE t.name IN ('pat','apt','apn','cnt','ins','dnt','aps','AppointmentTypes','PatientAlert','Location')
ORDER BY t.name, c.column_id
