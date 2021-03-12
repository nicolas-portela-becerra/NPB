use master
go

create database AutoescuelaTemporales
go
use AutoescuelaTemporales
go

--FILESTREAM
--ACTIVAR FILESTREAM PARA LA BASE DE DATOS
EXEC sp_configure filestream_access_level, 2
RECONFIGURE
GO

ALTER DATABASE AutoescuelaTemporales
	ADD FILEGROUP 
	CONTAINS FILESTREAM 
GO
ALTER DATABASE AutoescuelaTemporales
       ADD FILE (
             NAME = 'MyDatabase_filestream',
             FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\Autoescuela_Temporal_FileStream'
       )
       TO FILEGROUP [PRIMARY_FILESTREAM] 
GO

--TABLA CON FILESTREAM

USE [AutoescuelaTemporales]
GO

DROP TABLE IF EXISTS [dbo].[coches]
GO
CREATE TABLE [coches]
(
	[matricula] VARCHAR(7) /*PRIMARY KEY*/ NOT NULL,
	[modelo] VARCHAR(10) NOT NULL,
	[marca] VARCHAR(10) NOT NULL,
	[imagen] VARBINARY(MAX) FILESTREAM NULL,
	[imagen_id] UNIQUEIDENTIFIER ROWGUIDCOL  NOT NULL UNIQUE
)
GO

INSERT INTO COCHES (matricula, modelo, marca, imagen_id, imagen)
SELECT '1111AAA', 'C3', 'Citroën', NEWID(), BULKCOLUMN FROM OPENROWSET (BULK 'C:\FotosCoches\C3.jpg',SINGLE_BLOB) as f;

SELECT * FROM Coches
GO

--Documentacion de Microsoft
/*CREATE TABLE dbo.Records
(
    [Id] [uniqueidentifier] ROWGUIDCOL NOT NULL UNIQUE, 
    [SerialNumber] INTEGER UNIQUE,
    [Chart] VARBINARY(MAX) FILESTREAM NULL
)
GO*/

--AL FINAL FUNCIONO DE FORMA NORMAL
--INSERT INTO COCHES2 (imagen_id, imagen)
--SELECT  NEWID(),BULKCOLUMN FROM OPENROWSET (BULK 'C:\FotosCoches\C3.jpg',SINGLE_BLOB) as f;

--DROP TABLE IF EXISTS [dbo].[coches2]
--GO
--CREATE TABLE [coches2]
--(
--	[imagen] VARBINARY(MAX) FILESTREAM NULL,
--	[imagen_id] UNIQUEIDENTIFIER ROWGUIDCOL  NOT NULL UNIQUE
--)
--GO

--INSERT INTO [dbo].[coches2]  (imagen_id, imagen)
--SELECT  NEWID(),BULKCOLUMN FROM OPENROWSET (BULK 'C:\FotosCoches\C3.jpg',SINGLE_BLOB) as f;

--		SELECT NEWID(), BulkColumn
--		FROM OPENROWSET(BULK 'C:\Fotos_Actores\thor.jpg', SINGLE_BLOB) as f;


--NO SE PUEDEN AÑADIR CAMPOS FILESTREAM A UNA TABLA CON HISTORY_TABLE
-----------------------------------

--Tabla Temporal, control de los movimientos
DROP TABLE IF EXISTS Alumnos
GO
create table Alumnos
(
	id int identity(1,1) primary key,
	nombre varchar(50),
	apellidos varchar(50),
	psicotecnico bit not null default 0,
	SysStartTime datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
	SysEndTime datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
	PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime)
)
with
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Altas_Alumnos)
)
go

--Procedimiento de almacenado INSERTAR ALUMNO
Create or alter PROC dbo.InsertAlumno
	--Parametros de Entrada 
	@nombre varchar(50),
	@apellidos varchar(50),
	@psicotecnico bit
AS
BEGIN
	Insert into dbo.Alumnos
	(nombre, apellidos, psicotecnico)
	Values
	(@nombre, @apellidos, @psicotecnico);
END;
GO


EXEC InsertAlumno
	@Nombre='Nicolás',
	@Apellidos='Portela Becerra',
	@psicotecnico=0
GO
Select * from Alumnos
GO

UPDATE Alumnos
	set psicotecnico=1
	where Apellidos='Portela Becerra'
GO
SELECT * FROM Altas_Alumnos
GO

EXEC InsertAlumno
	@Nombre='Pepe',
	@Apellidos='García García',
	@psicotecnico=0
GO
SELECT * FROM Alumnos;

UPDATE Alumnos
	set psicotecnico=1
	where Apellidos='García García'
GO
SELECT * FROM Altas_Alumnos;


--ALTER TABLE dbo.Alumnos SET (SYSTEM_VERSIONING = OFF);

--------------------------------------------

--BASES DE DATOS CONTENIDAS
DROP DATABASE IF EXISTS Contenida_Autoescuela
GO
CREATE DATABASE Contenida_Autoescuela
CONTAINMENT=PARTIAL
GO
USE Contenida_Autoescuela
GO

DROP USER IF EXISTS admin
GO
CREATE USER admin
	WITH PASSWORD='Abcd1234.',
	DEFAULT_SCHEMA=dbo
GO
ALTER ROLE db_owner
	ADD MEMBER admin
GO

--------------------------

--PARTICIONES

USE AutoescuelaTemporales
GO

ALTER DATABASE AUTOESCUELATEMPORALES ADD FILEGROUP [FG_2019]
GO
ALTER DATABASE AUTOESCUELATEMPORALES ADD FILEGROUP [FG_2020]
GO
ALTER DATABASE AUTOESCUELATEMPORALES ADD FILEGROUP [FG_2021]
GO

SELECT * FROM SYS.filegroups
GO

ALTER DATABASE AutoescuelaTemporales ADD FILE ( NAME = 'Altas_2019', FILENAME = 'c:\DATA\Altas_2019.ndf', SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB ) TO FILEGROUP [FG_2019]
GO
ALTER DATABASE AutoescuelaTemporales ADD FILE ( NAME = 'Altas_2020', FILENAME = 'c:\DATA\Altas_2020.ndf', SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB ) TO FILEGROUP [FG_2020]
GO
ALTER DATABASE AutoescuelaTemporales ADD FILE ( NAME = 'Altas_2021', FILENAME = 'c:\DATA\Altas_2021.ndf', SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB ) TO FILEGROUP [FG_2021]
GO

select * from sys.filegroups
GO
select * from sys.database_files
GO

--FUNCION
CREATE PARTITION FUNCTION FN_Altas_Alumnos (datetime)
AS RANGE RIGHT
	FOR VALUES ('2019-01-01','2020-01-01')
GO
--ESQUEMA
CREATE PARTITION SCHEME Altas_Alumnos
AS PARTITION FN_Altas_Alumnos
	TO (FG_2019, FG_2020, FG_2021)
GO

--PEQUEÑA VARIANTE DE LA TABLA ORIGINAL PARA EL EJEMPLO
--CON UN USO NORMAL SE USARIA LA TABALA DE ANTES PERO PARA ESTE EJEMPLO
--SE NECESITA PODER INTRODUCIR LAS FECHAS MANUALMENTE
DROP TABLE IF EXISTS Alumnos
GO
create table Alumnos
(
	id int identity(1,1) primary key,
	nombre varchar(50),
	apellidos varchar(50),
	psicotecnico bit not null default 0,
	Fecha_Alta datetime
	--SysStartTime datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
	--SysEndTime datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
	--PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime)
)
ON Altas_Alumnos
	(Fecha_Alta)
with
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Altas_Alumnos)
)
go
--???
--Column 'Fecha_Alta' is partitioning column of the index 'PK__Alumnos__8F9E2E59'. Partition columns for a unique index must be a subset of the index key.


------------------------------------------------------------------



--PROCEDIMIENTO DE ALMACENADO PARA BACKUP DE BASES DE DATOS

CREATE OR ALTER PROCEDURE Backup_Autoescuela
	@path varchar (256)
AS
DECLARE @name VARCHAR(50), 
@filename VARCHAR(256), 
@filedate VARCHAR(20), 
@backupcount INT

--Tabla temporal donde se guardan los nombres de las bases de datos
CREATE TABLE [dbo].#tempBackup 
(intID int identity (1, 1),
name VARCHAR(200))

--Hacer que aparezca fecha en el nombre del backup
SET @filedate = CONVERT(VARCHAR(20), GETDATE(), 112) --112 es un formato para la fecha, hay distintos tipos de formatos

--Selecciono las bases de datos de las que quiero que se haga backup
INSERT INTO dbo.#tempBackup (name)
	SELECT name
	FROM master.dbo.sysdatabases
	WHERE name in ('Autoescuela')

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
				@filename = @path + name + '_'+ @filedate + '.BAK'
				FROM [dbo].#tempBackup
				WHERE intID = @currentbackup

			print @filename

				BACKUP DATABASE @name TO DISK = @filename
			
			BACKUP DATABASE @name TO DISK = @filename WITH INIT

				SET @currentbackup = @currentbackup + 1
		END
END

EXEC Backup_Autoescuela
	@path = 'C:\Backup\'
GO
--(1 row affected)
--C:\Backup\Autoescuela_20210307.BAK
--Processed 400 pages for database 'Autoescuela', file 'Autoescuela' on file 1.
--Processed 2 pages for database 'Autoescuela', file 'Autoescuela_log' on file 1.
--BACKUP DATABASE successfully processed 402 pages in 0.580 seconds (5.403 MB/sec).
--Processed 400 pages for database 'Autoescuela', file 'Autoescuela' on file 1.
--Processed 2 pages for database 'Autoescuela', file 'Autoescuela_log' on file 1.
--BACKUP DATABASE successfully processed 402 pages in 0.036 seconds (87.036 MB/sec).



-----------------------------------------------------------------------------------


USE Autoescuela2
GO
create table Prueba
(
	ID varchar(20) primary key,
	cosa int,
	algo varchar(20)
)
GO

alter table Prueba add img VARBINARY(MAX) FILESTREAM NULL, imagen_id UNIQUEIDENTIFIER ROWGUIDCOL  NOT NULL UNIQUE;
GO

----------------------------------------------------------------------------------------


DROP DATABASE IF EXISTS Autoescuela
GO
CREATE DATABASE Autoescuela
	ON PRIMARY (NAME='Autoescuela',
	FILENAME = 'C:\Data\Autoescuela.mdf', 
	SIZE=15360KB, MAXSIZE=UNLIMITED, FILEGROWTH=0)
	LOG ON (NAME='Autoescuela_log',
	FILENAME='C:\Data\Autoescuela.ldf',
	SIZE=10176KB, MAXSIZE=2048GB, FILEGROWTH=10%)
GO
USE Autoescuela








