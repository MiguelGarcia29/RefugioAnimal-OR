-- 04_paquete.sql
CREATE OR REPLACE PACKAGE funcionesRefugio AS
    FUNCTION insertarAnimal(p_nombre VARCHAR2, p_fechaNacimiento DATE, p_id_raza NUMBER, p_color VARCHAR2, p_sexo CHAR, p_fechaLlegada DATE, p_caracteristicas VARCHAR2) RETURN NUMBER;
    FUNCTION actualizarAnimal(p_id IN NUMBER, p_nombre VARCHAR2, p_fechaNacimiento DATE, p_id_raza NUMBER, p_color VARCHAR2, p_sexo CHAR, p_fechaLlegada DATE, p_caracteristicas VARCHAR2, p_fechaAdopcion DATE) RETURN NUMBER;
    FUNCTION edadAnimal(p_id IN NUMBER) RETURN NUMBER;
    FUNCTION adoptarAnimal(p_id IN NUMBER) RETURN NUMBER;
    FUNCTION borrarAnimal(p_id IN NUMBER) RETURN NUMBER;
    FUNCTION crearVacuna(p_nombre VARCHAR2, p_esEsencial CHAR, p_id_especie NUMBER) RETURN NUMBER;
    FUNCTION borrarVacuna(p_id IN NUMBER) RETURN NUMBER;
    FUNCTION suministrarDosis(p_id_animal IN NUMBER, p_id_vacuna IN NUMBER, p_fecha DATE) RETURN NUMBER;
    FUNCTION insertarSocio(p_nombre VARCHAR2, p_fechaNacimiento DATE, p_dni VARCHAR2, p_direccion VARCHAR2, p_telefono VARCHAR2) RETURN NUMBER;
    FUNCTION insertarCuota(p_ejercicio NUMBER, p_importe NUMBER) RETURN NUMBER;
    FUNCTION asignarCuotaSocio(p_id_socio NUMBER, p_ejercicio NUMBER, p_pagada CHAR) RETURN NUMBER;
    FUNCTION obtenerRazasPorEspecie(p_nombre_especie VARCHAR2) RETURN Lista_Nombres;
    FUNCTION obtenerEspeciePorRaza(p_nombre_raza VARCHAR2) RETURN VARCHAR2;
    FUNCTION insertarEspecie(p_nombre VARCHAR2) RETURN NUMBER;
    FUNCTION insertarRaza(p_nombre VARCHAR2, p_id_especie NUMBER) RETURN NUMBER;
END funcionesRefugio;
/

CREATE OR REPLACE PACKAGE BODY funcionesRefugio AS

    FUNCTION insertarEspecie(p_nombre VARCHAR2) RETURN NUMBER IS
    BEGIN
        INSERT INTO Tabla_Especies (id_especie, nombre_especie) 
        VALUES (seq_especie.NEXTVAL, p_nombre);
        COMMIT;
        RETURN 0;
    EXCEPTION WHEN OTHERS THEN ROLLBACK; RETURN -1;
    END;

    FUNCTION insertarRaza(p_nombre VARCHAR2, p_id_especie NUMBER) RETURN NUMBER IS
    BEGIN
        INSERT INTO Tabla_Razas (id_raza, nombre_raza, id_especie) 
        VALUES (seq_raza.NEXTVAL, p_nombre, p_id_especie);
        COMMIT;
        RETURN 0;
    EXCEPTION WHEN OTHERS THEN ROLLBACK; RETURN -1;
    END;

    FUNCTION insertarAnimal(
        p_nombre VARCHAR2, p_fechaNacimiento DATE, p_id_raza NUMBER, 
        p_color VARCHAR2, p_sexo CHAR, p_fechaLlegada DATE, 
        p_caracteristicas VARCHAR2
    ) RETURN NUMBER IS
    BEGIN
        INSERT INTO Table_Animal VALUES (
            seq_id_animal.NEXTVAL, p_nombre, p_fechaNacimiento, 
            p_id_raza, p_color, p_sexo, p_fechaLlegada, p_caracteristicas, 
            NULL, Tipo_Lista_Dosis()
        );
        COMMIT;
        RETURN 0;
    EXCEPTION WHEN OTHERS THEN ROLLBACK; RETURN -1;
    END;

    FUNCTION actualizarAnimal(
        p_id IN NUMBER, p_nombre VARCHAR2, p_fechaNacimiento DATE, 
        p_id_raza NUMBER, p_color VARCHAR2, p_sexo CHAR, 
        p_fechaLlegada DATE, p_caracteristicas VARCHAR2, p_fechaAdopcion DATE
    ) RETURN NUMBER IS
    BEGIN
        UPDATE Table_Animal SET 
            nombre = p_nombre, 
            fechaNacimiento = p_fechaNacimiento, 
            id_raza = p_id_raza, 
            color = p_color, 
            sexo = p_sexo, 
            fechaLLegada = p_fechaLlegada, 
            caracteristicas = p_caracteristicas, 
            fechaAdopcion = p_fechaAdopcion 
        WHERE id = p_id;
        IF SQL%ROWCOUNT = 0 THEN RETURN -1; END IF;
        COMMIT;
        RETURN 0;
    EXCEPTION WHEN OTHERS THEN ROLLBACK; RETURN -1;
    END;

    FUNCTION crearVacuna(p_nombre VARCHAR2, p_esEsencial CHAR, p_id_especie NUMBER) RETURN NUMBER IS
    BEGIN
        INSERT INTO Tabla_Vacuna VALUES (
            seq_vacuna.NEXTVAL, p_nombre, p_esEsencial, p_id_especie
        );
        COMMIT;
        RETURN 0;
    EXCEPTION WHEN OTHERS THEN ROLLBACK; RETURN -1;
    END;

    FUNCTION edadAnimal(p_id IN NUMBER) RETURN NUMBER IS
        v_animal Tipo_Animal;
    BEGIN
        SELECT VALUE(a) INTO v_animal FROM Table_Animal a WHERE id = p_id;
        RETURN v_animal.edad();
    EXCEPTION WHEN OTHERS THEN RETURN -1;
    END;

    FUNCTION adoptarAnimal(p_id IN NUMBER) RETURN NUMBER IS
    BEGIN
        UPDATE Table_Animal SET fechaAdopcion = SYSDATE WHERE id = p_id;
        IF SQL%ROWCOUNT = 0 THEN RETURN -1; END IF;
        COMMIT;
        RETURN 0;
    EXCEPTION WHEN OTHERS THEN ROLLBACK; RETURN -1;
    END;

    FUNCTION borrarAnimal(p_id IN NUMBER) RETURN NUMBER IS
    BEGIN
        DELETE FROM Table_Animal WHERE id = p_id;
        IF SQL%ROWCOUNT = 0 THEN RETURN -1; END IF;
        COMMIT;
        RETURN 0;
    EXCEPTION WHEN OTHERS THEN ROLLBACK; RETURN -1;
    END;

    FUNCTION borrarVacuna(p_id IN NUMBER) RETURN NUMBER IS
    BEGIN
        DELETE FROM Tabla_Vacuna WHERE id = p_id;
        IF SQL%ROWCOUNT = 0 THEN RETURN -1; END IF;
        COMMIT;
        RETURN 0;
    EXCEPTION WHEN OTHERS THEN ROLLBACK; RETURN -1;
    END;

    FUNCTION suministrarDosis(p_id_animal IN NUMBER, p_id_vacuna IN NUMBER, p_fecha DATE) RETURN NUMBER IS
        v_ref_vacuna REF Tipo_Vacuna;
    BEGIN
        SELECT REF(v) INTO v_ref_vacuna FROM Tabla_Vacuna v WHERE id = p_id_vacuna;
        INSERT INTO TABLE(SELECT a.Dosis FROM Table_Animal a WHERE a.id = p_id_animal) 
        VALUES (Tipo_Dosis(p_fecha, v_ref_vacuna));
        COMMIT;
        RETURN 0;
    EXCEPTION WHEN OTHERS THEN ROLLBACK; RETURN -1;
    END;

    FUNCTION insertarSocio (p_nombre VARCHAR2, p_fechaNacimiento DATE, p_dni VARCHAR2, p_direccion VARCHAR2, p_telefono VARCHAR2) RETURN NUMBER IS
    BEGIN
        INSERT INTO Tabla_Socio VALUES (seq_socio.NEXTVAL, p_nombre, p_fechaNacimiento, p_dni, p_direccion, p_telefono, Tabla_CuotasPagadas());
        COMMIT;
        RETURN 0;
    EXCEPTION WHEN OTHERS THEN ROLLBACK; RETURN -1;
    END;

    FUNCTION insertarCuota (p_ejercicio NUMBER, p_importe NUMBER) RETURN NUMBER IS
    BEGIN
        INSERT INTO Tabla_InfoCuota VALUES (Tipo_InfoCuota(p_ejercicio, p_importe));
        COMMIT;
        RETURN 0;
    EXCEPTION WHEN OTHERS THEN ROLLBACK; RETURN -1;
    END;

    FUNCTION asignarCuotaSocio (p_id_socio NUMBER, p_ejercicio NUMBER, p_pagada CHAR) RETURN NUMBER IS
        v_ref_cuota REF Tipo_InfoCuota;
    BEGIN
        SELECT REF(c) INTO v_ref_cuota FROM Tabla_InfoCuota c WHERE ejercicio = p_ejercicio;
        INSERT INTO TABLE(SELECT cuotas FROM Tabla_Socio WHERE id = p_id_socio) 
        VALUES (Tipo_CuotasPagafas(v_ref_cuota, p_pagada));
        COMMIT;
        RETURN 0;
    EXCEPTION WHEN OTHERS THEN ROLLBACK; RETURN -1;
    END;

    FUNCTION obtenerRazasPorEspecie(p_nombre_especie VARCHAR2) RETURN Lista_Nombres IS
        v_lista Lista_Nombres := Lista_Nombres();
    BEGIN
        SELECT r.nombre_raza 
        BULK COLLECT INTO v_lista
        FROM Tabla_Razas r
        JOIN Tabla_Especies e ON r.id_especie = e.id_especie
        WHERE UPPER(e.nombre_especie) = UPPER(p_nombre_especie);
        RETURN v_lista;
    EXCEPTION WHEN OTHERS THEN
        RETURN Lista_Nombres(); 
    END obtenerRazasPorEspecie;

    FUNCTION obtenerEspeciePorRaza(p_nombre_raza VARCHAR2) RETURN VARCHAR2 IS
        v_nombre_especie VARCHAR2(50);
    BEGIN
        SELECT e.nombre_especie INTO v_nombre_especie
        FROM Tabla_Especies e
        JOIN Tabla_Razas r ON e.id_especie = r.id_especie
        WHERE UPPER(r.nombre_raza) = UPPER(p_nombre_raza);
        RETURN v_nombre_especie;
    EXCEPTION WHEN OTHERS THEN
        RETURN 'No encontrado';
    END obtenerEspeciePorRaza;

END funcionesRefugio;
/