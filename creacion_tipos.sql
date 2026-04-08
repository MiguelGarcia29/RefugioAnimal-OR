-- Tipo para direcciones (reutilizable)
CREATE OR REPLACE TYPE Direccion_T AS OBJECT (
    calle VARCHAR2(100),
    ciudad VARCHAR2(50),
    codigo_postal VARCHAR2(5),
    provincia VARCHAR2(50)
) FINAL;
/

-- Superclase Persona (Not Final permite herencia)
CREATE OR REPLACE TYPE Persona_T AS OBJECT (
    dni VARCHAR2(9),
    nombre VARCHAR2(50),
    apellidos VARCHAR2(100),
    telefono VARCHAR2(15),
    direccion Direccion_T
) NOT FINAL;
/

-- Subtipo Adoptante
CREATE OR REPLACE TYPE Adoptante_T UNDER Persona_T (
    vivienda_tipo VARCHAR2(20), -- 'Piso', 'Casa con jardín'
    tiene_otros_animales CHAR(1) -- 'S' o 'N'
);
/

-- Superclase Animal
CREATE OR REPLACE TYPE Animal_T AS OBJECT (
    id_animal NUMBER,
    nombre VARCHAR2(50),
    fecha_nacimiento DATE,
    sexo CHAR(1),
    estado VARCHAR2(20) -- 'Disponible', 'Adoptado', 'En Tratamiento'
) NOT FINAL;
/

-- Subtipo Perro
CREATE OR REPLACE TYPE Perro_T UNDER Animal_T (
    raza VARCHAR2(50),
    es_ppp CHAR(1) -- Perro Potencialmente Peligroso
);
/

-- Subtipo Gato
CREATE OR REPLACE TYPE Gato_T UNDER Animal_T (
    es_social CHAR(1),
    tipo_pelo VARCHAR2(20)
);
/