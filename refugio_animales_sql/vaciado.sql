SET SERVEROUTPUT ON;
BEGIN
   -- Forzamos una inserción manual para ver el error real de Oracle
   INSERT INTO Tabla_Vacuna (id, nombre, esEsencial, especie) 
   VALUES (seq_vacuna.NEXTVAL, 'DEBUG', 'S', 'Perro');
   
   INSERT INTO Table_Animal (id, nombre, fechaNacimiento, especie, raza, color, sexo, fechaLLegada, Dosis)
   VALUES (seq_id_animal.NEXTVAL, 'DEBUG_ANIMAL', SYSDATE-10, 'Perro', 'Raza', 'Negro', 'M', SYSDATE, Tipo_Lista_Dosis());
   
   COMMIT;
   DBMS_OUTPUT.PUT_LINE('Inserción manual exitosa. Si llegas aquí, las tablas funcionan.');
END;
/