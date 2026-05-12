-- 03_tablas.sql
CREATE TABLE Tabla_Especies (
    id_especie NUMBER,
    nombre_especie VARCHAR2(50) NOT NULL,
    CONSTRAINT PK_Especies PRIMARY KEY (id_especie),
    CONSTRAINT UQ_Nombre_Especie UNIQUE (nombre_especie)
);
/

CREATE TABLE Tabla_Razas (
    id_raza NUMBER,
    nombre_raza VARCHAR2(50) NOT NULL,
    id_especie NUMBER NOT NULL,
    CONSTRAINT PK_Razas PRIMARY KEY (id_raza),
    CONSTRAINT FK_Raza_Especie FOREIGN KEY (id_especie) 
        REFERENCES Tabla_Especies(id_especie) ON DELETE CASCADE
);
/

CREATE TABLE Tabla_Vacuna OF Tipo_Vacuna(
    CONSTRAINT PK_Tabla_Vacuna PRIMARY KEY(id),
    CONSTRAINT FK_Tabla_Vacuna FOREIGN KEY (id_especie) 
        REFERENCES Tabla_Especies(id_especie)
);
/

CREATE TABLE Table_Animal OF Tipo_Animal (
    CONSTRAINT PK_Tabla_Animal PRIMARY KEY (id),
    nombre NOT NULL,
    fechaNacimiento NOT NULL,
    color NOT NULL,
    sexo NOT NULL,
    fechaLLegada NOT NULL,
    CONSTRAINT FK_Animal_Raza FOREIGN KEY (id_raza) 
        REFERENCES Tabla_Razas(id_raza)
)
NESTED TABLE Dosis STORE AS Lista_Dosis;
/

ALTER TABLE Lista_Dosis ADD (SCOPE FOR (vacuna) IS Tabla_Vacuna);
/

CREATE TABLE Tabla_InfoCuota OF Tipo_InfoCuota(
    CONSTRAINT PK_Tabla_InfoCUOTAS PRIMARY KEY (ejercicio),
    importe NOT NULL
);
/

CREATE TABLE Tabla_Socio OF Tipo_Socio(
    CONSTRAINT PK_Tabla_Socio PRIMARY KEY (id),
    dni NOT NULL
)NESTED TABLE cuotas STORE AS Lista_Cuotas;
/

ALTER TABLE Lista_Cuotas ADD (SCOPE FOR (cuotaPagada) IS Tabla_InfoCuota);
/