
--EXEC sp_configure filestream_access_level, 2
--RECONFIGURE
--GO
-- FileTable

DROP DATABASE IF EXISTS SQLFileTable
GO
CREATE DATABASE SQLFileTable
ON PRIMARY
(
    NAME = SQLFileTable_data,
    FILENAME = 'C:\FileTable\SQLFileTable.mdf'
),
FILEGROUP FileStreamFG CONTAINS FILESTREAM
(
    NAME = SQLFileTable,
    FILENAME = 'C:\FileTable\FileTable_Container' 
)
LOG ON
(
    NAME = SQLFileTable_Log,
    FILENAME = 'C:\FileTable\SQLFileTable_Log.ldf'
)
WITH FILESTREAM
(
    NON_TRANSACTED_ACCESS = FULL,
    DIRECTORY_NAME = 'FileTableContainer'
);
GO
-------------------------
-- METADATA

-- Check the Filestream Options
SELECT DB_NAME(database_id),
non_transacted_access,
non_transacted_access_desc
FROM sys.database_filestream_options;
GO
----------------
-- Another version
SELECT DB_NAME(database_id) as DatabaseName, non_transacted_access, non_transacted_access_desc 
FROM sys.database_filestream_options
where DB_NAME(database_id)='SQLFileTable';
GO

--We can have the following options for non-transacted access.

--OFF: Non-transactional access to FileTables is not allowed
--Read Only– Non-transactional access to FileTables is allowed for the read-only purpose
--Full– Non-transactional access to FileTables is allowed for both reading and writing
--Specify a directory for the SQL Server FILETABLE. We need to specify directory without directory path. This directory acts as a root path in FILETABLE hierarchy. We will explore more in a further section of this article


-- Createe FileTable Table
USE SQLFileTable
GO
DROP TABLE IF EXISTS SQLDemoDocuments 
GO
CREATE TABLE SQLDemoDocuments 
AS FILETABLE
WITH 
(
    FileTable_Directory = 'FileTableContainer',
    FileTable_Collate_Filename = database_default
);
GO
-- See FileTableTb in OBJECT EXPLORER

-- Now you can select data using a regular select table.

SELECT *
FROM SQLDemoDocuments
GO


-- Arrastro 3 objetos


SELECT TOP (1000) [stream_id]
      ,[file_stream]
      ,[name]
      ,[path_locator]
      ,[parent_path_locator]
      ,[file_type]
      ,[cached_file_size]
      ,[creation_time]
      ,[last_write_time]
      ,[last_access_time]
      ,[is_directory]
      ,[is_offline]
      ,[is_hidden]
      ,[is_readonly]
      ,[is_archive]
      ,[is_system]
      ,[is_temporary]
  FROM [SQLFileTable].[dbo].[SQLDemoDocuments]
  go

-- SUMMING UP

SELECT  [stream_id],[name]
  FROM [SQLFileTable].[dbo].[SQLDemoDocuments]
GO

--  stream_id									           name
--B4608232-B146-EA11-9BCD-000C29A5C7F8					hiremenow.png
--B5608232-B146-EA11-9BCD-000C29A5C7F8					names.xls
--B7608232-B146-EA11-9BCD-000C29A5C7F8					Seguridad Encerado.jpeg

CREATE TABLE [dbo].[authors](
	[au_id] int NOT NULL,
	[au_lname] [varchar](40) NOT NULL,
	[au_fname] [varchar](20) NOT NULL,
	[phone] [char](12) NOT NULL,
	[address] [varchar](40) NULL,
	[city] [varchar](20) NULL,
	[state] [char](2) NULL,
	[zip] [char](5) NULL,
	[contract] [bit] NOT NULL,
 CONSTRAINT [UPKCL_auidind] PRIMARY KEY CLUSTERED 
(
	[au_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO




