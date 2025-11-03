# REPASO-INTEGRAL-FUNDAMENTOS-Y-BD-RELACIONALES
# 🎓 Sistema de Gestión Académica – Proyecto Final de Base de Datos

**Autores:** Jairo Rincón - Camilo Cuvides
**Institución:** Fundación de Estudios Superiores Comfanorte (FESC)  
**Programa:** Ingeniería de Software  
**Año:** 2025  

---

## Descripción General

Este proyecto presenta el desarrollo completo de un **Sistema de Gestión Académica** implementado en **MySQL Workbench**, cuyo propósito es modelar, estructurar y automatizar los procesos académicos de una universidad.  

El sistema permite administrar **departamentos, profesores, estudiantes, asignaturas, cursos, inscripciones y calificaciones**, incorporando mecanismos automáticos de cálculo de promedios, control de integridad y recuperación de datos.

El trabajo se enfoca en aplicar los conceptos aprendidos durante el curso de **Base de Datos**, incluyendo diseño relacional, normalización, creación de triggers, vistas, consultas avanzadas y control de concurrencia.

---

## Objetivos del Proyecto

### Objetivo General
Diseñar e implementar una base de datos relacional que permita gestionar la información académica de una institución educativa, aplicando principios de integridad, eficiencia y consistencia de datos.

### Objetivos Específicos
- Modelar las entidades y relaciones académicas mediante un diagrama ER normalizado.  
- Crear la base de datos en MySQL siguiendo buenas prácticas de diseño relacional.  
- Implementar **triggers** y **vistas** para la automatización de procesos.  
- Desarrollar consultas SQL complejas para el análisis y la generación de reportes.  
- Aplicar mecanismos de **control de concurrencia y recuperación ante fallos**.  

---

## Características Principales

- **Estructura relacional completa** con claves primarias y foráneas.  
- **Triggers automáticos** para actualización de promedios y validaciones.  
- **Vistas y reportes** de cursos, estudiantes y promedios.  
- **Simulación de fallos y recuperación** con técnicas de logging y checkpoints.  
- **Control de concurrencia** mediante bloqueos y transacciones.  
- **Consultas analíticas** usando funciones de agregación y CTEs.  
- **Modelo relacional documentado** con diagrama ER en formato Mermaid.

---

## Estructura del Sistema

| Componente | Descripción |
|-------------|-------------|
| **Departamentos** | Agrupan asignaturas y profesores. |
| **Profesores** | Docentes asignados a cursos específicos. |
| **Estudiantes** | Participantes inscritos en cursos. |
| **Asignaturas** | Materias o módulos de enseñanza. |
| **Cursos** | Secciones dictadas por profesores. |
| **Inscripciones** | Registro de estudiantes en cursos. |
| **Calificaciones** | Notas obtenidas por los estudiantes. |
| **Promedios_curso** | Tabla auxiliar con promedio actualizado por trigger. |

---

## Automatizaciones (Triggers)

El sistema incluye varios **triggers** que garantizan la consistencia de los datos:

- `trg_promedio_after_insert` → Calcula automáticamente el promedio del curso al insertar una nueva calificación.  
- `trg_promedio_after_update` → Recalcula el promedio cuando se modifica una nota existente.  
- `trg_promedio_after_delete` → Actualiza o elimina el promedio cuando se borra una calificación.  
- Validaciones de notas (0–5), fechas válidas y restricciones de duplicado.  

---

## Resultados Obtenidos

- Base de datos completamente funcional en **MySQL Workbench**.  
- Triggers probados y verificados con datos de ejemplo.  
- Consultas avanzadas de rendimiento y agrupación por promedio.  
- Recuperación ante fallos simulada con logs y checkpoints.  
- Generación automática de promedios por curso y estudiante.

---

## Tecnologías Utilizadas

| Herramienta | Uso Principal |
|--------------|---------------|
| **MySQL Server 8.0+** | Motor principal de base de datos |
| **MySQL Workbench** | Entorno visual y modelado ER |
| **Mermaid / Draw.io** | Diagramas entidad-relación |
| **SQL (DDL/DML/DCL)** | Lenguaje principal de implementación |

---

## Archivos Incluidos

| Archivo | Descripción |
|----------|-------------|
| `gestion_academica.sql` | Script completo del proyecto con tablas, vistas, triggers y datos de prueba. |
| `README_INSTALACION.md` | Guía paso a paso de instalación y ejecución del sistema. |
| `evidencias/` | Carpeta con capturas de pruebas, resultados y verificaciones. |
| `diagramas/` | Diagramas ER y modelos relacionales. |


---

## 📫 Autores

**Andrés Rincón**  
Estudiante de Ingeniería de Sistemas – FESC  

**Camilo Cuvides**  
Estudiante de Ingeniería de Sistemas – FESC  
