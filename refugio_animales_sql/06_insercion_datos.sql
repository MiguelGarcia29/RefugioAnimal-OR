-- Inserción Masiva de Datos para el Refugio
DECLARE
    v_res NUMBER;
    v_id_animal NUMBER;
    v_id_socio  NUMBER;
    v_id_vacuna NUMBER;
BEGIN
    -- 1. INSERTAR VARIEDAD DE VACUNAS
    v_res := funcionesRefugio.crearVacuna('Rabia Canina', 'S', 'Perro'); -- ID 1 aprox
    v_res := funcionesRefugio.crearVacuna('Leucemia Felina', 'S', 'Gato'); -- ID 2
    v_res := funcionesRefugio.crearVacuna('Parvovirus', 'N', 'Perro');    -- ID 3
    v_res := funcionesRefugio.crearVacuna('Moquillo', 'S', 'Perro');      -- ID 4
    v_res := funcionesRefugio.crearVacuna('Gripe Felina', 'N', 'Gato');   -- ID 5
    v_res := funcionesRefugio.crearVacuna('Polivalente', 'S', 'Perro');   -- ID 6

    -- 2. INSERTAR SOCIOS
    v_res := funcionesRefugio.insertarSocio('Juan Perez', TO_DATE('1985-05-20','YYYY-MM-DD'), '12345678X', 'Calle Mayor 1', '600111222'); -- ID 1
    v_res := funcionesRefugio.insertarSocio('Maria Lopez', TO_DATE('1990-11-10','YYYY-MM-DD'), '87654321Y', 'Plaza Sol 5', '600333444');  -- ID 2
    v_res := funcionesRefugio.insertarSocio('Carlos Ruiz', TO_DATE('1978-03-15','YYYY-MM-DD'), '11223344Z', 'Av. Libertad 10', '655999888'); -- ID 3
    v_res := funcionesRefugio.insertarSocio('Ana Belen', TO_DATE('1995-07-30','YYYY-MM-DD'), '55667788K', 'Calle Luna 4', '622777111');    -- ID 4
    v_res := funcionesRefugio.insertarSocio('Pedro Marmol', TO_DATE('1982-12-01','YYYY-MM-DD'), '99001122M', 'Calle Roca 12', '611000222'); -- ID 5

    -- 3. INSERTAR ANIMALES (Algunos ya vienen con vacunas esenciales por el Trigger)
    -- Perro adoptado y vacunado extra
    v_res := funcionesRefugio.insertarAnimal('Rex', TO_DATE('2020-01-01','YYYY-MM-DD'), 'Perro', 'Pastor Alemán', 'Negro/Fuego', 'M', TO_DATE('2023-01-10','YYYY-MM-DD'), 'Muy amigable');
    -- Obtenemos el ID (asumimos 1 por la secuencia limpia) y le ponemos vacuna extra y adopción
    v_res := funcionesRefugio.suministrarDosis(1, 3, SYSDATE); -- Dosis extra de Parvovirus
    v_res := funcionesRefugio.adoptarAnimal(1);

    -- Perro no adoptado, pero muy vacunado
    v_res := funcionesRefugio.insertarAnimal('Toby', TO_DATE('2019-05-05','YYYY-MM-DD'), 'Perro', 'Beagle', 'Tricolor', 'M', TO_DATE('2023-05-15','YYYY-MM-DD'), 'Cazador y juguetón');
    v_res := funcionesRefugio.suministrarDosis(2, 6, SYSDATE-30); -- Polivalente

    -- Gato adoptado
    v_res := funcionesRefugio.insertarAnimal('Luna', TO_DATE('2021-06-15','YYYY-MM-DD'), 'Gato', 'Común', 'Blanco', 'H', TO_DATE('2023-08-20','YYYY-MM-DD'), 'Tranquila');
    v_res := funcionesRefugio.adoptarAnimal(3);

    -- Más perros y gatos para volumen
    v_res := funcionesRefugio.insertarAnimal('Kira', TO_DATE('2022-02-02','YYYY-MM-DD'), 'Perro', 'Golden Retriever', 'Dorado', 'H', SYSDATE-5, 'Cachorra activa');
    v_res := funcionesRefugio.insertarAnimal('Simba', TO_DATE('2018-10-10','YYYY-MM-DD'), 'Gato', 'Persa', 'Naranja', 'M', SYSDATE-100, 'Muy peludo');
    v_res := funcionesRefugio.insertarAnimal('Balto', TO_DATE('2015-12-25','YYYY-MM-DD'), 'Perro', 'Husky', 'Gris', 'M', SYSDATE-200, 'Viejo pero noble');
    v_res := funcionesRefugio.insertarAnimal('Misi', TO_DATE('2023-01-01','YYYY-MM-DD'), 'Gato', 'Siames', 'Crema', 'H', SYSDATE-1, 'Maúlla mucho');

    -- 4. GESTIÓN DE CUOTAS
    -- Creamos ejercicios de cuotas (El Trigger las asignará como 'N' a todos los socios)
    v_res := funcionesRefugio.insertarCuota(2022, 45.00);
    v_res := funcionesRefugio.insertarCuota(2023, 48.50);
    v_res := funcionesRefugio.insertarCuota(2024, 50.00);

    -- 5. MARCAR CUOTAS COMO PAGADAS (Simulamos pagos de socios)
    -- Juan Perez (ID 1) paga todo
    UPDATE TABLE(SELECT s.cuotas FROM Tabla_Socio s WHERE s.id = 1) c 
    SET c.pagada = 'S';

    -- Maria Lopez (ID 2) paga 2022 y 2023
    UPDATE TABLE(SELECT s.cuotas FROM Tabla_Socio s WHERE s.id = 2) c 
    SET c.pagada = 'S'
    WHERE DEREF(c.cuotaPagada).ejercicio IN (2022, 2023);

    -- Carlos Ruiz (ID 3) solo paga 2022
    UPDATE TABLE(SELECT s.cuotas FROM Tabla_Socio s WHERE s.id = 3) c 
    SET c.pagada = 'S'
    WHERE DEREF(c.cuotaPagada).ejercicio = 2022;
    
    -- Ana Belen (ID 4) no ha pagado nada (se queda 'N' por defecto del trigger)

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Carga masiva completada con éxito.');
EXCEPTION 
    WHEN OTHERS THEN 
        ROLLBACK; 
        DBMS_OUTPUT.PUT_LINE('Error en carga masiva: ' || SQLERRM);
END;
/
