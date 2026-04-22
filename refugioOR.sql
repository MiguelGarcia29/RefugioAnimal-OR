-- 1. Eliminar las tablas (esto también elimina la tabla anidada Lista_Dosis de forma automática)
DROP TABLE Table_Animal CASCADE CONSTRAINTS;
DROP TABLE Tabla_Vacuna CASCADE CONSTRAINTS;

-- 2. Eliminar los subtipos (hijos)
DROP TYPE Perro FORCE;
DROP TYPE Gato FORCE;

-- 3. Eliminar los tipos base (en orden inverso a sus dependencias)
DROP TYPE Tipo_Animal FORCE;
DROP TYPE Tipo_Lista_Dosis FORCE;
DROP TYPE Tipo_Dosis FORCE;
DROP TYPE Tipo_Vacuna FORCE;

-- 4. Eliminar la secuencia
DROP SEQUENCE seq_id_animal;




CREATE SEQUENCE seq_id_animal START WITH 1 INCREMENT BY 1 MAXVALUE 9999999999;
/

CREATE TYPE Tipo_Vacuna AS OBJECT(
    id NUMBER,
    nombre VARCHAR2(50),
    esEsencial CHAR(1), 
    especie VARCHAR2(10)
);
/

CREATE TABLE Tabla_Vacuna OF Tipo_Vacuna(
    -- id GENERATED ALWAYS AS IDENTITY START WITH 1 INCREMENTE BY 1,
    CONSTRAINT PK_Tabla_Vacuna PRIMARY KEY(id)    
);
/

CREATE TYPE Tipo_Dosis AS OBJECT(
    fechaAdministracion DATE,
    vacuna REF Tipo_Vacuna
);
/

CREATE TYPE Tipo_Lista_Dosis AS TABLE OF Tipo_Dosis;
/

CREATE TYPE Tipo_Animal AS OBJECT(
    id NUMBER,
    nombre VARCHAR2(50),
    fechaNacimiento DATE,
    raza VARCHAR2(50),
    color VARCHAR2(20),
    sexo CHAR(1),
    fechaLLegada DATE,
    caracteristicas VARCHAR2(200),
    Dosis Tipo_Lista_Dosis,
    MEMBER FUNCTION edad RETURN NUMBER

) NOT FINAL; 
/

CREATE OR REPLACE TYPE BODY Tipo_Animal IS
    MEMBER FUNCTION edad RETURN NUMBER IS
        fechaActual DATE := SYSDATE;
        edad_anios NUMBER;
    BEGIN
        edad_anios := FLOOR(MONTHS_BETWEEN(fechaActual,fechaNacimiento)/12);
        RETURN edad_anios;
    END edad;
END;
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

CREATE TYPE Perro UNDER Tipo_Animal(
    RPP CHAR(1) 
);
/

CREATE TYPE Gato UNDER Tipo_Animal(
);
/

CREATE OR REPLACE PACKAGE funcionesRefugio AS
    PROCEDURE ultimosAnimales(cantidad IN NUMBER);
END funcionesRefugio;
/

CREATE OR REPLACE PACKAGE BODY funcionesRefugio AS
    PROCEDURE ultimosAnimales(cantidad IN NUMBER) IS
        CURSOR iterar IS 
            SELECT * FROM Table_Animal ORDER BY fechaLLegada DESC;
        fila Table_Animal%ROWTYPE;
        iteracion NUMBER := 0;
    BEGIN
        OPEN iterar;
        iteracion := iteracion + 1;
        FETCH iterar INTO fila;
        WHILE iteracion<=cantidad AND iterar%FOUND LOOP
            DBMS_OUTPUT.PUT_LINE('Id: ' ||fila.id||'Nombre: ' ||fila.nombre ||'Raza: '||fila.raza);
            iteracion := iteracion + 1;
            FETCH iterar INTO fila;
        END LOOP;
        CLOSE iterar;
    END ultimosAnimales;
END funcionesRefugio;

CREATE TRIGGER llegaAnimal 
BEFORE INSERT ON Table_Animal
WHEN (NEW.fechaLLegada IS NULL )
BEGIN
    NEW.fechaLLegada := SYSDATE;
END llegaAnimal;
