-- disable referential integrity
EXEC sp_MSForEachTable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';

-- truncate tables
EXEC sp_MSForEachTable 'truncate table ?';

-- enable referential integrity again 
EXEC sp_MSForEachTable 'ALTER TABLE ? CHECK CONSTRAINT ALL';

--rebuild all indexes
Exec sp_msforeachtable 'SET QUOTED_IDENTIFIER ON; ALTER INDEX ALL ON ? REBUILD'