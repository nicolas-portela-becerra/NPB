
-- Create a “Last Modified” Column in SQL Server



USE tempdb
GO
CREATE TABLE dbo.Books (
	BookId int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	BookName nvarchar(1000) NOT NULL,
	CreateDate datetime DEFAULT CURRENT_TIMESTAMP,
	ModifiedDate datetime DEFAULT CURRENT_TIMESTAMP
);
GO

CREATE OR ALTER TRIGGER trg_Books_UpdateModifiedDate
ON dbo.Books
AFTER UPDATE
AS
	UPDATE dbo.Books
	SET ModifiedDate = CURRENT_TIMESTAMP
	WHERE BookId IN (SELECT DISTINCT BookId FROM inserted);
GO

INSERT INTO Books (BookName) 
VALUES ('Trigger Happy');
GO

SELECT * FROM Books;
GO

--BookId	BookName		CreateDate					ModifiedDate
--1			Trigger Happy	2021-02-18 22:05:29.467		2021-02-18 22:05:29.467
UPDATE Books 
SET BookName = 'Trigger Hippy'
WHERE BookId = 1;
GO

SELECT * FROM Books;
GO

--BookId	BookName			CreateDate						ModifiedDate
--1			Trigger Hippy	2021-02-18 22:05:29.467			2021-02-18 22:07:06.187


INSERT INTO Books (BookName)
VALUES ('Robin Hood');
GO
Select * FROM Books;
GO
--BookId BookName       CreateDate					ModifiedDate
--1		 Trigger Hippy	2021-02-18 22:05:29.467		2021-02-18 22:07:06.187
--2		 Robin Hood		2021-02-18 22:14:17.880		2021-02-18 22:14:17.880
UPDATE Books
SET BookName ='Robin Hoood'
WHERE BookId = 2;
GO
SELECT * FROM Books
GO
--BookId BookName       CreateDate					ModifiedDate
--1		Trigger Hippy	2021-02-18 22:05:29.467	2021-02-18 22:07:06.187
--2		Robin Hoood		2021-02-18 22:14:17.880	2021-02-18 22:16:17.507




USE pubs
GO

DROP TABLE IF EXISTS Autores
GO
SELECT * 
	INTO autores
	FROM authors
GO

DROP TRIGGER IF EXISTS trg_actualizar_ciudad
GO
CREATE OR ALTER TRIGGER trg_actualizar_ciudad
ON Autores
FOR UPDATE
AS
	IF UPDATE(city)
		BEGIN
			RAISERROR('No puedes actualizar la ciudad', 15,1)
			ROLLBACK TRAN
		END
	ELSE
		PRINT 'Operación correcta'
GO

SELECT * FROM AUTORES
GO

UPDATE autores
SET au_lname='Blanco'
WHERE au_fname='Johnson'
GO
--Operación correcta
--(1 row affected)

Select * FROM autores
GO
--172-32-1176	Blanco	Johnson	408 496-7223	10932 Bigge Rd.	Menlo Park	CA	94025	1

UPDATE autores
SET city='A Coruña'
WHERE city='Menlo Park'
GO
--Msg 50000, Level 15, State 1, Procedure trg_actualizar_ciudad, Line 7 [Batch Start Line 105]
--No puedes actualizar la ciudad
--Msg 3609, Level 16, State 1, Line 106
--The transaction ended in the trigger. The batch has been aborted.
			 
UPDATE autores
SET city='A Coruña'
WHERE au_fname='Johnson'
GO
--Msg 50000, Level 15, State 1, Procedure trg_actualizar_ciudad, Line 7 [Batch Start Line 114]
--No puedes actualizar la ciudad
--Msg 3609, Level 16, State 1, Line 115
--The transaction ended in the trigger. The batch has been aborted.

--NO DEJA HACER LOS UPDATE DONDE EL SET VAYA AL CAMPO city DEBIDO AL TRIGGER.





USE AdventureWorks2017
GO

SELECT * 
	INTO DEPARTAMENTO
	FROM HumanResources.Department
GO
SELECT * FROM DEPARTAMENTO
GO

--Creacion del TRIGGER
DROP TRIGGER IF EXISTS trg_borrado_GroupName
GO
CREATE OR ALTER TRIGGER trg_borrado_GroupName
ON DEPARTAMENTO
FOR UPDATE 
AS
	IF UPDATE (GroupName)
		BEGIN
			RAISERROR('Solo DBA puede cambiar el nombre', 15,1)
			ROLLBACK TRAN
		END
	ELSE
		PRINT 'Operación correcta'
GO

Select * FROM DEPARTAMENTO
GO

UPDATE DEPARTAMENTO
	SET GroupName='Investigación y Desarrollo'
	WHERE GroupName='Research and Development'
GO
--Msg 50000, Level 15, State 1, Procedure trg_borrado_GroupName, Line 7 [Batch Start Line 158]
--Solo DBA puede cambiar el nombre
--Msg 3609, Level 16, State 1, Line 159
--The transaction ended in the trigger. The batch has been aborted.




USE Northwind
GO

DROP TABLE IF EXISTS empleados
GO
SELECT * 
	INTO empleados
	FROM employees
GO
SELECT * FROM empleados
GO

DROP TRIGGER IF EXISTS trg_SoloBorrarUno
GO
CREATE OR ALTER TRIGGER trg_SoloBorrarUno
ON empleados
FOR DELETE
AS
	IF (@@ROWCOUNT>1)
		BEGIN
			RAISERROR('No puedes borrar más de un registro',15,1)
			ROLLBACK TRAN
		END
	ELSE
		PRINT 'Operación correcta'
GO

SELECT * FROM empleados
GO

DELETE empleados
GO
--Msg 50000, Level 15, State 1, Procedure trg_SoloBorrarUno, Line 7 [Batch Start Line 200]
--No puedes borrar más de un registro
--Msg 3609, Level 16, State 1, Line 201
--The transaction ended in the trigger. The batch has been aborted.

DELETE empleados
WHERE EmployeeID=1
GO
--Operación correcta
--(1 row affected)

USE Northwind
GO

--OTRA SOLUCION AL TRIGGER DE ANTES
DROP TRIGGER IF EXISTS trg_SoloBorrarIndividual
GO
CREATE OR ALTER TRIGGER trg_SoloBorrarIndividual
ON empleados
FOR DELETE
AS
	IF (SELECT COUNT(*) FROM DELETED) > 1
		BEGIN
			RAISERROR('No puedes borrar más de un registro',15,1)
			ROLLBACK TRAN
		END
	ELSE
		PRINT 'Operación correcta'
GO

SELECT * FROM empleados
GO
delete Empleados
where EmployeeID>5;
--Msg 50000, Level 15, State 1, Procedure trg_SoloBorrarUno, Line 7 [Batch Start Line 234]
--No puedes borrar más de un registro
--Msg 3609, Level 16, State 1, Line 235
--The transaction ended in the trigger. The batch has been aborted.


--OTRA VARIANTE MAS AL TRIGGER DE SOLO BORRAR UNO
--@@ROWCOUNT & @@TRANCOUNT
--@@TRANCOUNT Cuenta el numero de transacciones activas
--@@ROWCOUNT Cuenta el numero de filas

USE AdventureWorks2017
GO
DROP TABLE IF EXISTS EMPLEADOS
GO
SELECT *
INTO EMPLEADOS
FROM HumanResources.Employee
GO
SELECT * FROM EMPLEADOS
GO

--CREACION DE TRIGGER
CREATE OR ALTER TRIGGER trg_NoBorrarEmpleados
ON EMPLEADOS
INSTEAD OF DELETE
AS 
BEGIN
	DECLARE @Count = @@ROWCOUNT;
	IF @Count = 0
		RETURN;
	BEGIN
		RAISERROR
			('Employees cannot be deleted. They can only be marked as not current.',10,1)

		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION
		END
	END;
END;
GO




USE AdventureWorks2017
GO

DROP TABLE IF EXISTS Person.Direcciones
GO
SELECT [AddressLine1], [City], [StateProvinceID], [PostalCode]
	INTO Person.Direcciones
	FROM Person.Address
GO
SELECT * FROM Person.Direcciones
GO

DROP TRIGGER IF EXISTS tr_Direcciones
GO
CREATE OR ALTER TRIGGER tr_Direcciones
ON Person.Direcciones
INSTEAD OF INSERT
AS
BEGIN
		IF EXISTS
				(
				SELECT AddressLine1
				FROM Inserted
				WHERE RIGHT(AddressLine1, 3)='Ave'
				)
				--WHERE RIGHT(AddressLine1, 3) = 'Ave'
				--Esta linea comprueba si las tres primeras letras desde la derecha del campo AddressLine1 es Ave, 
				--para reemplazarlo despues con el trigger

				INSERT INTO Person.Direcciones
						(AddressLine1, City, StateProvinceID, PostalCode)
						SELECT REPLACE (AddressLine1, 'Ave', 'Avenue'), City, StateProvinceID, PostalCode
						FROM Inserted;
		ELSE
				INSERT INTO Person.Direcciones
						(AddressLine1, City, StateProvinceID, PostalCode)
						SELECT AddressLine1, City, StateProvinceID, PostalCode
						FROM Inserted;
END
GO

INSERT INTO Person.Direcciones
	(AddressLine1, City, StateProvinceID, PostalCode)
	VALUES('Honduras Ave', 'city3', 79, '33333')
GO
--(1 row affected)
--(1 row affected)
SELECT AddressLine1
	FROM Person.Direcciones
	WHERE PostalCode = '33333';
GO
--AdressLine1
--Honduras Avenue
--El trigger cambia la insercion, donde pone 'Ave' lo cambia por 'Avenue'


INSERT INTO Person.Direcciones
	(AddressLine1, City, StateProvinceID, PostalCode)
	VALUES('Honduras Avenida', 'city3', 79, '33333')
GO
--(1 row affected)
--(1 row affected)
SELECT AddressLine1
	FROM Person.Direcciones
	WHERE PostalCode = '33333';
GO
--AdressLine1
--Honduras Avenida
--Ahora no cambia la entrada porque no detecta 'Ave'en la inserción



--CONTROLAR EXISTENCIAS DE LA TABLA PRODUCTOS SEGUN LOS PEDIDOS
DROP DATABASE IF EXISTS Almacen
GO
CREATE DATABASE Almacen
GO
USE Almacen
GO

---------------------------------------
DROP TABLE IF EXISTS Productos
GO
DROP TABLE IF EXISTS Pedidos
GO

sp_helpconstraint Productos
GO
sp_helpconstraint Pedidos
GO

ALTER TABLE Pedidos
	NOCHECK CONSTRAINT Pk_Id_Producto
GO

ALTER TABLE Pedidos
	CHECK CONSTRAINT Pk_Id_Producto
GO
---------------------------------------

DROP TABLE IF EXISTS Productos
GO
CREATE TABLE Productos
(
	Id_Producto CHAR(8) PRIMARY KEY NOT NULL,
	NombreProducto VARCHAR(25) NOT NULL,
	Existencia INT NULL,
	Precio Decimal (10,2) NOT NULL,
	PrecioVenta Decimal (10,2)
)
GO

DROP TABLE IF EXISTS Pedidos
GO
CREATE TABLE Pedidos
(
	Id_Pedido INT IDENTITY,
	Id_Producto CHAR(8) NOT NULL,
	Cantidad_Pedido INT 
	CONSTRAINT Pk_Id_Producto FOREIGN KEY(Id_Producto)
	REFERENCES Productos (Id_Producto)
)
GO

INSERT INTO Productos VALUES ('P001', 'Filtros Pantalla', 5, 10, 12.5)
INSERT INTO Productos VALUES ('P002', 'Teclados', 7, 10, 11.5)
INSERT INTO Productos VALUES ('P003', 'Mouse', 8, 4.5, 6)
GO
SELECT * FROM Productos
	ORDER BY Id_Producto
GO
--Id_Producto NombreProducto    Existencias Precio  PrecioVenta
--P001    	  Filtros Pantalla	5	        10.00	12.50
--P002    	  Teclados	        7	        10.00	11.50
--P003    	  Mouse	            8	        4.50	6.00


--Tigger
--Insertar en Pedidos y descontar en Productos
DROP TRIGGER IF EXISTS Trg_Pedido_Articulos
GO
CREATE OR ALTER TRIGGER Trg_Pedido_Articulos
ON Pedidos
FOR INSERT
AS
	UPDATE Productos
	SET Existencia = Existencia-(SELECT Cantidad_Pedido FROM Inserted)
	WHERE Id_Producto = (SELECT Id_Producto FROM Inserted)
GO


--DEMOSTRACION SOBRE 'P003'

--Insertar pedido
INSERT INTO Pedidos
	VALUES ('P003', 5)
GO
--(1 row affected)
--(1 row affected)

SELECT * FROM Productos 
	WHERE Id_Producto = 'P003'
GO
--P003    	Mouse	3	4.50	6.00
--Las existencias bajaron de 8 a 3 porque el pedido fue de 5 unidades

USE Almacen
GO
--PROBAR FUNCIONAMIENTO DE LA INTEGRIDAD REFERENCIAL
INSERT INTO Pedidos
	VALUES('P033',5)
GO
--Msg 547, Level 16, State 0, Line 452
--The INSERT statement conflicted with the FOREIGN KEY constraint "Pk_Id_Producto". 
--The conflict occurred in database "Almacen", table "dbo.Productos", column 'Id_Producto'.
--The statement has been terminated.
--NO DEJA HACER LA INSERCION PORQUE SE ESTA HACIENDO REFERENCIA A UNA PK QUE NO EXISTE



--CONTROLAR SI HAY SUFICIENTES EXISTENCIAS PARA UN PEDIDO
DROP TRIGGER IF EXISTS Trg_Control_Existencias
GO
CREATE OR ALTER TRIGGER Trg_Control_Existencias
ON Pedidos
FOR INSERT
AS
	DECLARE @Existencias INT --DECLARO LA VARIBLE
	SELECT @Existencias=Existencia --LE ASIGNO EL VALOR A LA VARIABLE
		FROM Productos
		WHERE Id_Producto = (Select Id_Producto FROM inserted)

	IF @Existencias<(SELECT Cantidad_Pedido FROM inserted)
		BEGIN
			RAISERROR('No hay suficientes existencias', 16, 1);
			RETURN
		END

	ELSE
		BEGIN
			UPDATE Productos
			SET Existencia=Existencia-(SELECT Cantidad_Pedido FROM inserted)
			WHERE Id_Producto=(SELECT Id_Producto FROM inserted)
		END
GO

SELECT * FROM Productos
GO
--P001    	Filtros Pantalla	5	10.00	12.50
--P002    	Teclados	7	10.00	11.50
--P003    	Mouse	3	4.50	6.00

INSERT INTO Pedidos
	VALUES('P001', 6)
GO
--(1 row affected)
--Msg 50000, Level 16, State 1, Procedure Trg_Control_Existencias, Line 12 [Batch Start Line 494]
--No hay suficientes existencias

SELECT * FROM Productos
GO
--P001    	Filtros Pantalla	-1	10.00	12.50
--P002    	Teclados	7	10.00	11.50
--P003    	Mouse	3	4.50	6.00
--EL TRIGGER ESTA MAL, HABRIA QUE AÑADIR "ROLLBACK TRAN" PORQUE SINO EJECUTA LA ACCION IGUALMENTE 
--AUNQUE SALTE EL MENSAJE DE ERROR

SELECT * FROM Pedidos
GO
DELETE Pedidos
	WHERE Id_Pedido=5
GO

CREATE OR ALTER TRIGGER Trg_Control_Existencias
ON Pedidos
FOR INSERT
AS
	DECLARE @Existencias INT --DECLARO LA VARIBLE
	SELECT @Existencias=Existencia --LE ASIGNO EL VALOR A LA VARIABLE
		FROM Productos
		WHERE Id_Producto = (Select Id_Producto FROM inserted)

	IF @Existencias<(SELECT Cantidad_Pedido FROM inserted)
		BEGIN
			RAISERROR('No hay suficientes existencias', 16, 1);
			ROLLBACK TRAN --Con esto el trigger funciona correctamente
			RETURN
		END

	ELSE
		BEGIN
			UPDATE Productos
			SET Existencia=Existencia-(SELECT Cantidad_Pedido FROM inserted)
			WHERE Id_Producto=(SELECT Id_Producto FROM inserted)
		END
GO

SELECT * FROM Productos
GO
INSERT INTO Pedidos
	VALUES('P003', 4)
GO
--(3 rows affected)
--(1 row affected)
--Msg 50000, Level 16, State 1, Procedure Trg_Control_Existencias, Line 12 [Batch Start Line 541]
--No hay suficientes existencias
--Msg 3609, Level 16, State 1, Line 542
--The transaction ended in the trigger. The batch has been aborted.
--AHORA SI SE ABORTA LA TRANSACCION Y NO HAY PEDIDO
SELECT * FROM Productos
GO
--P001    	Filtros Pantalla	-1	 10.00	 12.50
--P002    	Teclados	         7	 10.00	 11.50
--P003    	Mouse	             3	 4.50	 6.00
--Sigue habiendo 3 Ratones porque no se ejecuto el pedido


----------------------------------------------------------------------------------------------------




--EMULAR TABLA TEMPORAL MEDIANTE TRIGGERS

--GETDATE() and GETUTCDATE()

--The difference between GETDATE() and GETUTCDATE() is in timezone, the GETDATE() function return current date and time in the local timezone, 

--the timezone where your database server is running, but GETUTCDATE() return current time and date in UTC (Universal Time Coordinate) or GMT timezone.


print GETDATE()
go

-- Mar  9 2021  9:25PM

print GETUTCDATE()
go

-- Mar  9 2021  8:25PM

print SYSUTCDATETIME()
go

-- 2021-03-09 20:26:54.0182276



--------------
--SYSUTCDATETIME 


--Devuelve un valor datetime2 que contiene la fecha y hora del equipo en el que
--  la instancia de SQL Server se está ejecutando. La fecha y hora se devuelven como una hora universal coordinada (UTC). La especificación de precisión de fracción de segundo tiene un intervalo de 1 a 7 dígitos. La precisión predeterminada es 7 dígitos.


----------------------------------

DROP DATABASE IF EXISTS TemporalTable_Trigger
GO
CREATE DATABASE TemporalTable_Trigger
GO
USE TemporalTable_Trigger
GO

DROP TABLE IF EXISTS Birds
GO
CREATE TABLE dbo.Birds  
(   
 Id INT IDENTITY PRIMARY KEY,
 BirdName varchar(50),
 SightingCount int,
 SysStartTime datetime2 DEFAULT SYSUTCDATETIME(),
 SysEndTime datetime2 DEFAULT '9999-12-31 23:59:59.9999999'  
);
GO

DROP TABLE IF EXISTS BirdsHistory
GO
CREATE TABLE dbo.BirdsHistory
(   
 Id int,
 BirdName varchar(50),
 SightingCount int,
 SysStartTime datetime2,
 SysEndTime datetime2  
) WITH (DATA_COMPRESSION = PAGE);
GO


CREATE CLUSTERED INDEX CL_Id ON dbo.BirdsHistory (Id);
GO

-- Trigger

CREATE OR ALTER TRIGGER TemporalFaking 
	ON dbo.Birds
			AFTER UPDATE, DELETE
AS
BEGIN
SET NOCOUNT ON;

DECLARE @CurrentDateTime datetime2 = SYSUTCDATETIME();--Declara la variable con el valor de SYSUTCDATETIME
PRINT SYSUTCDATETIME()
/* Update start times for newly updated data */
UPDATE b--Aqui esta haciendo referencia a la tabla Birds, b es su alias en el trigger, lo define mas abajo
SET
       SysStartTime = @CurrentDateTime--Actualiza la fecha en la tabla Birds
FROM
    dbo.Birds b--Hace que Birds sea b para optimizar la escritura
    INNER JOIN inserted i--Hace una innerjoin con la tabla inserted que hace que sea i
        ON b.Id = i.Id --Iguala ambos Id de las tablas
		--Si se intenta insertar algo en la tabla y coincide actualiza SysStartTime

/* Grab the SysStartTime from dbo.Birds
   Insert into dbo.BirdsHistory */
INSERT INTO dbo.BirdsHistory
SELECT d.Id, d.BirdName, d.SightingCount,d.SysStartTime,ISNULL(b.SysStartTime,@CurrentDateTime)--ISNULL deja un blanco
FROM
       dbo.Birds b
       RIGHT JOIN deleted d--Asigna d a Deleted
              ON b.Id = d.Id
END
--Mete toda la informacion de la tabla Birds en BirdsHistory cuando algo se va a borrar en la tabla Birds 
GO

-----------------------------------------------
SELECT * FROM Birds
GO

SELECT * FROM BirdsHistory
GO
-------------------------------------------------
SELECT * FROM Birds
GO
-- (0 rows affected)

SELECT * FROM BirdsHistory
GO
-- (0 rows affected)


-- TRIGGER    TABLE BIRDS AFTER UPDATE, DELETE

/* inserts */
INSERT INTO dbo.Birds (BirdName, SightingCount) VALUES ('Blue Jay',1);
GO
INSERT INTO dbo.Birds (BirdName, SightingCount) VALUES ('Cardinal',1);
GO
SELECT * FROM Birds
GO
--Id	BirdName	SightingCount	SysStartTime						SysEndTime
--1	Blue Jay	1	2021-03-09 21:07:22.4525250	9999-12-31 23:59:59.9999999
--2	Cardinal	1	2021-03-09 21:07:22.4669662	9999-12-31 23:59:59.9999999
SELECT * FROM BirdsHistory
GO
-- (0 rows affected)

BEGIN TRANSACTION
	INSERT INTO dbo.Birds (BirdName, SightingCount) VALUES ('Canada Goose',1)
	INSERT INTO dbo.Birds (BirdName, SightingCount) VALUES ('Nuthatch',1)
COMMIT
GO
SELECT * FROM Birds
GO
--Id	BirdName	SightingCount	     SysStartTime					SysEndTime
--1	Blue Jay	     1	             2021-03-09 21:07:22.4525250	9999-12-31 23:59:59.9999999
--2	Cardinal	     1	             2021-03-09 21:07:22.4669662	9999-12-31 23:59:59.9999999
--3	Canada Goose	 1	             2021-03-09 21:07:48.1825536	9999-12-31 23:59:59.9999999
--4	Nuthatch	     1	             2021-03-09 21:07:48.1825536	9999-12-31 23:59:59.9999999

SELECT * FROM BirdsHistory
GO
-- (0 rows affected)

BEGIN TRANSACTION
	INSERT INTO dbo.Birds (BirdName, SightingCount) VALUES ('Dodo',1)
	INSERT INTO dbo.Birds (BirdName, SightingCount) VALUES ('Ivory Billed Woodpecker',1)
ROLLBACK
GO

SELECT * FROM Birds
GO
--Id	BirdName	SightingCount			SysStartTime						SysEndTime
--1	Blue Jay	        1	              2021-03-09 21:07:22.4525250	  9999-12-31 23:59:59.9999999
--2	Cardinal	        1	              2021-03-09 21:07:22.4669662	  9999-12-31 23:59:59.9999999
--3	Canada Goose	    1	              2021-03-09 21:07:48.1825536	  9999-12-31 23:59:59.9999999
--4	Nuthatch	        1	              2021-03-09 21:07:48.1825536	  9999-12-31 23:59:59.9999999
SELECT * FROM BirdsHistory
GO
-- (0 rows affected)

/* updates */
UPDATE dbo.Birds SET SightingCount = SightingCount+1 WHERE id = 1;
GO
UPDATE dbo.Birds SET SightingCount = SightingCount+1 WHERE id in (2,3);
GO

SELECT * FROM Birds
GO

--Id	BirdName	SightingCount			SysStartTime					SysEndTime
--1	Blue Jay	         2	            2021-03-09 21:09:49.3223593	    9999-12-31 23:59:59.9999999
--2	Cardinal	         2	            2021-03-09 21:09:49.3287120	    9999-12-31 23:59:59.9999999
--3	Canada Goose	     2	            2021-03-09 21:09:49.3287120	    9999-12-31 23:59:59.9999999
--4	Nuthatch	         1	            2021-03-09 21:07:48.1825536	    9999-12-31 23:59:59.9999999


SELECT * FROM BirdsHistory
GO

--Id	BirdName	SightingCount			SysStartTime					SysEndTime
--1	Blue Jay	       1	         2021-03-09 21:07:22.4525250	2021-03-09 21:09:49.3223593
--2	Cardinal	       1	         2021-03-09 21:07:22.4669662	2021-03-09 21:09:49.3287120
--3	Canada Goose	   1	         2021-03-09 21:07:48.1825536	2021-03-09 21:09:49.3287120

BEGIN TRANSACTION
UPDATE dbo.Birds SET SightingCount = SightingCount+1 WHERE id =4;
GO
ROLLBACK

SELECT * FROM Birds
GO

--Id	BirdName	SightingCount	   SysStartTime	              SysEndTime
--1	Blue Jay	         2	       2021-03-09 21:09:49.3223593	  9999-12-31 23:59:59.9999999
--2	Cardinal	         2	       2021-03-09 21:09:49.3287120	  9999-12-31 23:59:59.9999999
--3	Canada Goose	     2	       2021-03-09 21:09:49.3287120	  9999-12-31 23:59:59.9999999
--4	Nuthatch	         1	       2021-03-09 21:07:48.1825536	  9999-12-31 23:59:59.9999999
SELECT * FROM BirdsHistory
GO

--Id	BirdName	SightingCount			SysStartTime				SysEndTime
--1	Blue Jay	        1	          2021-03-09 21:07:22.4525250	  2021-03-09 21:09:49.3223593
--2	Cardinal	        1	          2021-03-09 21:07:22.4669662	  2021-03-09 21:09:49.3287120
--3	Canada Goose	    1	          2021-03-09 21:07:48.1825536	  2021-03-09 21:09:49.3287120


/* deletes */

DELETE FROM dbo.Birds WHERE id = 1;
GO
DELETE FROM dbo.Birds WHERE id in (2,3);
GO

SELECT * FROM Birds
GO

--Id	BirdName	SightingCount			SysStartTime						SysEndTime
--4	Nuthatch	      1	               2021-03-09 21:07:48.1825536	      9999-12-31 23:59:59.9999999

SELECT * FROM BirdsHistory
GO

--Id	BirdName	SightingCount				SysStartTime					SysEndTime
--1	Blue Jay	          1	                 2021-03-09 21:07:22.4525250	2021-03-09 21:09:49.3223593
--1	Blue Jay	          2	                 2021-03-09 21:09:49.3223593	2021-03-09 21:12:19.3284339
--2	Cardinal	          1	                 2021-03-09 21:07:22.4669662	2021-03-09 21:09:49.3287120
--2	Cardinal	          2	                 2021-03-09 21:09:49.3287120	2021-03-09 21:12:19.3446934
--3	Canada Goose	      1	                 2021-03-09 21:07:48.1825536	2021-03-09 21:09:49.3287120
--3	Canada Goose	      2	                 2021-03-09 21:09:49.3287120	2021-03-09 21:12:19.3446934

BEGIN TRANSACTION
DELETE FROM dbo.Birds WHERE id =4;
GO
ROLLBACK
 
SELECT * FROM Birds
GO
--Id	BirdName	SightingCount	SysStartTime							SysEndTime
--4	Nuthatch	          1	         2021-03-09 21:07:48.1825536	9999-12-31 23:59:59.9999999
SELECT * FROM BirdsHistory
GO
--Id	BirdName	SightingCount				SysStartTime		SysEndTime
--1	Blue Jay	           1	      2021-03-09 21:07:22.4525250	2021-03-09 21:09:49.3223593
--1	Blue Jay	           2	      2021-03-09 21:09:49.3223593	2021-03-09 21:12:19.3284339
--2	Cardinal	           1	      2021-03-09 21:07:22.4669662	2021-03-09 21:09:49.3287120
--2	Cardinal	           2	      2021-03-09 21:09:49.3287120	2021-03-09 21:12:19.3446934
--3	Canada Goose	       1	      2021-03-09 21:07:48.1825536	2021-03-09 21:09:49.3287120
--3	Canada Goose	       2	      2021-03-09 21:09:49.3287120	2021-03-09 21:12:19.3446934


-- Now seeing what our dbo.Birds data looked like at a certain point-in-time isn’t quite 
-- as easy as a system versioned table in SQL Server 2016, but it’s not bad:
--SEGUIR DESDE AQUI
DECLARE @SYSTEM_TIME datetime2 = '2021-02-01 19:55:53.128014';
SELECT * 
FROM
	(
	SELECT * FROM dbo.Birds
	UNION ALL
	SELECT * FROM dbo.BirdsHistory
	) FakeTemporal
WHERE 
	@SYSTEM_TIME >= SysStartTime 
	AND @SYSTEM_TIME < SysEndTime;
GO

--Id	BirdName	SightingCount	SysStartTime	SysEndTime
--1	Blue Jay	1	2021-02-01 19:55:53.1280143	2021-02-01 20:01:55.3920048

DECLARE @SYSTEM_TIME datetime2 = '2021-02-01 20:01:55.4756823';
SELECT * 
FROM
	(
	SELECT * FROM dbo.Birds
	UNION ALL
	SELECT * FROM dbo.BirdsHistory
	) FakeTemporal
WHERE 
	@SYSTEM_TIME >= SysStartTime 
	AND @SYSTEM_TIME < SysEndTime;
GO

SELECT * FROM dbo.Birds
	UNION ALL
SELECT * FROM dbo.BirdsHistory
GO
--Id	BirdName		SightingCount		SysStartTime					SysEndTime
--4	Nuthatch				1		2021-02-01 19:57:53.3654352			9999-12-31 23:59:59.9999999
--1	Blue Jay				1		2021-02-01 19:55:53.1280143			2021-02-01 20:01:55.3920048
--1	Blue Jay				2		2021-02-01 20:01:55.3920048			2021-02-01 20:07:17.4070381
--2	Cardinal				1		2021-02-01 19:55:53.1519945			2021-02-01 20:01:55.4756823
--2	Cardinal				2		2021-02-01 20:01:55.4756823			2021-02-01 20:07:17.4179717
--3	Canada Goose			1		2021-02-01 19:57:53.3654352			2021-02-01 20:01:55.4756823
--3	Canada Goose			2		2021-02-01 20:01:55.4756823			2021-02-01 20:07:17.4179717

--WHERE 
--	@SYSTEM_TIME >= SysStartTime 
--	AND @SYSTEM_TIME < SysEndTime;

-- @SYSTEM_TIME = '2021-02-01 20:01:55.4756823'


--Id	BirdName	SightingCount			SysStartTime				SysEndTime
--4	Nuthatch			1			2021-02-01 19:57:53.3654352		9999-12-31 23:59:59.9999999
--1	Blue Jay			2			2021-02-01 20:01:55.3920048		2021-02-01 20:07:17.4070381
--2	Cardinal			2			2021-02-01 20:01:55.4756823		2021-02-01 20:07:17.4179717
--3	Canada Goose		2			2021-02-01 20:01:55.4756823		2021-02-01 20:07:17.4179717


-- the trigger based version is almost the same as a real system versioned temporal table.


---------------------------------------
-- NOTA : ISNULL

-- Finds the average of the weight of all products.
-- It substitutes the value 50 for all NULL entries in the Weight column of the Product table.


USE AdventureWorks2017;  
GO 
SELECT AVG(WeighT)  
FROM Production.Product;  
GO
-- 74.069219
SELECT Weight
FROM Production.Product; 
GO
-- (504 rows affected)
SELECT ISNULL(Weight, 50)  
FROM Production.Product;  
GO 
-- (504 rows affected)
SELECT AVG(ISNULL(Weight, 50))  
FROM Production.Product;  
GO  
-- 59.790059







