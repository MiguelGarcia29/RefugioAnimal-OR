DECLARE
    v_resultado NUMBER;
BEGIN
    -- Crear cuota 2024 a 30€
    v_resultado := funcionesRefugio.insertarCuota(2024, 30.00);
    
    -- Crear socio
    v_resultado := funcionesRefugio.insertarSocio('María Gómez', TO_DATE('1992-03-10', 'YYYY-MM-DD'), '11223344C', 'Calle Luna 2', '600111222');
    
    -- Asignarle la cuota del 2024 al socio con ID 1, y marcarla como No Pagada ('N')
    -- v_resultado := funcionesRefugio.asignarCuotaSocio(1, 2024, 'N');
END;
/

INSERT INTO Tabla_InfoCuota VALUES (Tipo_InfoCuota(2026, 40.00));
COMMIT;

SELECT 
    s.id AS ID_Socio,
    s.nombre AS Nombre_Socio,
    s.dni AS DNI,
    DEREF(c.cuotaPagada).ejercicio AS Ejercicio_Cuota,
    DEREF(c.cuotaPagada).importe AS Importe_Euros,
    c.pagada AS Estado_Pago
FROM 
    Tabla_Socio s, 
    TABLE(s.cuotas) c
WHERE 
    s.id = 1;
/

SELECT     s.nombre,    s.dni,    COUNT(DEREF(c.cuotaPagada).ejercicio) AS Cuotas_Pendientes FROM     Tabla_Socio s,    TABLE(s.cuotas) c WHERE     c.pagada = 'N' GROUP BY     s.nombre,     s.dni ORDER BY s.nombre;