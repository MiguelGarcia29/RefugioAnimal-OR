-- 1. Borrar el paquete (especificación y cuerpo)
DROP PACKAGE funcionesRefugio;

-- 2. Borrar las secuencias (usadas en el Package)
DROP SEQUENCE seq_id_animal;
DROP SEQUENCE seq_vacuna;
DROP SEQUENCE seq_socio;

-- 3. Borrar las Tablas (CASCADE CONSTRAINTS elimina dependencias de las REF y anidadas)
DROP TABLE Table_Animal CASCADE CONSTRAINTS;
DROP TABLE Tabla_Socio CASCADE CONSTRAINTS;
DROP TABLE Tabla_Vacuna CASCADE CONSTRAINTS;
DROP TABLE Tabla_InfoCuota CASCADE CONSTRAINTS;

-- 4. Borrar los Tipos de la rama de Animales y Vacunas
DROP TYPE Tipo_Animal FORCE;
DROP TYPE Tipo_Lista_Dosis FORCE;
DROP TYPE Tipo_Dosis FORCE;
DROP TYPE Tipo_Vacuna FORCE;

-- 5. Borrar los Tipos de la rama de Socios y Cuotas
-- (Nota: Respetando el nombre "Tipo_CuotasPagafas" que pusiste en tu script)
DROP TYPE Tipo_Socio FORCE;
DROP TYPE Tabla_CuotasPagadas FORCE;
DROP TYPE Tipo_CuotasPagafas FORCE;
DROP TYPE Tipo_InfoCuota FORCE;

CREATE SEQUENCE seq_id_animal START WITH 1 INCREMENT BY 1 MAXVALUE 9999999999;
CREATE SEQUENCE seq_vacuna START WITH 1 INCREMENT BY 1 MAXVALUE 9999999999;
CREATE SEQUENCE seq_socio START WITH 1 INCREMENT BY 1 MAXVALUE 9999999999;

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

-- AÑO Y VALOR DE AL CUOTA ESE AÑO
CREATE TYPE Tipo_InfoCuota AS OBJECT(
    ejercicio NUMBER(4),
    importe NUMBER(6,2)
);
/

CREATE TABLE Tabla_InfoCuota OF Tipo_InfoCuota(
    CONSTRAINT PK_Tabla_InfoCUOTAS PRIMARY KEY (ejercicio),
    importe NOT NULL
);
/

CREATE TYPE Tipo_CuotasPagafas AS OBJECT (
    cuotaPagada REF Tipo_InfoCuota,
    pagada CHAR(1) -- SI ESTA PAGADA O NO
);
/

CREATE TYPE Tabla_CuotasPagadas AS TABLE OF Tipo_CuotasPagafas;
/

CREATE TYPE Tipo_Socio AS OBJECT(
    id NUMBER,
    nombre VARCHAR2(50),
    fechaNacimiento DATE,
    dni VARCHAR2(10),
    direccion VARCHAR2(100),
    telefono VARCHAR2(15),
    cuotas Tabla_CuotasPagadas


) NOT FINAL; 
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

    FUNCTION insertarSocio(
        p_nombre VARCHAR2, p_fechaNacimiento DATE, p_dni VARCHAR2, 
        p_direccion VARCHAR2, p_telefono VARCHAR2
    ) RETURN NUMBER;
    
    FUNCTION insertarCuota(p_ejercicio NUMBER, p_importe NUMBER) RETURN NUMBER;
    
    FUNCTION asignarCuotaSocio(p_id_socio NUMBER, p_ejercicio NUMBER, p_pagada CHAR) RETURN NUMBER;

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

    FUNCTION insertarSocio (
        p_nombre VARCHAR2, p_fechaNacimiento DATE, p_dni VARCHAR2, 
        p_direccion VARCHAR2, p_telefono VARCHAR2
    ) RETURN NUMBER IS
    BEGIN
        INSERT INTO Tabla_Socio VALUES (
            seq_socio.NEXTVAL, p_nombre, p_fechaNacimiento, p_dni, 
            p_direccion, p_telefono, Tabla_CuotasPagadas() 
        );
        COMMIT;
        RETURN 0;
    EXCEPTION WHEN OTHERS THEN ROLLBACK; RETURN -1;
    END insertarSocio;

    FUNCTION insertarCuota (p_ejercicio NUMBER, p_importe NUMBER) RETURN NUMBER IS
    BEGIN
        INSERT INTO Tabla_InfoCuota VALUES (
            Tipo_InfoCuota(p_ejercicio, p_importe)
        );
        COMMIT;
        RETURN 0;
    EXCEPTION WHEN OTHERS THEN ROLLBACK; RETURN -1;
    END insertarCuota;

    FUNCTION asignarCuotaSocio (p_id_socio NUMBER, p_ejercicio NUMBER, p_pagada CHAR) RETURN NUMBER IS
        v_ref_cuota REF Tipo_InfoCuota;
    BEGIN
        -- 1. Obtenemos la referencia
        SELECT REF(c) INTO v_ref_cuota 
        FROM Tabla_InfoCuota c 
        WHERE ejercicio = p_ejercicio;
        
        -- 2. Insertamos en la colección del socio
        INSERT INTO TABLE(SELECT cuotas FROM Tabla_Socio WHERE id = p_id_socio)
        VALUES (Tipo_CuotasPagafas(v_ref_cuota, p_pagada));
        
        COMMIT;
        RETURN 0;
    EXCEPTION WHEN OTHERS THEN ROLLBACK; RETURN -1;
    END asignarCuotaSocio;

END funcionesRefugio;
/

-- TRIGAR PARA VACUNAS ESENCIALES DE UN ANIMAL
-- TRIGGER suministrarEsenciales();
-- TRIGGER PARA CUANDO INSERTE UNA CUOTA PONERLESELA NO PAGADAS A TODOS LOS SOCIOS
CREATE OR REPLACE TRIGGER Trigger_AsignarCuotas
FOR INSERT ON Tabla_InfoCuota
COMPOUND TRIGGER

    v_ejercicio NUMBER(4);

    AFTER EACH ROW IS
    BEGIN
        v_ejercicio := :NEW.ejercicio;
    END AFTER EACH ROW;

    AFTER STATEMENT IS
        v_ref_cuota REF Tipo_InfoCuota;
    BEGIN
        IF v_ejercicio IS NOT NULL THEN
            
            SELECT REF(c) INTO v_ref_cuota
            FROM Tabla_InfoCuota c
            WHERE ejercicio = v_ejercicio;

            FOR r_socio IN (SELECT id FROM Tabla_Socio) LOOP
                
                INSERT INTO TABLE(SELECT cuotas FROM Tabla_Socio WHERE id = r_socio.id)
                VALUES (Tipo_CuotasPagafas(v_ref_cuota, 'N'));
                
            END LOOP;
            
            v_ejercicio := NULL;
            
        END IF;
    END AFTER STATEMENT;

END Trigger_AsignarCuotas;
/


COMMIT;