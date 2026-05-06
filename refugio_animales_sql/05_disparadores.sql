-- Creación de Disparadores
CREATE OR REPLACE TRIGGER Trigger_SuministrarEsenciales
AFTER INSERT ON Table_Animal
FOR EACH ROW
DECLARE
    CURSOR c_vacunas_esenciales IS
        SELECT REF(v) as ref_v
        FROM Tabla_Vacuna v
        WHERE v.esEsencial = 'S' 
        AND UPPER(v.especie) = UPPER(:NEW.especie);
BEGIN
    FOR r_vacuna IN c_vacunas_esenciales LOOP
        INSERT INTO TABLE(SELECT a.Dosis FROM Table_Animal a WHERE a.id = :NEW.id)
        VALUES (Tipo_Dosis(SYSDATE, r_vacuna.ref_v));
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
            v_ejercicio := NULL;
        END IF;
    END AFTER STATEMENT;
END Trigger_AsignarCuotas;
/
