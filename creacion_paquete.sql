CREATE OR REPLACE PACKAGE PKG_GESTION_PROTECTORA AS
    -- Función para ver si un adoptante es apto
    FUNCTION ES_APTO_PARA_PERRO_GRANDE(p_dni VARCHAR2) RETURN BOOLEAN;
    
    -- Procedimiento para registrar entrada de animal
    PROCEDURE REGISTRAR_ENTRADA_PERRO(p_nombre VARCHAR2, p_raza VARCHAR2, p_sexo CHAR);
END PKG_GESTION_PROTECTORA;
/

CREATE OR REPLACE PACKAGE BODY PKG_GESTION_PROTECTORA AS

    FUNCTION ES_APTO_PARA_PERRO_GRANDE(p_dni VARCHAR2) RETURN BOOLEAN IS
        v_vivienda VARCHAR2(20);
    BEGIN
        -- Tratamos la tabla de objetos Personas como una tabla de Adoptante_T
        SELECT TREAT(VALUE(p) AS Adoptante_T).vivienda_tipo 
        INTO v_vivienda
        FROM Personas p 
        WHERE dni = p_dni;
        
        RETURN (v_vivienda = 'Casa con jardín');
    EXCEPTION
        WHEN OTHERS THEN RETURN FALSE;
    END;

    PROCEDURE REGISTRAR_ENTRADA_PERRO(p_nombre VARCHAR2, p_raza VARCHAR2, p_sexo CHAR) IS
    BEGIN
        INSERT INTO Animales VALUES (
            Perro_T(SEQ_ANIMALES.NEXTVAL, p_nombre, SYSDATE, p_sexo, 'Disponible', p_raza, 'N')
        );
        COMMIT;
    END;

END PKG_GESTION_PROTECTORA;
/