--OWNERSHIP CHAINING

drop database if exists TestDB;
go
create database TestDB;
go
use TestDB;
go

drop schema if exists HR
go 
create schema HR;
go

drop table if exists HR.Employee
go
create table HR.Employee
(
	EmployeeID INT,
	GivenName varchar(50),
	Surname varchar(50),
	SSNN char(9) --No queremos que los Becarios vean este campo
);
go
select * from HR.Employee
go

--1	Luis	Arias	11       
--2	Ana	Perez	22       
--3	Pepe	Gomez	333

drop view if exists HR.LookUpEmployee
go
create view HR.LookUpEmployee
as 
select
	EmployeeID, GivenName, Surname
from HR.Employee;
go
Select * from HR.LookUpEmployee
go

drop role if exists HumanResourcesAnalyst
go
create role HumanResourcesAnalyst
go

grant select on HR.LookUpEmployee to HumanResourcesAnalyst;
go

drop user if exists JaneDoe
go
create user JaneDoe without login;
go

Alter role HumanResourcesAnalyst
	add member JaneDoe
go

--JaneDoe tiene permiso para ver la vista HR.LookUpEmployee
--Pero no puede ver la tabla directamente
--Lo demostramos impersonando a JaneDoe

Execute as user ='JaneDoe';
GO

PRINT USER
GO
--JaneDoE

Select * from HR.LookUpEmployee
GO
--1	Luis	Arias
--2	Ana	Perez
--3	Pepe	Gomez
--1	Luis	Arias
--2	Ana	Gomez
--3	Juan	Perez

Select * from HR.Employee
GO
--Msg 229, Level 14, State 5, Line 80
--The SELECT permission was denied on the object 'Employee', database 'TestDB', schema 'HR'.
--No puede consultar la tabla porque no tiene permiso para ello, pero si puede consultar la tabla utilizando la vista

REVERT;
GO
--Sirve para salir de la impersonacion
PRINT USER;
--dbo

---------------------------------------------------------
--PROCEDIMIENTO DE ALMACENADO

Create or alter PROC HR.InsertNewEmployee
	--Parametros de Entrada
	@EmployeeID int, 
	@GivenName varchar(50),
	@SurName varchar(50),
	@SSN CHAR(9)
AS
BEGIN
	Insert into HR.Employee
	(EmployeeID, GivenName, Surname, SSNN)
	Values
	(@EmployeeID, @GivenName, @Surname, @SSN);
END;
GO
------------------------------------------------------

CREATE ROLE	HumanResourcesRecruiter;
GO
Grant execute on schema::[HR] to HumanResourcesRecruiter;
GO

Create user JohnSmith without login;
GO

Alter role HumanResourcesRecruiter
add member JohnSmith
GO

EXECUTE AS USER ='JohnSmith';
GO
PRINT USER;
GO
--JohnSmith

INSERT INTO HR.Employee
	(EmployeeID, GivenName, Surname, SSNN)
	VALUES 
	(4, 'Miguel', 'Martinez', '444');
GO
--Msg 229, Level 14, State 5, Line 129
--The INSERT permission was denied on the object 'Employee', database 'TestDB', schema 'HR'.
--No puede hacer insercion porque no tiene permisos para ello
--Ahora mediante el proceso de almacenado sobre el que tiene permiso el ROLE podra hacer la insercion

EXEC HR.InsertNewEmployee
	@EmployeeID = 4,
	@GivenName = 'Miguel',
	@SurName = 'Martinez',
	@SSN = '444'
GO
--(1 row affected)

Select * from HR.Employee
GO
--Msg 229, Level 14, State 5, Line 147
--The SELECT permission was denied on the object 'Employee', database 'TestDB', schema 'HR'.
--NO PUEDE HACER LA SELECT * PORQUE NO TIENE PERMISO

REVERT
GO

Select * from HR.Employee
GO
--1	Luis	Arias	11       
--2	Ana	Perez	22       
--3	Pepe	Gomez	333      
--4	Miguel	Martinez	444    
--LA INSERCION DE JOHNSMITH SE HA REALIZADO PORQUE SU ROLE LE PERMITE ACCEDER AL PROCEMIENTO DE ALMACENADO
--QUE INSERTA VALORES EN LA TABLA
  