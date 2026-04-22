INSERT INTO Tabla_Vacuna VALUES (seq_vacuna.NEXTVAL, 'Rabia', 'S');
INSERT INTO Tabla_Vacuna VALUES (seq_vacuna.NEXTVAL, 'Parvovirus', 'S');
INSERT INTO Tabla_Vacuna VALUES (seq_vacuna.NEXTVAL, 'Leucemia Felina', 'N');
INSERT INTO Tabla_Vacuna VALUES (seq_vacuna.NEXTVAL, 'Moquillo', 'S');

INSERT INTO Table_Animal VALUES (
    seq_id_animal.NEXTVAL, 
    'Rex', 
    TO_DATE('2022-05-15', 'YYYY-MM-DD'), 
    'Perro', 
    'Pastor Alemán', 
    'Negro/Fuego', 
    'M', 
    SYSDATE, 
    'Muy juguetón y protector', 
    NULL, -- Aún no adoptado
    Tipo_Lista_Dosis(
        Tipo_Dosis(TO_DATE('2023-01-10', 'YYYY-MM-DD'), (SELECT REF(v) FROM Tabla_Vacuna v WHERE v.nombre = 'Rabia')),
        Tipo_Dosis(TO_DATE('2023-03-20', 'YYYY-MM-DD'), (SELECT REF(v) FROM Tabla_Vacuna v WHERE v.nombre = 'Parvovirus'))
    )
);

INSERT INTO Table_Animal VALUES (
    seq_id_animal.NEXTVAL, 
    'Luna', 
    TO_DATE('2023-08-01', 'YYYY-MM-DD'), 
    'Gato', 
    'Siamés', 
    'Blanco/Gris', 
    'F', 
    SYSDATE, 
    'Tranquila, le gusta dormir al sol', 
    NULL, 
    Tipo_Lista_Dosis() -- Lista vacía
);


SELECT a.nombre, a.especie, a.edad() as edad_actual
FROM Table_Animal a;

SELECT a.nombre as Mascota, d.fechaAdministracion, DEREF(d.vacuna).nombre as Nombre_Vacuna
FROM Table_Animal a, TABLE(a.Dosis) d
WHERE a.nombre = 'Rex';