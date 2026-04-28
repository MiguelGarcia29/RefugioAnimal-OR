-- 1. Eliminar las tablas (esto también elimina la tabla anidada Lista_Dosis de forma automática)
DROP TABLE Table_Animal CASCADE CONSTRAINTS;
DROP TABLE Tabla_Vacuna CASCADE CONSTRAINTS;

-- 3. Eliminar los tipos base (en orden inverso a sus dependencias)
DROP TYPE Tipo_Animal FORCE;
DROP TYPE Tipo_Lista_Dosis FORCE;
DROP TYPE Tipo_Dosis FORCE;
DROP TYPE Tipo_Vacuna FORCE;

-- 4. Eliminar la secuencia
DROP SEQUENCE seq_id_animal;
DROP SEQUENCE seq_vacuna;

CREATE SEQUENCE seq_id_animal START WITH 1 INCREMENT BY 1 MAXVALUE 9999999999;
CREATE SEQUENCE seq_vacuna START WITH 1 INCREMENT BY 1 MAXVALUE 9999999999;

/

CREATE TYPE Tipo_Vacuna AS OBJECT(
    id NUMBER,
    nombre VARCHAR2(50),
    esEsencial CHAR(1)
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
    especie VARCHAR2(50),
    raza VARCHAR2(50),
    color VARCHAR2(20),
    sexo CHAR(1),
    fechaLLegada DATE,
    caracteristicas VARCHAR2(200),
    fechaAdopcion DATE,
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

CREATE OR REPLACE PACKAGE funcionesRefugio AS

    FUNCTION insertarAnimal(
        p_nombre VARCHAR2, p_fechaNacimiento DATE, p_especie VARCHAR2, 
        p_raza VARCHAR2, p_color VARCHAR2, p_sexo CHAR, 
        p_fechaLlegada DATE, p_caracteristicas VARCHAR2
    ) RETURN NUMBER;
    
    FUNCTION edadAnimal(p_id IN NUMBER) RETURN NUMBER;
    
    FUNCTION adoptarAnimal(p_id IN NUMBER) RETURN NUMBER;
    
    FUNCTION actualizarAnimal(
        p_id IN NUMBER, p_nombre VARCHAR2, p_fechaNacimiento DATE, 
        p_especie VARCHAR2, p_raza VARCHAR2, p_color VARCHAR2, 
        p_sexo CHAR, p_fechaLlegada DATE, p_caracteristicas VARCHAR2,
        p_fechaAdopcion DATE
    ) RETURN NUMBER;
    
    FUNCTION borrarAnimal(p_id IN NUMBER) RETURN NUMBER;

    FUNCTION crearVacuna(p_nombre VARCHAR2, p_esEsencial CHAR) RETURN NUMBER;
    
    FUNCTION borrarVacuna(p_id IN NUMBER) RETURN NUMBER;
    
    FUNCTION suministrarDosis(p_id_animal IN NUMBER, p_id_vacuna IN NUMBER, p_fecha DATE) RETURN NUMBER;

END funcionesRefugio;
/
CREATE OR REPLACE PACKAGE BODY funcionesRefugio AS

    FUNCTION insertarAnimal(
        p_nombre VARCHAR2, p_fechaNacimiento DATE, p_especie VARCHAR2, 
        p_raza VARCHAR2, p_color VARCHAR2, p_sexo CHAR, 
        p_fechaLlegada DATE, p_caracteristicas VARCHAR2
    ) RETURN NUMBER IS
    BEGIN
        INSERT INTO Table_Animal VALUES (
            seq_id_animal.NEXTVAL, p_nombre, p_fechaNacimiento, p_especie, 
            p_raza, p_color, p_sexo, p_fechaLlegada, p_caracteristicas, 
            NULL, Tipo_Lista_Dosis()
        );
        COMMIT;
        RETURN 0;
    EXCEPTION WHEN OTHERS THEN ROLLBACK; RETURN -1;
    END insertarAnimal;

    FUNCTION edadAnimal(p_id IN NUMBER) RETURN NUMBER IS
        v_animal Tipo_Animal;
    BEGIN
        SELECT VALUE(a) INTO v_animal FROM Table_Animal a WHERE id = p_id;
        RETURN v_animal.edad();
    EXCEPTION WHEN OTHERS THEN RETURN -1;
    END edadAnimal;

    FUNCTION adoptarAnimal(p_id IN NUMBER) RETURN NUMBER IS
    BEGIN
        UPDATE Table_Animal SET fechaAdopcion = SYSDATE WHERE id = p_id;
        IF SQL%ROWCOUNT = 0 THEN RETURN -1; END IF;
        COMMIT;
        RETURN 0;
    EXCEPTION WHEN OTHERS THEN ROLLBACK; RETURN -1;
    END adoptarAnimal;

    FUNCTION actualizarAnimal(
        p_id IN NUMBER, p_nombre VARCHAR2, p_fechaNacimiento DATE, 
        p_especie VARCHAR2, p_raza VARCHAR2, p_color VARCHAR2, 
        p_sexo CHAR, p_fechaLlegada DATE, p_caracteristicas VARCHAR2,
        p_fechaAdopcion DATE
    ) RETURN NUMBER IS
    BEGIN
        UPDATE Table_Animal SET 
            nombre = p_nombre, fechaNacimiento = p_fechaNacimiento, especie = p_especie,
            raza = p_raza, color = p_color, sexo = p_sexo, fechaLLegada = p_fechaLlegada,
            caracteristicas = p_caracteristicas, fechaAdopcion = p_fechaAdopcion
        WHERE id = p_id;
        IF SQL%ROWCOUNT = 0 THEN RETURN -1; END IF;
        COMMIT;
        RETURN 0;
    EXCEPTION WHEN OTHERS THEN ROLLBACK; RETURN -1;
    END actualizarAnimal;

    FUNCTION borrarAnimal(p_id IN NUMBER) RETURN NUMBER IS
    BEGIN
        DELETE FROM Table_Animal WHERE id = p_id;
        IF SQL%ROWCOUNT = 0 THEN RETURN -1; END IF;
        COMMIT;
        RETURN 0;
    EXCEPTION WHEN OTHERS THEN ROLLBACK; RETURN -1;
    END borrarAnimal;

    FUNCTION crearVacuna(p_nombre VARCHAR2, p_esEsencial CHAR) RETURN NUMBER IS
    BEGIN
        INSERT INTO Tabla_Vacuna VALUES (seq_vacuna.NEXTVAL, p_nombre, p_esEsencial);
        COMMIT;
        RETURN 0;
    EXCEPTION WHEN OTHERS THEN ROLLBACK; RETURN -1;
    END crearVacuna;

    FUNCTION borrarVacuna(p_id IN NUMBER) RETURN NUMBER IS
    BEGIN
        DELETE FROM Tabla_Vacuna WHERE id = p_id;
        IF SQL%ROWCOUNT = 0 THEN RETURN -1; END IF;
        COMMIT;
        RETURN 0;
    EXCEPTION WHEN OTHERS THEN ROLLBACK; RETURN -1;
    END borrarVacuna;

    FUNCTION suministrarDosis(p_id_animal IN NUMBER, p_id_vacuna IN NUMBER, p_fecha DATE) RETURN NUMBER IS
        v_ref_vacuna REF Tipo_Vacuna;
    BEGIN
        -- Intentamos obtener la referencia de la vacuna
        SELECT REF(v) INTO v_ref_vacuna FROM Tabla_Vacuna v WHERE id = p_id_vacuna;
        
        -- Insertamos en la tabla anidada
        INSERT INTO TABLE(SELECT a.Dosis FROM Table_Animal a WHERE a.id = p_id_animal)
        VALUES (Tipo_Dosis(p_fecha, v_ref_vacuna));
        
        COMMIT;
        RETURN 0;
    EXCEPTION WHEN OTHERS THEN ROLLBACK; RETURN -1;
    END suministrarDosis;

END funcionesRefugio;
/

-- TRIGAR PARA VACUNAS ESENCIALES DE UN ANIMAL
-- TRIGGER suministrarEsenciales();
