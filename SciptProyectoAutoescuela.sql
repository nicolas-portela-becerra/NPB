-- Generated by Oracle SQL Developer Data Modeler 18.2.0.179.0756
--   at:        2021-03-09 21:31:01 CET
--   site:      SQL Server 2012
--   type:      SQL Server 2012
USE master
GO
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
GO

CREATE TABLE alumnos (
    id                    VARCHAR(20) NOT NULL,
    nombre                VARCHAR(50),
    apellidos             VARCHAR(50),
    clase_teorica_grupo   VARCHAR(10) NOT NULL,
    psicotecnico          bit NOT NULL
)

go

ALTER TABLE Alumnos ADD constraint alumnos_pk PRIMARY KEY CLUSTERED (ID)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON ) 
go

CREATE TABLE clase_teorica (
    grupo         VARCHAR(10) NOT NULL,
    hora_inicio   time,
    hora_fin      time,
    n�alumnos     INTEGER NOT NULL
)

go

ALTER TABLE Clase_Teorica ADD constraint clase_teorica_pk PRIMARY KEY CLUSTERED (Grupo)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON ) 
go

CREATE TABLE coches (
    matricula   VARCHAR(7) NOT NULL,
    modelo      VARCHAR(10),
    marca       VARCHAR(10)
)

go

ALTER TABLE Coches ADD constraint coches_pk PRIMARY KEY CLUSTERED (Matricula)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON ) 
go

CREATE TABLE examen_practico (
    examinador   VARCHAR(50) NOT NULL,
    fecha_hora   datetime,
    fallos       INTEGER,
    alumnos_id   VARCHAR(20) NOT NULL
)

go 

    


CREATE unique nonclustered index examen_practico__idx ON examen_practico ( alumnos_id ) 
go

ALTER TABLE Examen_Practico ADD constraint examen_practico_pk PRIMARY KEY CLUSTERED (Examinador)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
go

CREATE TABLE examen_teorico (
    id_examen           VARCHAR(50) NOT NULL,
    fecha_hora_examen   datetime,
    fallos              INTEGER,
    alumnos_id          VARCHAR(20) NOT NULL
)

go 

    


CREATE unique nonclustered index examen_teorico__idx ON examen_teorico ( alumnos_id ) 
go

ALTER TABLE Examen_Teorico ADD constraint examen_teorico_pk PRIMARY KEY CLUSTERED (ID_Examen)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON ) 
go

CREATE TABLE facturas (
    id_factura       VARCHAR(25) NOT NULL,
    importe          INTEGER NOT NULL,
    fecha            DATE NOT NULL,
    metodo_de_pago   VARCHAR(20) NOT NULL,
    alumnos_id       VARCHAR(20) NOT NULL
)

go

ALTER TABLE Facturas ADD constraint facturas_pk PRIMARY KEY CLUSTERED (Id_Factura)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON ) 
go

CREATE TABLE practica_coche (
    hora_inicio     time,
    duracion        INTEGER,
    alumnos_id      VARCHAR(20) NOT NULL,
    profesores_id   VARCHAR(20) NOT NULL
)

go

CREATE TABLE profesores (
    id                 VARCHAR(20) NOT NULL,
    nombre             VARCHAR(50),
    apellidos          VARCHAR(50),
    coches_matricula   VARCHAR(7) NOT NULL
)

go 

    


CREATE unique nonclustered index profesores__idx ON profesores ( coches_matricula ) 
go

ALTER TABLE Profesores ADD constraint profesores_pk PRIMARY KEY CLUSTERED (ID)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON ) 
go

ALTER TABLE Alumnos
    ADD CONSTRAINT alumnos_clase_teorica_fk FOREIGN KEY ( clase_teorica_grupo )
        REFERENCES clase_teorica ( grupo )
ON DELETE NO ACTION 
    ON UPDATE no action
go

ALTER TABLE Examen_Practico
    ADD CONSTRAINT examen_practico_alumnos_fk FOREIGN KEY ( alumnos_id )
        REFERENCES alumnos ( id )
ON DELETE NO ACTION 
    ON UPDATE no action 
go

ALTER TABLE Examen_Teorico
    ADD CONSTRAINT examen_teorico_alumnos_fk FOREIGN KEY ( alumnos_id )
        REFERENCES alumnos ( id )
ON DELETE NO ACTION 
    ON UPDATE no action 
go

ALTER TABLE Facturas
    ADD CONSTRAINT facturas_alumnos_fk FOREIGN KEY ( alumnos_id )
        REFERENCES alumnos ( id )
ON DELETE NO ACTION 
    ON UPDATE no action 
go

ALTER TABLE Practica_Coche
    ADD CONSTRAINT practica_coche_alumnos_fk FOREIGN KEY ( alumnos_id )
        REFERENCES alumnos ( id )
ON DELETE NO ACTION 
    ON UPDATE no action 
go

ALTER TABLE Practica_Coche
    ADD CONSTRAINT practica_coche_profesores_fk FOREIGN KEY ( profesores_id )
        REFERENCES profesores ( id )
ON DELETE NO ACTION 
    ON UPDATE no action 
go

ALTER TABLE Profesores
    ADD CONSTRAINT profesores_coches_fk FOREIGN KEY ( coches_matricula )
        REFERENCES coches ( matricula )
ON DELETE NO ACTION 
    ON UPDATE no action 
go



-- Oracle SQL Developer Data Modeler Summary Report: 
-- 
-- CREATE TABLE                             8
-- CREATE INDEX                             3
-- ALTER TABLE                             14
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE DATABASE                          0
-- CREATE DEFAULT                           0
-- CREATE INDEX ON VIEW                     0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE ROLE                              0
-- CREATE RULE                              0
-- CREATE SCHEMA                            0
-- CREATE SEQUENCE                          0
-- CREATE PARTITION FUNCTION                0
-- CREATE PARTITION SCHEME                  0
-- 
-- DROP DATABASE                            0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0