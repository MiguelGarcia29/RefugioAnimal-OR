DECLARE
    v_res NUMBER;
BEGIN
    -- Suponiendo que el Animal ID es 1 y la Vacuna ID es 1
    v_res := funcionesRefugio.suministrarDosis(
        p_id_animal => 1, 
        p_id_vacuna => 1, 
        p_fecha     => SYSDATE
    );

    IF v_res = 0 THEN
        DBMS_OUTPUT.PUT_LINE('✅ Dosis registrada en el historial del animal.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('❌ Error: Verifica que los IDs existan.');
    END IF;
END;
/

SELECT DEREF(vacuna).nombre as nombre_vacuna, fechaAdministracion
FROM TABLE(SELECT Dosis FROM Table_Animal WHERE id = 1);