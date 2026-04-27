SET SERVEROUTPUT ON;

DECLARE
    v_res NUMBER;
BEGIN
    -- Intentamos crear una vacuna esencial (por ejemplo, la de la Rabia)
    v_res := funcionesRefugio.crearVacuna(
        p_nombre    => 'Rabia Aprobadora',
        p_esEsencial => 'N' -- 'S' para Sí, 'N' para No
    );

    IF v_res = 0 THEN
        DBMS_OUTPUT.PUT_LINE('✅ Vacuna creada exitosamente.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('❌ Error al crear la vacuna.');
    END IF;
    
END;
/

SELECT * FROM Tabla_Vacuna;