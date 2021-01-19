USE AdventureWorks2017
GO
DECLARE Employee_Cursor CURSOR FOR
	SELECT BusinessEntityID, JobTitle
	FROM AdventureWorks2017.HumanResources.Employee;
OPEN Employee_Cursor;
FETCH NEXT FROM Employee_Cursor;
WHILE @@FETCH_STATUS = 0
	BEGIN
		FETCH NEXT FROM Employee_Cursor
	END;
CLOSE Employee_Cursor;
DEALLOCATE Employee_Cursor;
GO

------------------------------------------------

USE master
GO
CREATE OR ALTER PROC Backup_con_Cursores
AS
	BEGIN
		DECLARE @name VARCHAR(50) --Database name
		DECLARE @path VARCHAR(50) --Path for the file
		DECLARE @filename VARCHAR(256) --filename
		DECLARE @fileDate VARCHAR(20) --used for file name

		--Especificar el directorio
		SET @path='C:\Backup\'

		--Especificar formato del archivo
		SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112)
		--Especificar hora y minuto en el archivo
		--https://www.mssqltips.com/sqlservertip/1145/date-and-time-conversions-using-sql-server/
		--SELECT @fileDate=CONVERT(VARCHAR(20),GETDATE(),112) + REPLACE(CONVERT(VARCHAR(20),GETDATE(108),':','')
		--Lo de arriba da error por los : del final
		--SELECT @fileDate = CONVERT(VARCHAR(20)GETDATE(),112) + CONVERT(VARCHAR(20),GETDATE(),

		DECLARE db_cursor CURSOR READ_ONLY FOR
		SELECT name
		FROM master.dbo.sysdatabases
		--WHERE name IN ('Northwind')
		WHERE NAME IN ('Northwind', 'Adventureworks2017')
		--WHERE name NOT IN ('master','model','msdb','tempdb')

		OPEN db_cursor
		FETCH NEXT FROM db_cursor INTO @name


		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @filename = @path + @name + '_' + @fileDate + '.BAK'
			BACKUP DATABASE @name TO DISK = @fileName

			FETCH NEXT FROM db_cursor INTO @name
		END
		CLOSE db_cursor
		DEALLOCATE db_cursor
	END
GO

EXECUTE Backup_con_Cursores
GO





