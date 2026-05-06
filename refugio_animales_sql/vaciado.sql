PROMPT *** Vaciando la base de datos (Limpieza Total) ***

-- 1. Paquetes
DROP PACKAGE funcionesRefugio;

-- 2. Secuencias
DROP SEQUENCE seq_id_animal;
DROP SEQUENCE seq_vacuna;
DROP SEQUENCE seq_socio;

-- 3. Tablas (El orden importa por las REF, pero CASCADE ayuda)
DROP TABLE Table_Animal CASCADE CONSTRAINTS;
DROP TABLE Tabla_Socio CASCADE CONSTRAINTS;
DROP TABLE Tabla_Vacuna CASCADE CONSTRAINTS;
DROP TABLE Tabla_InfoCuota CASCADE CONSTRAINTS;

-- 4. Tipos (FORCE es necesario si hay dependencias circulares o tablas de objetos)
DROP TYPE Tipo_Animal FORCE;
DROP TYPE Tipo_Lista_Dosis FORCE;
DROP TYPE Tipo_Dosis FORCE;
DROP TYPE Tipo_Vacuna FORCE;
DROP TYPE Tipo_Socio FORCE;
DROP TYPE Tabla_CuotasPagadas FORCE;
DROP TYPE Tipo_CuotasPagafas FORCE;
DROP TYPE Tipo_InfoCuota FORCE;

PROMPT *** Base de datos vacía. Iniciando creación... ***