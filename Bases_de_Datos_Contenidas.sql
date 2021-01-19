--Base de Datos contenidas

USE master
GO

--1º Activar opciones avanzadas
EXEC SP_CONFIGURE 'show advanced options', 1
GO
--Actualizamos el valor
RECONFIGURE
GO


--Activar la caracteristica
EXEC SP_CONFIGURE 'contained database authentication', 1
GO
--Configuration option 'contained database authentication' changed from 0 to 1. Run the RECONFIGURE statement to install.
--Actualizar de nuevo
RECONFIGURE 
GO
--Commands completed successfully.

--Hasta aqui es la preparacion del entorno


DROP DATABASE IF EXISTS Contenida_Nicolas_Portela
GO
CREATE DATABASE Contenida_Nicolas_Portela
CONTAINMENT=PARTIAL
GO

--Una vez creada la BD la activamos
USE Contenida_Nicolas_Portela
GO

--Crear usuario con en esquema dbo
DROP USER IF EXISTS NPB
GO
CREATE USER NPB
	WITH PASSWORD='abcd123',
	DEFAULT_SCHEMA=[dbo]
GO

--Añadir al usuario NPB al ROLE db_owner
ALTER ROLE db_owner
	ADD MEMBER NPB
GO
--EXEC SP_ADDROLEMEMBER 'db_owner', 'juan'  <-- Mejor no usar esta version, esta "deprecated"
--GO



--Intentamos conectarnos desde NPB (abcd1234.)
--Al intentar conectarnos da error porque no tiene permiso de conecxion

--Conceder perrmiso de conencxion
GRANT CONNECT TO NPB
GO
--Vuelve a dar error, porque es un usuario de una base de datos especial ("Contenida") y hay que especificar que solo se conecta a esta base de datos

