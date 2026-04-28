SET SERVEROUTPUT ON;

DECLARE
    v_resultado NUMBER;
BEGIN
    -- Llamamos a la función y guardamos el resultado en v_resultado
    v_resultado := funcionesRefugio.insertarAnimal(
        p_nombre           => 'Toby',
        p_fechaNacimiento  => TO_DATE('2021-03-10', 'YYYY-MM-DD'),
        p_especie          => 'Perro',
        p_raza             => 'Golden Retriever',
        p_color            => 'Dorado',
        p_sexo             => 'M',
        p_fechaLlegada     => SYSDATE,
        p_caracteristicas  => 'Muy amigable y le gusta jugar con pelotas'
    );

    -- Comprobamos si funcionó según la lógica de 0 y -1
    IF v_resultado = 0 THEN
        DBMS_OUTPUT.PUT_LINE('✅ Animal insertado correctamente.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('❌ Error al insertar el animal.');
    END IF;
END;
/

-- Consulta para ver los datos básicos y la edad calculada
SELECT 
    id, 
    nombre, 
    especie, 
    raza, 
    a.edad() as edad_actual, 
    fechaLLegada 
FROM Table_Animal a;