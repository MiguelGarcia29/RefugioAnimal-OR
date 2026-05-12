-- 06_insercion.sql
-- Carga masiva de datos utilizando exclusivamente el Package funcionesRefugio
SET SERVEROUTPUT ON;

DECLARE
    -- Variables para capturar resultados de funciones
    v_res NUMBER;
    
    -- Variables para IDs (necesarias para mantener las relaciones)
    v_id_perro    NUMBER;
    v_id_gato     NUMBER;
    v_id_conejo   NUMBER;
    
    v_r_lab       NUMBER;
    v_r_pastor    NUMBER;
    v_r_beagle    NUMBER;
    v_r_siames    NUMBER;
    v_r_comun     NUMBER;
    v_r_angora    NUMBER;
    
    v_v_rabia     NUMBER;
    v_v_parvo     NUMBER;
    v_v_tri_fel   NUMBER;
    
    -- Cursores para obtener IDs generados por las secuencias tras la inserción
    -- (Ya que las funciones del paquete retornan 0/-1 y no el ID generado)
    FUNCTION obtener_id_especie(p_nom VARCHAR2) RETURN NUMBER IS
        l_id NUMBER;
    BEGIN
        SELECT id_especie INTO l_id FROM Tabla_Especies WHERE nombre_especie = p_nom;
        RETURN l_id;
    END;

    FUNCTION obtener_id_raza(p_nom VARCHAR2) RETURN NUMBER IS
        l_id NUMBER;
    BEGIN
        SELECT id_raza INTO l_id FROM Tabla_Razas WHERE nombre_raza = p_nom;
        RETURN l_id;
    END;

    FUNCTION obtener_id_vacuna(p_nom VARCHAR2) RETURN NUMBER IS
        l_id NUMBER;
    BEGIN
        SELECT id INTO l_id FROM Tabla_Vacuna WHERE nombre = p_nom;
        RETURN l_id;
    END;

BEGIN
    DBMS_OUTPUT.PUT_LINE('Iniciando carga de datos via Package...');

    ----------------------------------------------------------------            
    -- 1. ESPECIES
    ----------------------------------------------------------------
    v_res := funcionesRefugio.insertarEspecie('Perro');
    v_res := funcionesRefugio.insertarEspecie('Gato');
    v_res := funcionesRefugio.insertarEspecie('Conejo');
    
    v_id_perro  := obtener_id_especie('Perro');
    v_id_gato   := obtener_id_especie('Gato');
    v_id_conejo := obtener_id_especie('Conejo');

    ----------------------------------------------------------------
    -- 2. RAZAS
    ----------------------------------------------------------------
    v_res := funcionesRefugio.insertarRaza('Labrador', v_id_perro);
    v_res := funcionesRefugio.insertarRaza('Pastor Aleman', v_id_perro);
    v_res := funcionesRefugio.insertarRaza('Beagle', v_id_perro);
    v_res := funcionesRefugio.insertarRaza('Siames', v_id_gato);
    v_res := funcionesRefugio.insertarRaza('Comun Europeo', v_id_gato);
    v_res := funcionesRefugio.insertarRaza('Angora', v_id_conejo);

    v_r_lab    := obtener_id_raza('Labrador');
    v_r_pastor := obtener_id_raza('Pastor Aleman');
    v_r_beagle := obtener_id_raza('Beagle');
    v_r_siames := obtener_id_raza('Siames');
    v_r_comun  := obtener_id_raza('Comun Europeo');
    v_r_angora := obtener_id_raza('Angora');

    ----------------------------------------------------------------
    -- 3. VACUNAS (Las 'S' dispararán dosis automáticas al crear animales)
    ----------------------------------------------------------------
    v_res := funcionesRefugio.crearVacuna('Rabia Canina', 'S', v_id_perro);
    v_res := funcionesRefugio.crearVacuna('Parvovirus', 'S', v_id_perro);
    v_res := funcionesRefugio.crearVacuna('Trivalente Felina', 'S', v_id_gato);
    v_res := funcionesRefugio.crearVacuna('Mixomatosis', 'S', v_id_conejo);
    v_res := funcionesRefugio.crearVacuna('Tos de las Perreras', 'N', v_id_perro);

    v_v_rabia   := obtener_id_vacuna('Rabia Canina');
    v_v_parvo   := obtener_id_vacuna('Parvovirus');
    v_v_tri_fel := obtener_id_vacuna('Trivalente Felina');

    ----------------------------------------------------------------
    -- 4. SOCIOS (6 socios)
    ----------------------------------------------------------------
    v_res := funcionesRefugio.insertarSocio('Carlos Sainz', TO_DATE('1970-04-12','YYYY-MM-DD'), '11122233A', 'Paseo Castellana 10', '600100200');
    v_res := funcionesRefugio.insertarSocio('Marta Garcia', TO_DATE('1985-06-25','YYYY-MM-DD'), '44455566B', 'Calle Mayor 5', '600300400');
    v_res := funcionesRefugio.insertarSocio('Luis Hamilton', TO_DATE('1982-01-07','YYYY-MM-DD'), '77788899C', 'Av. Libertad 100', '600500600');
    v_res := funcionesRefugio.insertarSocio('Elena Nito', TO_DATE('1990-11-30','YYYY-MM-DD'), '12312312D', 'Calle Falsa 123', '600700800');
    v_res := funcionesRefugio.insertarSocio('Pablo Escobar', TO_DATE('1975-12-01','YYYY-MM-DD'), '98798798E', 'Hacienda Napoles', '600900100');
    v_res := funcionesRefugio.insertarSocio('Sara Carbonero', TO_DATE('1984-02-03','YYYY-MM-DD'), '45645645F', 'Plaza España 1', '600200300');

    ----------------------------------------------------------------
    -- 5. CUOTAS (Asignación automática a todos los socios vía Trigger)
    ----------------------------------------------------------------
    v_res := funcionesRefugio.insertarCuota(2023, 40.00);
    v_res := funcionesRefugio.insertarCuota(2024, 45.00);

    -- Marcar pagos manuales usando la función del paquete
    FOR r IN (SELECT id FROM Tabla_Socio WHERE dni IN ('11122233A', '44455566B')) LOOP
        v_res := funcionesRefugio.asignarCuotaSocio(r.id, 2023, 'S');
        v_res := funcionesRefugio.asignarCuotaSocio(r.id, 2024, 'S');
    END LOOP;

    ----------------------------------------------------------------
    -- 6. ANIMALES (15 animales)
    ----------------------------------------------------------------
    -- Perros
    v_res := funcionesRefugio.insertarAnimal('Rex', TO_DATE('2020-01-01','YYYY-MM-DD'), v_r_pastor, 'Negro/Fuego', 'M', SYSDATE-400, 'Entrenado');
    v_res := funcionesRefugio.insertarAnimal('Toby', TO_DATE('2021-05-10','YYYY-MM-DD'), v_r_beagle, 'Tricolor', 'M', SYSDATE-300, 'Muy activo');
    v_res := funcionesRefugio.insertarAnimal('Lassie', TO_DATE('2019-08-15','YYYY-MM-DD'), v_r_pastor, 'Marron/Blanco', 'F', SYSDATE-500, 'Famosa');
    v_res := funcionesRefugio.insertarAnimal('Bud', TO_DATE('2022-03-20','YYYY-MM-DD'), v_r_lab, 'Dorado', 'M', SYSDATE-200, 'Jugador');
    v_res := funcionesRefugio.insertarAnimal('Kira', TO_DATE('2021-11-11','YYYY-MM-DD'), v_r_beagle, 'Blanco', 'F', SYSDATE-150, 'Miedosa');
    v_res := funcionesRefugio.insertarAnimal('Balto', TO_DATE('2018-02-28','YYYY-MM-DD'), v_r_pastor, 'Gris', 'M', SYSDATE-600, 'Heroico');
    v_res := funcionesRefugio.insertarAnimal('Nana', TO_DATE('2023-01-01','YYYY-MM-DD'), v_r_lab, 'Chocolate', 'F', SYSDATE-50, 'Cachorra');
    v_res := funcionesRefugio.insertarAnimal('Hachiko', TO_DATE('2020-05-05','YYYY-MM-DD'), v_r_pastor, 'Crema', 'M', SYSDATE-450, 'Fiel');

    -- Gatos
    v_res := funcionesRefugio.insertarAnimal('Garfield', TO_DATE('2017-06-19','YYYY-MM-DD'), v_r_comun, 'Naranja', 'M', SYSDATE-700, 'Gordo y perezoso');
    v_res := funcionesRefugio.insertarAnimal('Tom', TO_DATE('2021-02-10','YYYY-MM-DD'), v_r_siames, 'Gris/Azul', 'M', SYSDATE-300, 'Persigue ratones');
    v_res := funcionesRefugio.insertarAnimal('Duquesa', TO_DATE('2020-12-25','YYYY-MM-DD'), v_r_siames, 'Blanco', 'F', SYSDATE-400, 'Distinguida');
    v_res := funcionesRefugio.insertarAnimal('Figaro', TO_DATE('2022-09-12','YYYY-MM-DD'), v_r_comun, 'Negro/Blanco', 'M', SYSDATE-180, 'Pequeño');
    v_res := funcionesRefugio.insertarAnimal('Silvestre', TO_DATE('2019-04-01','YYYY-MM-DD'), v_r_comun, 'Negro', 'M', SYSDATE-500, 'Sisea mucho');

    -- Conejos
    v_res := funcionesRefugio.insertarAnimal('Tambor', TO_DATE('2023-06-01','YYYY-MM-DD'), v_r_angora, 'Gris', 'M', SYSDATE-100, 'Salta mucho');
    v_res := funcionesRefugio.insertarAnimal('Bugs', TO_DATE('2022-01-01','YYYY-MM-DD'), v_r_angora, 'Gris/Blanco', 'M', SYSDATE-300, 'Come zanahorias');

    ----------------------------------------------------------------
    -- 7. DOSIS MANUALES Y REFUERZOS
    ----------------------------------------------------------------
    -- Añadir dosis de refuerzo a un animal específico
    FOR r IN (SELECT id FROM Table_Animal WHERE nombre = 'Rex') LOOP
        v_res := funcionesRefugio.suministrarDosis(r.id, v_v_rabia, SYSDATE-90);
    END LOOP;

    ----------------------------------------------------------------
    -- 8. ADOPCIONES Y GESTIÓN DE ESTADO
    ----------------------------------------------------------------
    FOR r IN (SELECT id FROM Table_Animal WHERE nombre IN ('Balto', 'Duquesa')) LOOP
        v_res := funcionesRefugio.adoptarAnimal(r.id);
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Carga masiva finalizada con éxito.');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error en la carga: ' || SQLERRM);
END;
/