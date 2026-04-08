-- Tabla de Objetos para Personas (almacena Adoptantes y Voluntarios)
CREATE TABLE Personas OF Persona_T (
    dni PRIMARY KEY
);

-- Tabla de Objetos para Animales (almacena Perros y Gatos)
CREATE TABLE Animales OF Animal_T (
    id_animal PRIMARY KEY
);

-- Tabla Relacional para Vacunas (Control de salud)
CREATE TABLE Vacunas (
    id_vacuna NUMBER PRIMARY KEY,
    id_animal NUMBER REFERENCES Animales(id_animal),
    nombre_vacuna VARCHAR2(50),
    fecha_administracion DATE,
    proxima_dosis DATE
);

-- Tabla de Adopciones
CREATE TABLE Adopciones (
    id_adopcion NUMBER PRIMARY KEY,
    dni_adoptante VARCHAR2(9) REFERENCES Personas(dni),
    id_animal NUMBER REFERENCES Animales(id_animal),
    fecha_adopcion DATE DEFAULT SYSDATE,
    contrato_firmado CHAR(1) CHECK (contrato_firmado IN ('S', 'N'))
);