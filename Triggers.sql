--Triggers
--Se activan cuando ocurre una determinada accion. Son procedimientos de almacenado.
--Niveles=> 1.Servidor; 2.Base de Datos; 3.Tabla o Vista
	--3.Tabla o Vista=> Tipo After o Tipo Instead off


USE master
GO
DROP Trigger IF EXISTS trg_NoNuevoLogin
GO
--Deshabilitar nuevos logins en una instancia 
CREATE OR ALTER TRIGGER trg_NoNuevoLogin
ON ALL SERVER --SERVER LEVEL
FOR CREATE_LOGIN --Sentencia a controlar(puede haber mas de una)///CREATE_LOGIN es una palabra reservada en si, hay que mirar en la documentacion
AS
	PRINT 'No login creations without DBA involvement'
	ROLLBACK TRAN
GO

CREATE LOGIN Joe WITH PASSWORD='Abcd123.'
GO
--No login creations without DBA involvement
--Msg 3609, Level 16, State 2, Line 20
--The transaction ended in the trigger. The batch has been aborted.


--Buscar trigger en el Object Explorer=> Server Objects, Triggers



DISABLE Trigger ALL ON ALL SERVER;
GO
ENABLE Trigger ALL ON ALL SERVER;
GO
--Activar o desactivar Trigger


DROP Trigger trg_NoNuevoLogin
	ON ALL SERVER
GO
--Borrar Trigger




--TRIGGERS A NIVEL DE BASE DE DATOS

USE pubs
GO
IF OBJECT_ID ('Autores', 'U') IS NOT NULL
	DROP TABLE Autores;
GO
DROP TABLE IF EXISTS Autores
GO
SELECT * 
	INTO Autores
	FROM authors
GO
DROP TRIGGER IF EXISTS trg_PrevenirBorrado
GO
DISABLE TRIGGER trg_PrevenirBorrado ON Autores
GO
CREATE OR ALTER TRIGGER trg_PrevenirBorrado
ON DATABASE
FOR DROP_TABLE, ALTER_TABLE
AS
	RAISERROR('No se puede borrar o modificar tablas', 16, 3)
	ROLLBACK TRAN;
GO

DROP TABLE Autores
GO 
--Msg 50000, Level 16, State 3, Procedure trg_PrevenirBorrado, Line 5 [Batch Start Line 68]
--No se puede borrar o modificar tablas
--Msg 3609, Level 16, State 2, Line 69
--The transaction ended in the trigger. The batch has been aborted.



--TRIGER A NIVEL DE TABLA O VISTA

DROP TRIGGER IF EXISTS trg_DarAutor
GO
CREATE OR ALTER TRIGGER trg_DarAutor
ON Autores
AFTER INSERT, UPDATE --Si ponemos 'FOR' es un 'AFTER' <=Ambos hacen la misma funcion
AS
	RAISERROR(50009, 16, 10)
	EXEC sp_helpdb pubs
GO
--La accion de este trigger se realiza despues de la accion, TRIGGER AFTER
UPDATE Autores
	SET au_lname='Black'
	WHERE au_fname='Johnson';
GO
--Msg 18054, Level 16, State 1, Procedure trg_DarAutor, Line 5 [Batch Start Line 89]
--Error 50009, severity 16, state 10 was raised, but no message with that error number was found in sys.messages. 
--If error is larger than 50000, make sure the user-defined message is added using sp_addmessage.

--(1 row affected)

SELECT * FROM Autores;


DISABLE TRIGGER trg_DarAutor ON Autores
GO
ENABLE TRIGGER trg_DarAutor ON Autores;
GO
DROP TRIGGER trg_DarAutor
GO


--OTRO TIPO DE TRIGGER AFTER

CREATE OR ALTER TRIGGER trg_borra
ON Autores
FOR DELETE, UPDATE
AS
	RAISERROR('%d filas modificadas en la tabla Autores', 16, 1, @@rowcount)--El '%d' saca el numero que contiene '@@rowcount', mirar documentacion
GO

SELECT * FROM Autores
	WHERE au_fname='Johnson'
GO

DELETE Autores
	WHERE au_fname='Johnson'
GO
--Msg 50000, Level 16, State 1, Procedure trg_borra, Line 5 [Batch Start Line 123]
--1 filas modificadas en la tabla Autores
--(1 row affected)

SELECT * FROM Autores
	WHERE au_fname='Johnson'
GO
--El borrado se ha hecho correctamente porque ya no hay registros

DISABLE TRIGGER trg_borra ON Autores
GO
ENABLE TRIGGER trg_borra ON Autores
GO
DROP TRIGGER tgr_borra
GO

USE pubs
GO
--Trigger sobre una vista

CREATE OR ALTER VIEW vAutores
AS
	SELECT * FROM Autores
GO

CREATE OR ALTER TRIGGER trg_BorrarVista
ON vAutores
INSTEAD OF DELETE
AS
	PRINT 'No puedes borrar la vista'
GO

SELECT * FROM vAutores
GO

DELETE vAutores;
GO
--No puedes borrar la vista
--(22 rows affected)



--TRIGGER CON TABLAS TEMPORALES 'DELETED'e 'INSERTED'

USE pubs
GO

DROP TRIGGER IF EXISTS trg_TablasTemporales
GO
CREATE OR ALTER TRIGGER trg_TablasTemporales
ON Autores
AFTER UPDATE
AS
	PRINT 'Tabla inserted'
	SELECT * FROM inserted  --La tabla "inserted" es una tabla que crea el sistema cuando hay una insercion
	PRINT 'Tabla deleted'
	SELECT * FROM deleted --La tabla "deleted" es una tabla que crea el sistema cuando hay un borrado
	--Al haber un update se crean las dos tablas a la vez, "deleted" muestra el contenido anterior e "inserted" el contenido nuevo
	--Son tablas que solo se pueden consultar en el momento de la accion, despues no son accesibles porque se borran
GO

UPDATE Autores
SET au_lname='VERDE'
WHERE au_fname='Marjorie'
GO
--Tabla inserted
--213-46-8915	VERDE	Marjorie	415 986-7020	309 63rd St. #411	Oakland	CA	94618	1
--Tabla deleted
--213-46-8915	Green	Marjorie	415 986-7020	309 63rd St. #411	Oakland	CA	94618	1




