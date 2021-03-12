--Tablas Temporales
	-->Usuario => Ej: #Autores <--Locales, ##Autores <--Globales
	-->Version del Sistema (Recoge todos los moviemientos que tuvo la tabla con el antiguo contenido)

USE master
GO
DROP DATABASE IF EXISTS CAR
GO
CREATE DATABASE CAR
GO
USE CAR
GO
-------
DROP TABLE IF EXISTS CarInventory
GO
DROP TABLE IF EXISTS CarInventoryHistory
GO
------
CREATE TABLE CarInventory
(
	CardId INT IDENTITY PRIMARY KEY,
	Year INT, 
	Make VARCHAR(40),
	Model VARCHAR(40),
	Color VARCHAR(10),
	Mileage INT, 
	InLot BIT NOT NULL DEFAULT 1,
	SysStartTime datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
	SysEndTime datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
	PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime)
)
WITH
(
	SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.CarInventoryHistory) --Se pone "HISTORY_TABLE=" para darle un nombre a la tabla y que no la genere el sistema

);
GO

SELECT * FROM CarInventory
GO
SELECT * FROM CarInventoryHistory
GO
--No hay nada porque no hubo cambios, esta tabla detecta los cambios en los campos de la tabla

INSERT INTO dbo.CarInventory (Year, Make, Model, Color, Mileage)
VALUES(2017, 'Chevy', 'Malibu', 'Black', 0)
INSERT INTO dbo.CarInventory (Year, Make, Model, Color, Mileage)
VALUES(2017, 'Chevy', 'Malibu', 'Silver', 0)
GO

UPDATE  CarInventory set InLot = 0 WHERE CardId = 1
UPDATE CarInventory set InLot = 0 WHERE CardId = 2
GO
SELECT * FROM CarInventory
GO
--CardId Year Make  Model   Color Mileage InLot SysStartTime              SysEndTime
--1	2017	Chevy	Malibu	Black	0	0	2021-02-02 20:30:07.7567918	9999-12-31 23:59:59.9999999
--2	2017	Chevy	Malibu	Silver	0	0	2021-02-02 20:30:07.7567918	9999-12-31 23:59:59.9999999

SELECT * FROM CarInventoryHistory
GO
--CardId Year Make  Model   Color Mileage InLot SysStartTime              SysEndTime
--1	2017	Chevy	Malibu	Black	0	1	2021-01-28 21:18:32.1660712	2021-02-02 20:30:07.7567918
--2	2017	Chevy	Malibu	Silver	0	1	2021-01-28 21:18:32.1827042	2021-02-02 20:30:07.7567918
--Ahora muestra el cambio del UPDATE en el campo "InLot" sigue mostrando 1 porque es el historico, es decir, el valor anterior
--Tambien cambio el valor de "SysEndTime" al momento de la ultima modificaicon

UPDATE CarInventory SET InLot = 1, Mileage = 73 WHERE CardId = 1
UPDATE CarInventory SET InLot = 1, Mileage = 488 WHERE CardId = 2
GO

SELECT * FROM CarInventory
GO
--CardId Year Make  Model   Color Mileage InLot SysStartTime              SysEndTime
--1	2017	Chevy	Malibu	Black	73	1	2021-02-02 20:39:30.5563262	9999-12-31 23:59:59.9999999
--2	2017	Chevy	Malibu	Silver	488	1	2021-02-02 20:39:30.5717321	9999-12-31 23:59:59.9999999

SELECT * FROM CarInventoryHistory
GO
--CardId Year Make  Model   Color Mileage InLot SysStartTime              SysEndTime
--1	2017	Chevy	Malibu	Black	0	1	2021-01-28 21:18:32.1660712	2021-02-02 20:30:07.7567918
--2	2017	Chevy	Malibu	Silver	0	1	2021-01-28 21:18:32.1827042	2021-02-02 20:30:07.7567918
--1	2017	Chevy	Malibu	Black	0	0	2021-02-02 20:30:07.7567918	2021-02-02 20:39:30.5563262
--2	2017	Chevy	Malibu	Silver	0	0	2021-02-02 20:30:07.7567918	2021-02-02 20:39:30.5717321
--Aparece el segundo update ya que en la tabla real esta el 3er cambio, mientras no se haga un insert mas no se mostrara el kilometraje nuevo

DELETE FROM CarInventory WHERE CardId = 2
GO
SELECT * FROM CarInventory
GO
--ELiminamos uno de los coches

SELECT * FROM CarInventoryHistory
GO
--1	2017	Chevy	Malibu	Black	0	1	2021-01-28 21:18:32.1660712	2021-02-02 20:30:07.7567918
--2	2017	Chevy	Malibu	Silver	0	1	2021-01-28 21:18:32.1827042	2021-02-02 20:30:07.7567918
--1	2017	Chevy	Malibu	Black	0	0	2021-02-02 20:30:07.7567918	2021-02-02 20:39:30.5563262
--2	2017	Chevy	Malibu	Silver	0	0	2021-02-02 20:30:07.7567918	2021-02-02 20:39:30.5717321
--2	2017	Chevy	Malibu	Silver	488	1	2021-02-02 20:39:30.5717321	2021-02-02 20:45:44.6573768


--Ahora recuperamos los registros de la tabla en algun momento del tiempo

SELECT * FROM CarInventory
FOR SYSTEM_TIME AS OF '2021-01-28 21:18:32.1827042'
GO
--Muestra como estaba la tabla en ese momento del tiempo 
--1	2017	Chevy	Malibu	Black	0	1	2021-01-28 21:18:32.1660712	2021-02-02 20:30:07.7567918
--2	2017	Chevy	Malibu	Silver	0	1	2021-01-28 21:18:32.1827042	2021-02-02 20:30:07.7567918

SELECT * FROM CarInventory
FOR SYSTEM_TIME AS OF '2021-02-02 20:30:07.7567918'
GO
--Muetra el momento del tiempo en el que los 2 coches estaban alquilados
--1	2017	Chevy	Malibu	Black	0	0	2021-02-02 20:30:07.7567918	2021-02-02 20:39:30.5563262
--2	2017	Chevy	Malibu	Silver	0	0	2021-02-02 20:30:07.7567918	2021-02-02 20:39:30.5717321

SELECT * FROM CarInventory
FOR SYSTEM_TIME ALL
GO
--Muestra la tabla con todos los movimientos que hizo
--1	2017	Chevy	Malibu	Black	73	1	2021-02-02 20:39:30.5563262	9999-12-31 23:59:59.9999999
--1	2017	Chevy	Malibu	Black	0	1	2021-01-28 21:18:32.1660712	2021-02-02 20:30:07.7567918
--2	2017	Chevy	Malibu	Silver	0	1	2021-01-28 21:18:32.1827042	2021-02-02 20:30:07.7567918
--1	2017	Chevy	Malibu	Black	0	0	2021-02-02 20:30:07.7567918	2021-02-02 20:39:30.5563262
--2	2017	Chevy	Malibu	Silver	0	0	2021-02-02 20:30:07.7567918	2021-02-02 20:39:30.5717321
--2	2017	Chevy	Malibu	Silver	488	1	2021-02-02 20:39:30.5717321	2021-02-02 20:45:44.6573768
--Tambien recoge el original, el valor actual de la tabla. Se sabe porque la fecha pone "9999"