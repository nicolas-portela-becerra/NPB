


-- Temporal Tables


USE master 
go
DROP DATABASE IF EXISTS Colegio_Medico 
GO
CREATE DATABASE [Colegio_Medico] 
	ON PRIMARY ( NAME = 'Colegio_Medico', 
	FILENAME = 'C:\Data\Colegio_Medico_Fijo.mdf' , 
	SIZE = 15360KB , MAXSIZE = UNLIMITED, FILEGROWTH = 0) 
	LOG ON ( NAME = 'Colegio_Medico_log', 
	FILENAME = 'C:\Data\Colegio_Medico_log.ldf' , 
	SIZE = 10176KB , MAXSIZE = 2048GB , FILEGROWTH = 10%) 
GO

USE Colegio_Medico
GO

create table reserva_plaza 
	(   curso varchar(20) Primary Key Clustered,  
		num_reservas integer,  
	SysStartTime datetime2 generated always as row start not null,  
	SysEndTime datetime2 generated always as row end not null,  
	period for System_time (SysStartTime,SysEndTime) ) 
	with (System_Versioning = ON (History_Table = dbo.reserva_plaza_historico)
	) 
go

SELECT * FROM [dbo].[reserva_plaza]
GO
SELECT * FROM [dbo].[reserva_plaza_historico]
GO

-- Empty

insert into reserva_plaza (curso,num_reservas) 
values ('curso1',2), 
	('curso2',1), 
	('curso3',4), 
	('curso4',2), 
	('curso5',6) 
GO 
-- (5 rows affected)

SELECT * FROM [dbo].[reserva_plaza]
GO

--curso	num_reservas	SysStartTime					SysEndTime

--curso1	2		2018-12-19 16:11:52.6294735			9999-12-31 23:59:59.9999999

--curso2	1		2018-12-19 16:11:52.6294735			9999-12-31 23:59:59.9999999
--curso3	4		2018-12-19 16:11:52.6294735			9999-12-31 23:59:59.9999999
--curso4	2		2018-12-19 16:11:52.6294735			9999-12-31 23:59:59.9999999
--curso5	6		2018-12-19 16:11:52.6294735			9999-12-31 23:59:59.9999999

SELECT * FROM [dbo].[reserva_plaza_historico]
GO

-- curso	num_reservas	SysStartTime	SysEndTime

update reserva_plaza 
	set num_reservas = 7
	where curso = 'curso1'
GO

SELECT * FROM [dbo].[reserva_plaza]
GO

--curso	num_reservas	SysStartTime	SysEndTime

--curso1	7	2018-12-19 16:14:09.8269896	9999-12-31 23:59:59.9999999

--curso2	1	2018-12-19 16:11:52.6294735	9999-12-31 23:59:59.9999999
--curso3	4	2018-12-19 16:11:52.6294735	9999-12-31 23:59:59.9999999
--curso4	2	2018-12-19 16:11:52.6294735	9999-12-31 23:59:59.9999999
--curso5	6	2018-12-19 16:11:52.6294735	9999-12-31 23:59:59.9999999

SELECT * FROM [dbo].[reserva_plaza_historico]
GO

--curso	num_reservas	    SysStartTime	              SysEndTime
--curso1	2	          2018-12-19 16:11:52.6294735	2018-12-19 16:14:09.8269896

update reserva_plaza 
	set num_reservas = 9 
	where curso = 'curso2'
GO

SELECT * FROM [dbo].[reserva_plaza]
GO

--curso	num_reservas	SysStartTime	SysEndTime
--curso1	7				2018-12-19 16:14:09.8269896	9999-12-31 23:59:59.9999999

--curso2	9				2018-12-19 16:19:59.6537074	9999-12-31 23:59:59.9999999

--curso3	4				2018-12-19 16:11:52.6294735	9999-12-31 23:59:59.9999999
--curso4	2				2018-12-19 16:11:52.6294735	9999-12-31 23:59:59.9999999
--curso5	6				2018-12-19 16:11:52.6294735	9999-12-31 23:59:59.9999999

SELECT * FROM [dbo].[reserva_plaza_historico]
GO

--curso	num_reservas			SysStartTime						SysEndTime
--curso1	2				2018-12-19 16:11:52.6294735			2018-12-19 16:14:09.8269896
--curso2	1				2018-12-19 16:11:52.6294735			2018-12-19 16:19:59.6537074

update reserva_plaza 
	set num_reservas = 12 
	where curso = 'curso2' 
go

SELECT * FROM [dbo].[reserva_plaza]
GO

--curso	num_reservas				SysStartTime						SysEndTime
--curso1	7					2018-12-19 16:14:09.8269896			9999-12-31 23:59:59.9999999

--curso2	12					2018-12-19 16:25:09.6972015			9999-12-31 23:59:59.9999999

--curso3	4					2018-12-19 16:11:52.6294735			9999-12-31 23:59:59.9999999
--curso4	2					2018-12-19 16:11:52.6294735			9999-12-31 23:59:59.9999999
--curso5	6					2018-12-19 16:11:52.6294735			9999-12-31 23:59:59.9999999



SELECT * FROM [dbo].[reserva_plaza_historico]
GO

--curso	num_reservas		SysStartTime					SysEndTime
--curso1	2				2018-12-19 16:11:52.6294735		2018-12-19 16:14:09.8269896
--curso2	1				2018-12-19 16:11:52.6294735		2018-12-19 16:19:59.6537074
--curso2	9				2018-12-19 16:19:59.6537074		2018-12-19 16:25:09.6972015



delete from reserva_plaza 
	where curso='curso5'
GO

SELECT * FROM [dbo].[reserva_plaza]
GO

--curso	num_reservas	SysStartTime	SysEndTime
--curso1	7	2018-12-19 16:14:09.8269896	9999-12-31 23:59:59.9999999
--curso2	12	2018-12-19 16:25:09.6972015	9999-12-31 23:59:59.9999999
--curso3	4	2018-12-19 16:11:52.6294735	9999-12-31 23:59:59.9999999
--curso4	2	2018-12-19 16:11:52.6294735	9999-12-31 23:59:59.9999999


SELECT * FROM [dbo].[reserva_plaza_historico]
GO


--curso	num_reservas	SysStartTime	SysEndTime
--curso1	2	2018-12-19 16:11:52.6294735	2018-12-19 16:14:09.8269896
--curso2	1	2018-12-19 16:11:52.6294735	2018-12-19 16:19:59.6537074
--curso2	9	2018-12-19 16:19:59.6537074	2018-12-19 16:25:09.6972015
--curso5	6	2018-12-19 16:11:52.6294735	2018-12-19 16:28:34.8429525


insert into reserva_plaza (curso,num_reservas) 
	values ('curso6',13)
GO

SELECT * FROM [dbo].[reserva_plaza]
GO

--curso	num_reservas				SysStartTime				SysEndTime
--curso1	7						2018-12-19 16:14:09.8269896		9999-12-31 23:59:59.9999999
--curso2	12						2018-12-19 16:25:09.6972015		9999-12-31 23:59:59.9999999
--curso3	4						2018-12-19 16:11:52.6294735		9999-12-31 23:59:59.9999999
--curso4	2						2018-12-19 16:11:52.6294735		9999-12-31 23:59:59.9999999
--curso6	13						2018-12-19 16:30:35.4848348		9999-12-31 23:59:59.9999999



SELECT * FROM [dbo].[reserva_plaza_historico]
GO

--curso	num_reservas	SysStartTime	SysEndTime
--curso1	2	2018-12-19 16:11:52.6294735	2018-12-19 16:14:09.8269896
--curso2	1	2018-12-19 16:11:52.6294735	2018-12-19 16:19:59.6537074
--curso2	9	2018-12-19 16:19:59.6537074	2018-12-19 16:25:09.6972015
--curso5	6	2018-12-19 16:11:52.6294735	2018-12-19 16:28:34.8429525

delete from reserva_plaza 
	where curso='curso6'
GO

SELECT * FROM [dbo].[reserva_plaza]
GO

--curso	num_reservas	SysStartTime	SysEndTime
--curso1	7	2018-12-19 16:14:09.8269896	9999-12-31 23:59:59.9999999
--curso2	12	2018-12-19 16:25:09.6972015	9999-12-31 23:59:59.9999999
--curso3	4	2018-12-19 16:11:52.6294735	9999-12-31 23:59:59.9999999
--curso4	2	2018-12-19 16:11:52.6294735	9999-12-31 23:59:59.9999999



SELECT * FROM [dbo].[reserva_plaza_historico]
GO

--curso	num_reservas	SysStartTime	SysEndTime
--curso1	2	2018-12-19 16:11:52.6294735	2018-12-19 16:14:09.8269896
--curso2	1	2018-12-19 16:11:52.6294735	2018-12-19 16:19:59.6537074
--curso2	9	2018-12-19 16:19:59.6537074	2018-12-19 16:25:09.6972015
--curso5	6	2018-12-19 16:11:52.6294735	2018-12-19 16:28:34.8429525
--curso6	13	2018-12-19 16:30:35.4848348	2018-12-19 16:33:42.3019267




---------------------------------

--There is a new clause in SQL to do that: FOR SYSTEM_TIME. It has five sub-clauses:

--AS OF <date_time> – to get the actual values at the specified point in time
--FROM <start_date_time> TO <end_date_time> – to receive all row versions that were active within the specified time range not including values exactly matching the datetime boundaries
--BETWEEN <start_date_time> AND <end_date_time> – same as the previous one, except the values exactly matching the <end_date_time> boundary will be included
--CONTAINED IN (<start_date_time> , <end_date_time>) – will return records started and ended (closed) within the specified range including values exactly matching the datetime boundaries
--ALL – to get the union of rows belonging to the Temporal and the History Table

-------------------------------
--To perform any type of time-based analysis, use the new FOR SYSTEM_TIME clause with four temporal-specific sub-clauses to query data across the current and history tables. For more information on these clauses, see Temporal Tables and FROM (Transact-SQL)

--AS OF <date_time>

--FROM <start_date_time> TO <end_date_time>

--BETWEEN <start_date_time> AND <end_date_time>

--CONTAINED IN (<start_date_time> , <end_date_time>)

--ALL




-- Con “for system_time all” vemos todas las operaciones realizadas sobre la tabla

select * 
from dbo.reserva_plaza 
for system_time all 
go


--curso	num_reservas	SysStartTime	SysEndTime
--curso1	7	2018-12-19 16:14:09.8269896	9999-12-31 23:59:59.9999999
--curso2	12	2018-12-19 16:25:09.6972015	9999-12-31 23:59:59.9999999
--curso3	4	2018-12-19 16:11:52.6294735	9999-12-31 23:59:59.9999999
--curso4	2	2018-12-19 16:11:52.6294735	9999-12-31 23:59:59.9999999
--curso1	2	2018-12-19 16:11:52.6294735	2018-12-19 16:14:09.8269896
--curso2	1	2018-12-19 16:11:52.6294735	2018-12-19 16:19:59.6537074
--curso2	9	2018-12-19 16:19:59.6537074	2018-12-19 16:25:09.6972015
--curso5	6	2018-12-19 16:11:52.6294735	2018-12-19 16:28:34.8429525
--curso6	13	2018-12-19 16:30:35.4848348	2018-12-19 16:33:42.3019267

select * 
from [dbo].[reserva_plaza_historico]
for system_time all 
go


-- Msg 13544, Level 16, State 2, Line 234
--Temporal FOR SYSTEM_TIME clause can only be used with system-versioned tables. 'Colegio_Medico.dbo.reserva_plaza_historico' is not a system-versioned table.

SELECT * FROM [dbo].[reserva_plaza]
GO

--curso	num_reservas					SysStartTime							SysEndTime
--curso1	7							2018-12-19 16:14:09.8269896				9999-12-31 23:59:59.9999999
--curso2	12							2018-12-19 16:25:09.6972015				9999-12-31 23:59:59.9999999
--curso3	4							2018-12-19 16:11:52.6294735				9999-12-31 23:59:59.9999999
--curso4	2							2018-12-19 16:11:52.6294735				9999-12-31 23:59:59.9999999

SELECT * FROM [dbo].[reserva_plaza_historico]
GO

--curso	num_reservas				SysStartTime						SysEndTime
--curso1	2					2018-12-19 16:11:52.6294735		2018-12-19 16:14:09.8269896
--curso2	1					2018-12-19 16:11:52.6294735		2018-12-19 16:19:59.6537074
--curso2	9					2018-12-19 16:19:59.6537074		2018-12-19 16:25:09.6972015
--curso5	6					2018-12-19 16:11:52.6294735		2018-12-19 16:28:34.8429525
--curso6	13					2018-12-19 16:30:35.4848348		2018-12-19 16:33:42.3019267


-- Con “for system_time as of” vemos el estado de la tabla en un determinado punto en el tiempo.

select * 
from dbo.reserva_plaza 
for system_time as of '2018-12-19 16:11:52.6294735' 
go


--curso	num_reservas		SysStartTime								SysEndTime
--curso3	4				2018-12-19 16:11:52.6294735			9999-12-31 23:59:59.9999999
--curso4	2				2018-12-19 16:11:52.6294735			9999-12-31 23:59:59.9999999
--curso1	2				2018-12-19 16:11:52.6294735			2018-12-19 16:14:09.8269896
--curso2	1				2018-12-19 16:11:52.6294735			2018-12-19 16:19:59.6537074
--curso5	6				2018-12-19 16:11:52.6294735			2018-12-19 16:28:34.8429525


select * 
from dbo.reserva_plaza 
for system_time as of '2018-12-19 16:19:59.6537074' 
go

--curso	num_reservas	SysStartTime				SysEndTime
--curso1	7	2018-12-19 16:14:09.8269896			9999-12-31 23:59:59.9999999
--curso3	4	2018-12-19 16:11:52.6294735			9999-12-31 23:59:59.9999999
--curso4	2	2018-12-19 16:11:52.6294735			9999-12-31 23:59:59.9999999
--curso2	9	2018-12-19 16:19:59.6537074			2018-12-19 16:25:09.6972015
--curso5	6	2018-12-19 16:11:52.6294735			2018-12-19 16:28:34.8429525


select * 
from dbo.reserva_plaza 
for system_time as of '2018-12-19 16:25:09.6972015' 
go

--curso	num_reservas	SysStartTime				SysEndTime
--curso1	7	2018-12-19 16:14:09.8269896			9999-12-31 23:59:59.9999999
--curso2	12	2018-12-19 16:25:09.6972015			9999-12-31 23:59:59.9999999
--curso3	4	2018-12-19 16:11:52.6294735			9999-12-31 23:59:59.9999999
--curso4	2	2018-12-19 16:11:52.6294735			9999-12-31 23:59:59.9999999
--curso5	6	2018-12-19 16:11:52.6294735			2018-12-19 16:28:34.8429525


-- Con “for system_time from ‘fecha’ to ‘fecha’” vemos los cambios sufridos en la tabla en un rango de fechas

select * 
from reserva_plaza 
for system_time from '2018-02-24 10:13:48.5750487' to '2018-02-24 10:24:03.7897875' 
go


-- Between es similar al anterior pero toma referencia el SysStartTime

select * 
from reserva_plaza 
for system_time between '2018-02-24 10:13:48.5750487' and '2018-02-24 10:24:03.7897875'
GO

-- Con “for system_time contained in” se ven los registros que se introdujeron entre las 10:13 
-- y se cambiaron hasta las 10:21

select * 
from reserva_plaza 
for system_time contained in ('2018-02-24 10:13:48.5750487','2018-02-24 10:21:20.7110441')
GO



SELECT * FROM [dbo].[reserva_plaza]
GO


SELECT * FROM [dbo].[reserva_plaza_historico]
GO


-------------------------

--Limitation of Temporal Tables:

--1. Temporal querying over Linked Server is not supported.

--2. History table cannot have constraints (PK, FK, Table or Column constraints).

--3. INSERT and UPDATE statements cannot reference the SYSTEM_TIME period columns.

--4. TRUNCATE TABLE is not supported while SYSTEM_VERSIONING is ON

--5. Direct modification of the data in a history table is not permitted.

--6. INSTEAD OF triggers are not permitted on either the tables.

--7. Usage of Replication technologies is limited.





 
 