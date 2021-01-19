--PROCEDIMIENTO DE ALMACENADO PARA BACKUP DE BASES DE DATOS

CREATE OR ALTER PROCEDURE Backup_All_Databases
	@path varchar (256)
AS
--DECLARACION VARIABLES
DECLARE @name VARCHAR(50), --nombre de la base de datos
--@path VARCHAR(256), --path para el backup
@filename VARCHAR(256), --nombre del backup
@filedate VARCHAR(20), --nombre del fichero
@backupcount INT


CREATE TABLE [dbo].#tempBackup --ES UNA TABLA TEMPORAL DONDE SE GUARDAN LOS NOMBRES DE LAS BASES DE DATOS A LAS QUE HACEMOS BACKUP
(intID int identity (1, 1),
name VARCHAR(200))
--SABEMOS QUE LA TABLA ES TEMPORAL PORQUE TIENE UN #

--Hay que crear la carpeta donde vamos a mandar los backup
--SET @path = 'C:\Backup\'

--Hacer que aparezca fecha en el nombre del backup
SET @filedate = CONVERT(VARCHAR(20), GETDATE(), 112) --112 es un formato para la fecha, hay distintos tipos de formatos

--Hacer que aparezca fecha y hora en el nombre del backup
--SET @filedate = CONVERT(VARCHAR(20), GETDATE(), 112) + '_' + REPLACE (CONVERT(VARCHAR(20), GETDATE(), 108), ':', '') 

--Selecciono las bases de datos de las que quiero que se haga backup
INSERT INTO dbo.#tempBackup (name)
	SELECT name
	FROM master.dbo.sysdatabases
	--WHERE name in ('Northwind', 'pubs') --Elijo cuales quiero que tengan backup
	WHERE name in ('AdventureWorks2017')
	--WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb') --Elijo cuales no tienen que tener backup

SELECT TOP 1 @backupcount = intID
FROM dbo.#tempbackup
ORDER BY intID DESC
--Comprueba el nº de backups

if ((@backupcount IS NOT NULL) AND (@backupcount >0))
BEGIN
	DECLARE @currentbackup INT
	SET @currentbackup = 1
	WHILE (@currentbackup <=@backupcount)
		BEGIN
			SELECT
				@name = name,
				@filename = @path + name + '_'+ @filedate + '.BAK' --Unique Filename
				--@filename = @path + @name + '.BAK' --Non-Unique Filename
				FROM [dbo].#tempBackup
				WHERE intID = @currentbackup

			--Utilidad: Solo comprobacion nombre de backup
			print @filename

			--does not overwrite the existing file
				BACKUP DATABASE @name TO DISK = @filename
			
			--overwites the existing file(Note: remove @fileDate from the filename so they are no longer
			BACKUP DATABASE @name TO DISK = @filename WITH INIT

				SET @currentbackup = @currentbackup + 1
		END
END

EXEC Backup_All_Databases
	@path = 'C:\Backup\'
GO
--(2 rows affected)
--C:\Backup\Northwind_20201222.BAK
--Processed 832 pages for database 'Northwind', file 'Northwind' on file 1.
--Processed 2 pages for database 'Northwind', file 'Northwind_log' on file 1.
--BACKUP DATABASE successfully processed 834 pages in 0.596 seconds (10.921 MB/sec).
--Processed 832 pages for database 'Northwind', file 'Northwind' on file 1.
--Processed 2 pages for database 'Northwind', file 'Northwind_log' on file 1.
--BACKUP DATABASE successfully processed 834 pages in 0.056 seconds (116.219 MB/sec).
--C:\Backup\pubs_20201222.BAK
--Processed 584 pages for database 'pubs', file 'pubs' on file 1.
--Processed 2 pages for database 'pubs', file 'pubs_log' on file 1.
--BACKUP DATABASE successfully processed 586 pages in 0.314 seconds (14.559 MB/sec).
--Processed 584 pages for database 'pubs', file 'pubs' on file 1.
--Processed 2 pages for database 'pubs', file 'pubs_log' on file 1.
--BACKUP DATABASE successfully processed 586 pages in 0.045 seconds (101.573 MB/sec).


EXEC Backup_All_Databases --Ahora hago backup de AdventureWorks2017
	@path = 'C:\Backup\'
GO
--(1 row affected)
--C:\Backup\AdventureWorks2017_20201222.BAK
--Processed 26296 pages for database 'AdventureWorks2017', file 'AdventureWorks2017' on file 1.
--Processed 2 pages for database 'AdventureWorks2017', file 'AdventureWorks2017_log' on file 1.
--BACKUP DATABASE successfully processed 26298 pages in 11.486 seconds (17.886 MB/sec).
--Processed 26296 pages for database 'AdventureWorks2017', file 'AdventureWorks2017' on file 1.
--Processed 2 pages for database 'AdventureWorks2017', file 'AdventureWorks2017_log' on file 1.
--BACKUP DATABASE successfully processed 26298 pages in 2.740 seconds (74.980 MB/sec).

