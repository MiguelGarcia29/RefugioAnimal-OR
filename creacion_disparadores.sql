-- Trigger 1: Impedir adopción si el animal no está 'Disponible'
CREATE OR REPLACE TRIGGER TRG_VALIDAR_ADOPCION
BEFORE INSERT ON Adopciones
FOR EACH ROW
DECLARE
    v_estado VARCHAR2(20);
BEGIN
    SELECT estado INTO v_estado FROM Animales WHERE id_animal = :NEW.id_animal;
    
    IF v_estado != 'Disponible' THEN
        RAISE_APPLICATION_ERROR(-20001, 'El animal no se puede adoptar porque su estado es: ' || v_estado);
    END IF;
END;
/

-- Trigger 2: Cambiar estado del animal automáticamente tras adoptar
CREATE OR REPLACE TRIGGER TRG_ACTUALIZAR_ESTADO
AFTER INSERT ON Adopciones
FOR EACH ROW
BEGIN
    UPDATE Animales 
    SET estado = 'Adoptado' 
    WHERE id_animal = :NEW.id_animal;
END;
/