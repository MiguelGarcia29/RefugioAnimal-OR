# 🐾 Perrera Amiguitos

Sistema de gestión para refugios de animales desarrollado bajo el paradigma **Objeto-Relacional (O/R)** utilizando **Oracle Database** y **PL/SQL**.

## 📖 Descripción

Perrera Amiguitos es una solución integral para la administración de un refugio de animales multiespecie. El sistema permite gestionar animales, procesos de adopción, historiales sanitarios, socios colaboradores y cuotas económicas, automatizando procesos críticos mediante triggers y encapsulando toda la lógica de negocio en paquetes PL/SQL.

El proyecto ha sido diseñado para aprovechar las capacidades avanzadas del modelo Objeto-Relacional de Oracle, permitiendo una representación más natural y eficiente de la información.

## ✨ Características Principales

### 🐶 Gestión de Animales

* Registro de nuevos ingresos al refugio.
* Gestión de especies y razas.
* Consulta y modificación de fichas de animales.
* Búsqueda multicriterio por especie, raza, color, sexo o disponibilidad.
* Cálculo automático de edad.

### 💉 Control Sanitario

* Vacunación automática de vacunas esenciales al ingresar un animal.
* Registro de dosis de refuerzo y vacunas opcionales.
* Consulta completa del historial clínico.

### 🏠 Gestión de Adopciones

* Selección personalizada de animales por parte del adoptante.
* Registro de adopciones.
* Actualización automática del estado de disponibilidad.

### 👥 Gestión de Socios

* Alta, baja y modificación de socios.
* Gestión de cuotas anuales.
* Control de pagos y morosidad.
* Asignación automática de nuevas cuotas a socios activos.

## 🏗️ Arquitectura del Proyecto

El sistema sigue una arquitectura basada en:

* **Oracle Object Types**
* **Object Tables**
* **Nested Tables**
* **REFs con SCOPE**
* **Paquetes PL/SQL**
* **Triggers automáticos**

### Componentes principales

| Componente                 | Función                                 |
| -------------------------- | --------------------------------------- |
| Object Types               | Representación de entidades del dominio |
| Nested Tables              | Almacenamiento de vacunas y cuotas      |
| Package `funcionesRefugio` | API principal del sistema               |
| Triggers                   | Automatización de procesos críticos     |
| Oracle Database            | Persistencia de datos                   |

## 📋 Requisitos Funcionales

### Gestión de Animales

* Alta de animales.
* Gestión de especies y razas.
* Consulta y modificación de fichas.
* Búsqueda avanzada.

### Control Sanitario

* Vacunación automática.
* Registro de dosis manuales.
* Consulta de historial médico.

### Adopciones

* Registro de adopciones.
* Cierre automático del expediente.

### Socios y Economía

* Gestión completa de socios.
* Gestión de cuotas anuales.
* Seguimiento de pagos.

## 🔧 Requisitos No Funcionales

* Modelo Objeto-Relacional Oracle.
* Uso de colecciones anidadas (Nested Tables).
* Automatización mediante triggers.
* Encapsulación de lógica en paquetes PL/SQL.
* Integridad referencial mediante REF.
* Optimización de consultas y rendimiento.

## 📦 Paquete PL/SQL: `funcionesRefugio`

El paquete centraliza toda la lógica de negocio.

### Gestión de Animales

* `insertarAnimal()`
* `actualizarAnimal()`
* `edadAnimal()`
* `borrarAnimal()`
* `adoptarAnimal()`

### Salud y Vacunas

* `crearVacuna()`
* `suministrarDosis()`

### Gestión de Socios

* `insertarSocio()`
* `insertarCuota()`
* `asignarCuotaSocio()`

### Configuración

* `obtenerRazasPorEspecie()`
* `insertarEspecie()`
* `insertarRaza()`

## ⚡ Triggers Implementados

### Trigger_SuministrarEsenciales

**Evento:** `BEFORE INSERT ON Tabla_Animal`

Automatiza el protocolo sanitario inicial asignando automáticamente las vacunas esenciales correspondientes a la especie del animal.

### Trigger_AsignarCuotas

**Evento:** `FOR INSERT ON Tabla_InfoCuota`

Automatiza la asignación de cuotas anuales a todos los socios activos mediante un Compound Trigger.

## 🚀 Instalación

### 1. Instalar dependencias

```bash
pip install -r requirements.txt
```

### 2. Crear la base de datos

Ejecutar en Oracle el script principal:

```sql
@main.sql
```

### 3. Configurar conexión

Editar el archivo:

```ini
conexion.ini
```

y completar los parámetros de conexión a Oracle.

### 4. Ejecutar la aplicación

```bash
python main.py
```

## 🎯 Ventajas del Modelo Objeto-Relacional

* Mayor cohesión de los datos.
* Reducción de joins complejos.
* Mejor representación del dominio.
* Encapsulación de comportamiento junto a los datos.
* Integridad referencial robusta mediante REF.
* Escalabilidad para futuras integraciones web o móviles.

## 👨‍💻 Autores

* Jesús Miguel García Bernal
* Jacobo Caro Luna

## 📚 Tecnologías Utilizadas

* Oracle Database
* PL/SQL
* Oracle Object-Relational Features
* Python
* Qt Designer

## 📄 Licencia

Este proyecto ha sido desarrollado con fines académicos dentro de la asignatura de Tecnologías Avanzadas de Bases de Datos (TABD).
