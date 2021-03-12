-- https://dba-presents.com/index.php/databases/sql-server/59-introduction-to-filestream

-- A BLOB, or Binary Large Object, is an SQL object data type, meaning 
-- it is a reference or pointer to an object. 
-- Typically a BLOB is a file, image, video, or other large object. 
-- In database systems, such as Oracle and SQL Server, a BLOB can hold 
-- as much as 4 gigabytes. 

-- https://docs.microsoft.com/en-us/sql/relational-databases/blob/binary-large-object-blob-data-sql-server?view=sql-server-ver15

-- Options for Storing Blobs

-- FILESTREAM (SQL Server)
-- FILESTREAM enables SQL Server-based applications to store unstructured data, 
	--such as documents and images, on the file system. Applications can leverage the rich streaming APIs and performance of the file system and at the same time maintain transactional consistency between the unstructured data and corresponding structured data.

--FileTables (SQL Server)
--The FileTable feature brings support for the Windows file namespace and compatibility with Windows applications to the file data stored in SQL Server. FileTable lets an application integrate its storage and data management components, and provides integrated SQL Server services - including full-text search and semantic search - over unstructured data and metadata.

--In other words, you can store files and documents in special tables in SQL Server called FileTables, but access them from Windows applications as if they were stored in the file system, without making any changes to your client applications.

--Remote Blob Store (RBS) (SQL Server)
--Remote BLOB store (RBS) for SQL Server lets database administrators store binary large objects (BLOBs) in commodity storage solutions instead of directly on the server. This saves a significant amount of space and avoids wasting expensive server hardware resources. RBS provides a set of API libraries that define a standardized model for applications to access BLOB data. RBS also includes maintenance tools, such as garbage collection, to help manage remote BLOB data.

--RBS is included on the SQL Server installation media, but is not installed by the SQL Server Setup program.


-- https://www.sqlshack.com/viewing-sql-server-filestream-data-with-ssrs/

-- https://blog.sqlauthority.com/2019/03/01/sql-server-sql-server-configuration-manager-missing-from-start-menu/

-- IF CONFIGURATION MANAGER  
-- SQL Server 2017	SQLServerManager14.msc

-- ENABLE FILESTREAM

-- RESTART MSSQLSERVER SERVICE

-------------------------------------------------
-- Before FILESTREAM can be used, it has to be enabled on the instance. 
-- To do this, go to Configuration Manager, select SQL Server Services and double click the instance you would like to have FILESTREAM enabled.

--	A nivel de BD mediante sp_configure @enablelevel, dónde @enablelevel indica:

--0 = Deshabilitado. Este es el valor por defecto.
--1 = Habilitado solo para acceso T-SQL.
--2 = Habilitado solo para T-SQL y acceso local al sistema de ficheros.
--3 = Habilitado para T-SQL, acceso local y remoto al sistema de ficheros.


EXEC sp_configure filestream_access_level, 2
RECONFIGURE
GO

--Configuration option 'filestream access level' changed from 0 to 2. Run the RECONFIGURE statement to install.
--FILESTREAM feature could not be initialized. The operating system Administrator must enable FILESTREAM on the instance using Configuration Manager.

USE [master]
GO
DROP DATABASE IF EXISTS PruebaFS
GO
CREATE DATABASE PruebaFS
go
USE PruebaFS
go
--Necesitamos crear un FileGroup y agregarle un archivo
ALTER DATABASE PruebaFS 
	ADD FILEGROUP [PRIMARY_FILESTREAM] 
	CONTAINS FILESTREAM 
GO
ALTER DATABASE PruebaFS
       ADD FILE (
             NAME = 'MyDatabase_filestream',
             FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\filestream'
       )
       TO FILEGROUP [PRIMARY_FILESTREAM]
GO
USE PruebaFS
GO
DROP TABLE IF EXISTS IMAGES
GO
CREATE TABLE images(
       id UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL UNIQUE,
       imageFile VARBINARY(MAX) FILESTREAM
);
GO
-- FOLDER C:\Fotos_Actores\

INSERT INTO images(id, imageFile)
		SELECT NEWID(), BulkColumn
		FROM OPENROWSET(BULK 'C:\Fotos_Actores\thor.jpg', SINGLE_BLOB) as f;
GO
INSERT INTO images(id, imageFile)
	SELECT NEWID(), BulkColumn
	FROM OPENROWSET(BULK 'C:\Fotos_Actores\vin.jpg', SINGLE_BLOB) as f;
GO
INSERT INTO images(id, imageFile)
	SELECT NEWID(), BulkColumn
	FROM OPENROWSET(BULK 'C:\Fotos_Actores\will.jpg', SINGLE_BLOB) as f;
GO

SELECT *
FROM images;
GO

-- C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\filestream
-- Open with PAINT

-- Filestream columns
SELECT SCHEMA_NAME(t.schema_id) AS [schema], 
    t.[name] AS [table],
    c.[name] AS [column],
    TYPE_NAME(c.user_type_id) AS [column_type]
FROM sys.columns c
JOIN sys.tables t ON c.object_id = t.object_id
WHERE t.filestream_data_space_id IS NOT NULL
    AND c.is_filestream = 1
ORDER BY 1, 2, 3;
-- Filestream files and filegroups
SELECT f.[name] AS [file_name],
    f.physical_name AS [file_path],
    fg.[name] AS [filegroup_name]
FROM sys.database_files f 
JOIN sys.filegroups fg ON f.data_space_id = fg.data_space_id
WHERE f.[type] = 2
ORDER BY 1;
GO

ALTER TABLE [dbo].[images] DROP COLUMN [imageFile]
GO
ALTER TABLE [images] SET (FILESTREAM_ON="NULL")
GO

ALTER DATABASE [PruebaFS] REMOVE FILE MyDatabase_filestream;
GO

--Msg 5042, Level 16, State 13, Line 134
--The file 'MyDatabase_filestream' cannot be removed because it is not empty.

USE master
GO

ALTER DATABASE [PruebaFS] REMOVE FILE MyDatabase_filestream;
GO

--The file 'MyDatabase_filestream' has been removed.
--Msg 5535, Level 23, State 30, Line 143
--FILESTREAM data container 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\filestream' is corrupted.  Database cannot recover

ALTER DATABASE [PruebaFS] REMOVE FILEGROUP  [PRIMARY_FILESTREAM]
GO

-- The filegroup 'PRIMARY_FILESTREAM' has been removed.

DROP DATABASE [PruebaFS]
GO


-------------------------------------------------------

-- https://docs.microsoft.com/es-es/sql/relational-databases/blob/create-client-applications-for-filestream-data?view=sql-server-2017


-- https://docs.microsoft.com/es-es/sql/relational-databases/blob/access-filestream-data-with-opensqlfilestream?view=sql-server-2017

-- No parece tener creado el FILEGROUP para FILESTREAM

-- DB [AdventureWorks2017]
--CREATE DATABASE [AdventureWorks2017]
-- CONTAINMENT = NONE
-- ON  PRIMARY 
--( NAME = N'AdventureWorks2017', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\AdventureWorks2017.mdf' , SIZE = 270336KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
-- LOG ON 
--( NAME = N'AdventureWorks2017_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\AdventureWorks2017_log.ldf' , SIZE = 73728KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
--GO
-------------------
USE AdventureWorks2017
GO
sp_help '[Production].[Document]'
GO
SELECT * FROM  Production.Document
GO

ALTER DATABASE [AdventureWorks2017]
 ADD FILEGROUP [PRIMARY_FILESTREAM] CONTAINS FILESTREAM 
GO
ALTER DATABASE [AdventureWorks2017]
       ADD FILE (
             NAME = '[AdventureWorks2017]_filestream',
             FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\AdventureWorks2017_FS'
       )
       TO FILEGROUP [PRIMARY_FILESTREAM]
GO

DROP TABLE IF EXISTS [Production].[Documento]
GO
--CREATE TABLE [Production].[Documento](
--    [DocumentNode] [hierarchyid] NOT NULL,
--    [DocumentLevel]  AS ([DocumentNode].[GetLevel]()),
--    [Title] [nvarchar](50) NOT NULL,
--    [Owner] [int] NOT NULL,
--    [FolderFlag] [bit] NOT NULL,
--    [FileName] [nvarchar](400) NOT NULL,
--    [FileExtension] [nvarchar](8) NOT NULL,
--    [Revision] [nchar](5) NOT NULL,
--    [ChangeNumber] [int] NOT NULL,
--    [Status] [tinyint] NOT NULL,
--    [DocumentSummary] [nvarchar](max) NULL,
--    [Document] [varbinary](max) FILESTREAM  NULL,	-- para ejemplo FILESTREAM
--    [rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL, --- para ejemplo FILESTREAM
--    [ModifiedDate] [datetime] NOT NULL
--    );
--GO

--Msg 1969, Level 16, State 1, Line 64
--Default FILESTREAM filegroup is not available in database 'AdventureWorks2017'.

SELECT *
INTO [Production].[Documento]
FROM [Production].[Document]
GO

-- (13 rows affected)

SELECT [Title],[FileName],[FileExtension],[DocumentSummary],[Document],[rowguid]
FROM  Production.Documento
GO

SELECT [Title],[FileName],[FileExtension],[DocumentSummary],[Document],[rowguid]
INTO [Production].[DocumentoPequeño]
FROM [Production].[Document]
GO

-- (13 rows affected)

SELECT [Title],[FileName],[FileExtension],[DocumentSummary],[Document],[rowguid]
FROM  Production.DocumentoPequeño
GO

INSERT INTO Production.DocumentoPequeño( [Title],[FileName],[FileExtension],[DocumentSummary],[Document],[rowguid]) 
Values ('Probando a Insertar','Prueba','xls','Resumen',
       0xFFD8FFE000104A46494600010101006000600000FFE100684578696600004D4D002A000000080004011A0005000000010000003E011B0005000000010000004601280003000000010002000001310002000000120000004E00000000000000600000000100000060000000015061696E742E4E45542076332E352E313000FFDB0043000201010201010202020202020202030503030303030604040305070607070706070708090B0908080A0807070A0D0A0A0B0C0C0C0C07090E0F0D0C0E0B0C0C0CFFDB004301020202030303060303060C0807080C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0CFFC0001108000A000D03012200021101031101FFC4001F0000010501010101010100000000000000000102030405060708090A0BFFC400B5100002010303020403050504040000017D01020300041105122131410613516107227114328191A1082342B1C11552D1F02433627282090A161718191A25262728292A3435363738393A434445464748494A535455565758595A636465666768696A737475767778797A838485868788898A92939495969798999AA2A3A4A5A6A7A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3D4D5D6D7D8D9DAE1E2E3E4E5E6E7E8E9EAF1F2F3F4F5F6F7F8F9FAFFC4001F0100030101010101010101010000000000000102030405060708090A0BFFC400B51100020102040403040705040400010277000102031104052131061241510761711322328108144291A1B1C109233352F0156272D10A162434E125F11718191A262728292A35363738393A434445464748494A535455565758595A636465666768696A737475767778797A82838485868788898A92939495969798999AA2A3A4A5A6A7A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3D4D5D6D7D8D9DAE2E3E4E5E6E7E8E9EAF2F3F4F5F6F7F8F9FAFFDA000C03010002110311003F00E97FE0E87FF82CA7ED35FB04FED85E09F03FC2BD6A5F87BE1097408B5C4D523D2ADAF1BC41746795248CBDC4722F970848C18940399373E43478FD75FF00827CFC68F177ED17FB0FFC2AF1D78F3461A078C7C59E19B2D4F57B110B42B14F244199846DF346AFC384392A1C024E335E95E2EF87BE1FF880968BAF687A3EB6B612F9F6C2FECA3B916F27F7D3783B5BDC60D6C5007FFFD9
	   ,NEWID()
      );
go

-- (1 row affected)

SELECT Top 5 [Title],[FileName],[FileExtension],[DocumentSummary],[Document],[rowguid]
FROM  Production.DocumentoPequeño
ORDER BY NEWID() DESC
GO


INSERT INTO Production.DocumentoPequeño( [Title],[FileName],[FileExtension],[DocumentSummary],[Document],[rowguid]) 
Values ('Probando a Insertar con CAST','Prueba','txt','Resumen',
       CAST ('Foto de los alumnos de ASIB' AS VARBINARY(MAX))
	   ,NEWID()
      );
go

-- (1 row affected)



SELECT Top 5 [Title],[FileName],[FileExtension],[DocumentSummary],[Document],[rowguid]
FROM  Production.DocumentoPequeño
ORDER BY Title  DESC
GO


----------------------------------


-- http://andreyzavadskiy.com/2018/01/25/drop-filestream-in-sql-server/

-- Drop Filestream In SQL Server


-- Filestream columns
SELECT SCHEMA_NAME(t.schema_id) AS [schema], 
    t.[name] AS [table],
    c.[name] AS [column],
    TYPE_NAME(c.user_type_id) AS [column_type]
FROM sys.columns c
JOIN sys.tables t ON c.object_id = t.object_id
WHERE t.filestream_data_space_id IS NOT NULL
    AND c.is_filestream = 1
ORDER BY 1, 2, 3;
-- Filestream files and filegroups
SELECT f.[name] AS [file_name],
    f.physical_name AS [file_path],
    fg.[name] AS [filegroup_name]
FROM sys.database_files f 
JOIN sys.filegroups fg ON f.data_space_id = fg.data_space_id
WHERE f.[type] = 2
ORDER BY 1;
GO


ALTER TABLE [FilestreamTable] DROP COLUMN [FilestreamColumn];
ALTER TABLE [FilestreamTable] SET (FILESTREAM_ON="NULL")
ALTER DATABASE [FilestreamDatabase] REMOVE FILE [FilestreamFile];
ALTER DATABASE [FilestreamDatabase] REMOVE FILEGROUP [FilestreamFilegroup];

