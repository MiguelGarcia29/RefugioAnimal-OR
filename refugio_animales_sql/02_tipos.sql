-- Creación de Tipos de Objeto
CREATE OR REPLACE TYPE Tipo_Vacuna AS OBJECT(
    id NUMBER,
    nombre VARCHAR2(50),
    esEsencial CHAR(1),
    especie VARCHAR2(50)
);
/

CREATE OR REPLACE TYPE Tipo_Dosis AS OBJECT(
    fechaAdministracion DATE,
    vacuna REF Tipo_Vacuna
);
/

CREATE OR REPLACE TYPE Tipo_Lista_Dosis AS TABLE OF Tipo_Dosis;
/

CREATE OR REPLACE TYPE Tipo_Animal AS OBJECT(
    id NUMBER,
    nombre VARCHAR2(50),
    fechaNacimiento DATE,
    especie VARCHAR2(50),
    raza VARCHAR2(50),
    color VARCHAR2(20),
    sexo CHAR(1),
    fechaLLegada DATE,
    caracteristicas VARCHAR2(200),
    fechaAdopcion DATE,
    Dosis Tipo_Lista_Dosis,
    MEMBER FUNCTION edad RETURN NUMBER
) NOT FINAL; 
/

CREATE OR REPLACE TYPE BODY Tipo_Animal IS
    MEMBER FUNCTION edad RETURN NUMBER IS
        fechaActual DATE := SYSDATE;
    BEGIN
        RETURN FLOOR(MONTHS_BETWEEN(fechaActual, fechaNacimiento)/12);
    END edad;
END;
/

CREATE OR REPLACE TYPE Tipo_InfoCuota AS OBJECT(
    ejercicio NUMBER(4),
    importe NUMBER(6,2)
);
/

CREATE OR REPLACE TYPE Tipo_CuotasPagafas AS OBJECT (
    cuotaPagada REF Tipo_InfoCuota,
    pagada CHAR(1)
);
/

CREATE OR REPLACE TYPE Tabla_CuotasPagadas AS TABLE OF Tipo_CuotasPagafas;
/

CREATE OR REPLACE TYPE Tipo_Socio AS OBJECT(
    id NUMBER,
    nombre VARCHAR2(50),
    fechaNacimiento DATE,
    dni VARCHAR2(10),
    direccion VARCHAR2(100),
    telefono VARCHAR2(15),
    cuotas Tabla_CuotasPagadas
) NOT FINAL; 
/
