-- 05_disparadores.sql corregido
CREATE OR REPLACE TRIGGER Trigger_SuministrarEsenciales
BEFORE INSERT ON Table_Animal
FOR EACH ROW
DECLARE
    -- Buscamos las referencias de las vacunas esenciales
    CURSOR c_vacunas IS
        SELECT REF(v) as ref_v
        FROM Tabla_Vacuna v
        WHERE v.esEsencial = 'S' 
        AND UPPER(v.especie) = UPPER(:NEW.especie);
BEGIN
    -- Inicializamos la colección si viene nula (por si acaso)
    IF :NEW.Dosis IS NULL THEN
        :NEW.Dosis := Tipo_Lista_Dosis();
    END IF;

    -- Añadimos las dosis directamente al objeto :NEW antes de que se guarde en disco
    FOR r IN c_vacunas LOOP
        :NEW.Dosis.EXTEND;
        :NEW.Dosis(:NEW.Dosis.LAST) := Tipo_Dosis(SYSDATE, r.ref_v);
    END LOOP;
END;
/

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
            SELECT REF(c) INTO v_ref_cuota FROM Tabla_InfoCuota c WHERE ejercicio = v_ejercicio;
            FOR r_socio IN (SELECT id FROM Tabla_Socio) LOOP
                INSERT INTO TABLE(SELECT cuotas FROM Tabla_Socio WHERE id = r_socio.id)
                VALUES (Tipo_CuotasPagafas(v_ref_cuota, 'N'));
            END LOOP;
        END IF;
    END AFTER STATEMENT;
END Trigger_AsignarCuotas;
/