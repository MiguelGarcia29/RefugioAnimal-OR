-- Script principal de instalación
SET ECHO ON
SET FEEDBACK ON

PROMPT *** Borrando objetos previos...
DROP PACKAGE funcionesRefugio;
DROP SEQUENCE seq_id_animal;
DROP SEQUENCE seq_vacuna;
DROP SEQUENCE seq_socio;
DROP SEQUENCE seq_especie;
DROP SEQUENCE seq_raza;
DROP TABLE Table_Animal CASCADE CONSTRAINTS;
DROP TABLE Tabla_Socio CASCADE CONSTRAINTS;
DROP TABLE Tabla_Vacuna CASCADE CONSTRAINTS;
DROP TABLE Tabla_InfoCuota CASCADE CONSTRAINTS;
DROP TABLE Tabla_Especies CASCADE CONSTRAINTS;
DROP TABLE Tabla_Razas CASCADE CONSTRAINTS;
DROP TYPE Tipo_Animal FORCE;
DROP TYPE Tipo_Lista_Dosis FORCE;
DROP TYPE Tipo_Dosis FORCE;
DROP TYPE Tipo_Vacuna FORCE;
DROP TYPE Tipo_Socio FORCE;
DROP TYPE Tabla_CuotasPagadas FORCE;
DROP TYPE Tipo_CuotasPagafas FORCE;
DROP TYPE Tipo_InfoCuota FORCE;

PROMPT *** Creando secuencias...
@01_secuencias.sql

PROMPT *** Creando tipos...
@02_tipos.sql

PROMPT *** Creando tablas...
@03_tablas.sql

PROMPT *** Creando paquete...
@04_paquete.sql

PROMPT *** Creando disparadores...
@05_disparadores.sql

PROMPT *** Cargando datos iniciales...
@06_insercion.sql

PROMPT *** Instalación completada.
