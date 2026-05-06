-- Creación de Tablas de Objetos
CREATE TABLE Tabla_Vacuna OF Tipo_Vacuna(
    CONSTRAINT PK_Tabla_Vacuna PRIMARY KEY(id)    
);
/

CREATE TABLE Table_Animal OF Tipo_Animal (
    CONSTRAINT PK_Tabla_Animal PRIMARY KEY (id),
    nombre NOT NULL,
    fechaNacimiento NOT NULL,
    color NOT NULL,
    sexo NOT NULL,
    fechaLLegada NOT NULL,
    raza NOT NULL
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
    id NOT NULL,
    nombre NOT NULL,
    fechaNacimiento NOT NULL,
    dni NOT NULL,
    direccion NOT NULL,
    telefono NOT NULL 
)NESTED TABLE cuotas STORE AS Lista_Cuotas;
/

ALTER TABLE Lista_Cuotas ADD (SCOPE FOR (cuotaPagada) IS Tabla_InfoCuota);
/
