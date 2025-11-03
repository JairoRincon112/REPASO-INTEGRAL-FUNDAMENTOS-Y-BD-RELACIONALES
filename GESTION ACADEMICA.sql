/********************************************************************************
 * SISTEMA DE GESTIÓN ACADÉMICA - VERSIÓN FINAL COMPLETA
 * Autores: Jairo Rincón - Camilo Cuvides
 * NOTA: ejecutar en una nueva sesión. El script borra/crea la BD.
 ********************************************************************************/

-- ============================================================
-- 0) LIMPIEZA / CREACIÓN BD
-- ============================================================
DROP DATABASE IF EXISTS gestion_academica;
CREATE DATABASE gestion_academica
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
USE gestion_academica;

-- ============================================================
-- 1) DDL COMPLETO (6 ENTIDADES MÍNIMAS + AUXILIARES)
-- ============================================================

-- ----------------------------
-- Departamentos
-- ----------------------------
CREATE TABLE departamentos (
    id_departamento INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    ubicacion VARCHAR(150),
    presupuesto DECIMAL(14,2) DEFAULT 0 CHECK (presupuesto >= 0)
);

-- ----------------------------
-- Profesores
-- ----------------------------
CREATE TABLE profesores (
    id_profesor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    correo VARCHAR(200) NOT NULL UNIQUE,
    fecha_contratacion DATE NOT NULL,
    salario DECIMAL(12,2) DEFAULT 0 CHECK (salario >= 0),
    id_departamento INT,
    CONSTRAINT fk_prof_dept FOREIGN KEY (id_departamento)
        REFERENCES departamentos(id_departamento)
        ON UPDATE CASCADE ON DELETE SET NULL
);

-- ----------------------------
-- Estudiantes
-- ----------------------------
CREATE TABLE estudiantes (
    id_estudiante INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    correo VARCHAR(200) NOT NULL UNIQUE,
    fecha_nacimiento DATE NOT NULL,
    semestre INT NOT NULL CHECK (semestre BETWEEN 1 AND 10)
    -- Nota: validación de fecha_nacimiento se hace con trigger (MySQL no permite CURDATE() en CHECK)
);

-- ----------------------------
-- Asignaturas
-- ----------------------------
CREATE TABLE asignaturas (
    id_asignatura INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    creditos INT NOT NULL CHECK (creditos BETWEEN 1 AND 10),
    id_departamento INT,
    CONSTRAINT fk_asig_dept FOREIGN KEY (id_departamento)
        REFERENCES departamentos(id_departamento)
        ON UPDATE CASCADE ON DELETE SET NULL
);

-- ----------------------------
-- Cursos
-- ----------------------------
CREATE TABLE cursos (
    id_curso INT AUTO_INCREMENT PRIMARY KEY,
    id_asignatura INT NOT NULL,
    id_profesor INT NOT NULL,
    semestre VARCHAR(10) NOT NULL,
    anio YEAR NOT NULL,
    capacidad INT DEFAULT 0 CHECK (capacidad >= 0),
    CONSTRAINT fk_curso_asig FOREIGN KEY (id_asignatura)
        REFERENCES asignaturas(id_asignatura)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_curso_prof FOREIGN KEY (id_profesor)
        REFERENCES profesores(id_profesor)
        ON UPDATE CASCADE ON DELETE CASCADE,
    UNIQUE (id_asignatura, semestre, anio, id_profesor)
);

-- ----------------------------
-- Inscripciones
-- ----------------------------
CREATE TABLE inscripciones (
    id_inscripcion INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT NOT NULL,
    id_curso INT NOT NULL,
    fecha_inscripcion DATE NOT NULL DEFAULT (CURRENT_DATE),
    estado ENUM('activo','retirado','finalizado') NOT NULL DEFAULT 'activo',
    UNIQUE (id_estudiante, id_curso),
    CONSTRAINT fk_insc_est FOREIGN KEY (id_estudiante)
        REFERENCES estudiantes(id_estudiante)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_insc_curso FOREIGN KEY (id_curso)
        REFERENCES cursos(id_curso)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- ----------------------------
-- Calificaciones
-- ----------------------------
CREATE TABLE calificaciones (
    id_calificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_inscripcion INT NOT NULL,
    nota DECIMAL(4,2) NOT NULL CHECK (nota >= 0 AND nota <= 5),
    fecha_registro DATE NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT fk_cal_insc FOREIGN KEY (id_inscripcion)
        REFERENCES inscripciones(id_inscripcion)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- ----------------------------
-- Tabla auxiliar: Promedios por curso (materializada)
-- ----------------------------
CREATE TABLE promedios_curso (
    id_curso INT PRIMARY KEY,
    promedio DECIMAL(4,2),
    ultima_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_prom_curso FOREIGN KEY (id_curso)
        REFERENCES cursos(id_curso)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- ============================================================
-- 2) INDICES Y OPTIMIZACIONES
-- ============================================================
CREATE INDEX ix_profesores_dept ON profesores(id_departamento);
CREATE INDEX ix_asignaturas_dept ON asignaturas(id_departamento);
CREATE INDEX ix_estudiantes_semestre ON estudiantes(semestre);
CREATE INDEX ix_insc_estudiante ON inscripciones(id_estudiante);
CREATE INDEX ix_insc_curso ON inscripciones(id_curso);
CREATE INDEX ix_cal_insc ON calificaciones(id_inscripcion);

-- ============================================================
-- 3) DATOS DE PRUEBA (suficientes para las consultas)
-- ============================================================
-- Departamentos
INSERT INTO departamentos (nombre, ubicacion, presupuesto) VALUES
('Ingeniería de Sistemas','Bloque A - Piso 2',120000000),
('Ciencias Económicas','Bloque B - Piso 1',80000000),
('Ciencias Sociales','Bloque C - Piso 3',60000000),
('Derecho','Bloque D - Piso 1',40000000);

-- Profesores
INSERT INTO profesores (nombre, correo, fecha_contratacion, salario, id_departamento) VALUES
('Carlos Pérez','cperez@fesc.edu.co','2015-02-10',3200000,1),
('Laura Gómez','lgomez@fesc.edu.co','2018-06-21',2800000,2),
('Andrés Torres','atorres@fesc.edu.co','2020-03-15',3500000,3),
('María Ruiz','mruiz@fesc.edu.co','2017-09-01',3300000,1);

-- Estudiantes
INSERT INTO estudiantes (nombre, correo, fecha_nacimiento, semestre) VALUES
('Juan García','juan.garcia@correo.com','2003-05-12',4),
('María López','maria.lopez@correo.com','2002-09-30',6),
('Ana Torres','ana.torres@correo.com','2004-01-25',2),
('Pedro Sánchez','pedro.sanchez@correo.com','2001-12-10',8),
('Sofía Martínez','sofia.m@correo.com','2003-07-09',5);

-- Asignaturas
INSERT INTO asignaturas (nombre, creditos, id_departamento) VALUES
('Bases de Datos',4,1),
('Contabilidad',3,2),
('Sociología',2,3),
('Programación Avanzada',5,1),
('Derecho Civil',3,4);

-- Cursos
INSERT INTO cursos (id_asignatura, id_profesor, semestre, anio, capacidad) VALUES
(1,1,'2025-I',2025,40),
(2,2,'2025-I',2025,60),
(3,3,'2025-I',2025,30),
(4,4,'2025-I',2025,25),
(5,3,'2025-I',2025,20);

-- Inscripciones
INSERT INTO inscripciones (id_estudiante, id_curso, fecha_inscripcion, estado) VALUES
(1,1,'2025-02-01','activo'),
(2,1,'2025-02-03','activo'),
(3,2,'2025-02-05','activo'),
(4,4,'2025-02-07','activo'),
(1,4,'2025-02-08','activo'),
(5,1,'2025-02-09','activo'),
(5,5,'2025-02-10','activo');

-- Calificaciones
INSERT INTO calificaciones (id_inscripcion, nota, fecha_registro) VALUES
(1,4.50,'2025-03-01'),
(2,4.20,'2025-03-02'),
(3,3.80,'2025-03-05'),
(4,4.90,'2025-03-06'),
(5,4.00,'2025-03-07'),
(6,3.60,'2025-03-08'),
(7,4.30,'2025-03-09');

-- Inicializar promedios_curso (materializado)
INSERT INTO promedios_curso (id_curso, promedio)
SELECT i.id_curso, ROUND(AVG(c.nota),2)
FROM calificaciones c
JOIN inscripciones i ON c.id_inscripcion = i.id_inscripcion
GROUP BY i.id_curso
ON DUPLICATE KEY UPDATE promedio = VALUES(promedio);

-- ============================================================
-- 4) TRIGGERS (VALIDACIONES Y MANTENIMIENTO) - CORREGIDOS
-- ============================================================
-- IMPORTANTE: usar DELIMITER para permitir bloques BEGIN...END
DELIMITER $$

-- 4.1 Validar fecha_nacimiento (no futura) - INSERT
CREATE TRIGGER trg_estudiantes_validar_fecha_insert
BEFORE INSERT ON estudiantes
FOR EACH ROW
BEGIN
    IF NEW.fecha_nacimiento >= CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de nacimiento debe ser anterior a la fecha actual.';
    END IF;
END$$

-- 4.2 Validar fecha_nacimiento - UPDATE
CREATE TRIGGER trg_estudiantes_validar_fecha_update
BEFORE UPDATE ON estudiantes
FOR EACH ROW
BEGIN
    IF NEW.fecha_nacimiento >= CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede actualizar con fecha de nacimiento futura.';
    END IF;
END$$

-- 4.3 Validar rango nota - INSERT
CREATE TRIGGER trg_calificaciones_validar_nota_insert
BEFORE INSERT ON calificaciones
FOR EACH ROW
BEGIN
    IF NEW.nota < 0 OR NEW.nota > 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La nota debe estar entre 0 y 5.';
    END IF;
END$$

-- 4.4 Validar rango nota - UPDATE
CREATE TRIGGER trg_calificaciones_validar_nota_update
BEFORE UPDATE ON calificaciones
FOR EACH ROW
BEGIN
    IF NEW.nota < 0 OR NEW.nota > 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La nota debe estar entre 0 y 5.';
    END IF;
END$$

-- 4.5 Evitar inscripción duplicada (refuerzo aunque UNIQUE existe)
CREATE TRIGGER trg_inscripciones_no_duplicado
BEFORE INSERT ON inscripciones
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM inscripciones
        WHERE id_estudiante = NEW.id_estudiante AND id_curso = NEW.id_curso
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: el estudiante ya está inscrito en ese curso.';
    END IF;
END$$

-- 4.6 Evitar borrar profesor con cursos activos
CREATE TRIGGER trg_profesores_no_delete_con_cursos
BEFORE DELETE ON profesores
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM cursos WHERE id_profesor = OLD.id_profesor) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar un profesor con cursos asignados.';
    END IF;
END$$

-- 4.7 Mantenimiento promedios: AFTER INSERT en calificaciones
CREATE TRIGGER trg_promedio_after_insert
AFTER INSERT ON calificaciones
FOR EACH ROW
BEGIN
    DECLARE v_curso INT;
    -- obtener curso
    SELECT i.id_curso INTO v_curso
    FROM inscripciones i
    WHERE i.id_inscripcion = NEW.id_inscripcion
    LIMIT 1;

    IF v_curso IS NOT NULL THEN
        INSERT INTO promedios_curso (id_curso, promedio)
        SELECT v_curso, ROUND(AVG(c.nota),2)
        FROM calificaciones c
        JOIN inscripciones i ON c.id_inscripcion = i.id_inscripcion
        WHERE i.id_curso = v_curso
        GROUP BY i.id_curso
        ON DUPLICATE KEY UPDATE promedio = VALUES(promedio);
    END IF;
END$$

-- 4.8 Mantenimiento promedios: AFTER UPDATE en calificaciones
CREATE TRIGGER trg_promedio_after_update
AFTER UPDATE ON calificaciones
FOR EACH ROW
BEGIN
    DECLARE v_curso INT;
    SELECT i.id_curso INTO v_curso
    FROM inscripciones i
    WHERE i.id_inscripcion = NEW.id_inscripcion
    LIMIT 1;

    IF v_curso IS NOT NULL THEN
        INSERT INTO promedios_curso (id_curso, promedio)
        SELECT v_curso, ROUND(AVG(c.nota),2)
        FROM calificaciones c
        JOIN inscripciones i ON c.id_inscripcion = i.id_inscripcion
        WHERE i.id_curso = v_curso
        GROUP BY i.id_curso
        ON DUPLICATE KEY UPDATE promedio = VALUES(promedio);
    END IF;
END$$

-- 4.9 Mantenimiento promedios: AFTER DELETE en calificaciones (corregido)
CREATE TRIGGER trg_promedio_after_delete
AFTER DELETE ON calificaciones
FOR EACH ROW
BEGIN
    DECLARE v_curso INT;
    SELECT i.id_curso INTO v_curso
    FROM inscripciones i
    WHERE i.id_inscripcion = OLD.id_inscripcion
    LIMIT 1;

    IF v_curso IS NOT NULL THEN
        IF (SELECT COUNT(*) 
            FROM calificaciones c 
            JOIN inscripciones i ON c.id_inscripcion = i.id_inscripcion 
            WHERE i.id_curso = v_curso) = 0 THEN
            DELETE FROM promedios_curso WHERE id_curso = v_curso;
        ELSE
            INSERT INTO promedios_curso (id_curso, promedio)
            SELECT v_curso, ROUND(AVG(c.nota),2)
            FROM calificaciones c
            JOIN inscripciones i ON c.id_inscripcion = i.id_inscripcion
            WHERE i.id_curso = v_curso
            GROUP BY i.id_curso
            ON DUPLICATE KEY UPDATE promedio = VALUES(promedio);
        END IF;
    END IF;
END$$

DELIMITER ;

-- ============================================================
-- 5) VISTAS (REPORTES)
-- ============================================================
CREATE OR REPLACE VIEW vista_cursos_estudiantes AS
SELECT cu.id_curso,
       a.nombre AS asignatura,
       cu.semestre,
       cu.anio,
       cu.capacidad,
       COALESCE(COUNT(i.id_estudiante),0) AS total_inscritos
FROM cursos cu
JOIN asignaturas a ON cu.id_asignatura = a.id_asignatura
LEFT JOIN inscripciones i ON cu.id_curso = i.id_curso
GROUP BY cu.id_curso, a.nombre, cu.semestre, cu.anio, cu.capacidad;

CREATE OR REPLACE VIEW vista_estudiante_promedios AS
SELECT e.id_estudiante, e.nombre,
       ROUND(AVG(c.nota),2) AS promedio_general,
       COUNT(c.id_calificacion) AS total_calificaciones
FROM estudiantes e
LEFT JOIN inscripciones i ON e.id_estudiante = i.id_estudiante
LEFT JOIN calificaciones c ON i.id_inscripcion = c.id_inscripcion
GROUP BY e.id_estudiante, e.nombre;

-- ============================================================
-- 6) CONSULTAS COMPLEJAS (5) - CTEs, Window Functions, Álgebra Relacional
-- ============================================================
/* Álgebra relacional comentada cuando aplica. */

-- Consulta 1: Estudiantes con promedio superior al promedio global (CTE + subconsulta)
WITH promedio_global AS (
    SELECT AVG(nota) AS prom FROM calificaciones
)
SELECT
    e.id_estudiante,
    e.nombre AS estudiante,
    ROUND(AVG(c.nota),2) AS promedio_est,
    (SELECT prom FROM promedio_global) AS promedio_global
FROM calificaciones c
JOIN inscripciones i ON c.id_inscripcion = i.id_inscripcion
JOIN estudiantes e ON i.id_estudiante = e.id_estudiante
GROUP BY e.id_estudiante, e.nombre
HAVING ROUND(AVG(c.nota),2) > (SELECT prom FROM promedio_global);
-- Álgebra relacional: π id_estudiante,nombre,avg(nota) ( σ avg(nota) > prom (Estudiantes ⋈ Inscripciones ⋈ Calificaciones) )

-- Consulta 2: Ranking de estudiantes por promedio (Window Function)
SELECT
    e.id_estudiante,
    e.nombre,
    ROUND(AVG(c.nota),2) AS promedio,
    RANK() OVER (ORDER BY AVG(c.nota) DESC) AS posicion
FROM calificaciones c
JOIN inscripciones i ON c.id_inscripcion = i.id_inscripcion
JOIN estudiantes e ON i.id_estudiante = e.id_estudiante
GROUP BY e.id_estudiante, e.nombre
ORDER BY promedio DESC;

-- Consulta 3: Número de estudiantes por departamento (JOINs múltiples)
SELECT
    d.id_departamento,
    d.nombre AS departamento,
    COUNT(DISTINCT i.id_estudiante) AS total_estudiantes
FROM departamentos d
JOIN asignaturas a ON a.id_departamento = d.id_departamento
JOIN cursos cu ON cu.id_asignatura = a.id_asignatura
JOIN inscripciones i ON i.id_curso = cu.id_curso
GROUP BY d.id_departamento, d.nombre
ORDER BY total_estudiantes DESC;

-- Consulta 4: Promedio de notas por departamento (agregación)
SELECT
    d.id_departamento,
    d.nombre AS departamento,
    ROUND(AVG(ca.nota),2) AS promedio_notas
FROM calificaciones ca
JOIN inscripciones i ON ca.id_inscripcion = i.id_inscripcion
JOIN cursos cu ON i.id_curso = cu.id_curso
JOIN asignaturas a ON cu.id_asignatura = a.id_asignatura
JOIN departamentos d ON a.id_departamento = d.id_departamento
GROUP BY d.id_departamento, d.nombre
ORDER BY promedio_notas DESC;

-- Consulta 5: Promedio por semestre usando Window Function (PARTITION BY)
SELECT
    cu.semestre,
    e.id_estudiante,
    e.nombre,
    ROUND(AVG(ca.nota) OVER (PARTITION BY cu.semestre, e.id_estudiante),2) AS promedio_estudiante_semestre,
    ROUND(AVG(ca.nota) OVER (PARTITION BY cu.semestre),2) AS promedio_semestre
FROM calificaciones ca
JOIN inscripciones i ON ca.id_inscripcion = i.id_inscripcion
JOIN cursos cu ON i.id_curso = cu.id_curso
JOIN estudiantes e ON i.id_estudiante = e.id_estudiante
GROUP BY cu.semestre, e.id_estudiante, e.nombre, ca.id_calificacion
ORDER BY cu.semestre, promedio_estudiante_semestre DESC;

-- ============================================================
-- 7) CONTROL DE CONCURRENCIA (SIMULACIÓN Y SOLUCIONES)
-- ============================================================
/*
INSTRUCCIONES PARA DEMOSTRACIÓN:

Abrir DOS SESIONES en MySQL Workbench (Session A y Session B).

EJEMPLO: actualizacion perdida / bloqueo de fila

Session A:
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    START TRANSACTION;
    SELECT nota FROM calificaciones WHERE id_calificacion = 1 FOR UPDATE; -- bloquea fila
    UPDATE calificaciones SET nota = nota + 0.10 WHERE id_calificacion = 1;
    -- Mantener la transacción abierta (no COMMIT), para simular bloqueo

Session B:
    START TRANSACTION;
    -- Intentará adquirir lock; quedará esperando hasta que Session A haga COMMIT o ROLLBACK
    SELECT nota FROM calificaciones WHERE id_calificacion = 1 FOR UPDATE;
    UPDATE calificaciones SET nota = nota + 0.20 WHERE id_calificacion = 1;
    COMMIT;

Session A:
    COMMIT;

SOLUCIONES:
- Usar FOR UPDATE (bloqueo de fila) y control de transacciones como arriba.
- Usar nivel de aislamiento SERIALIZABLE si se requiere.
- Implementar control optimista con columna de versión (se puede agregar).
- Para demo simple se puede usar LOCK TABLES calificaciones WRITE; ... UNLOCK TABLES;

Observa que con FOR UPDATE, Session B esperará hasta que Session A finalice; si ambos aplicaran operaciones sin locks, podrían perderse actualizaciones.
*/

-- ============================================================
-- 8) EJEMPLOS ADICIONALES (CÁLCULO RELACIONAL, SUBCONSULTAS)
-- ============================================================
-- Ejemplo: estudiantes que han aprobado todas sus asignaturas inscritas (nota >= 3.0)
-- Cálculo relacional: { e | ∀ inscripciones i de e, ∃ calificaciones c tal que c.nota >= 3.0 }
SELECT e.id_estudiante, e.nombre
FROM estudiantes e
WHERE NOT EXISTS (
    SELECT 1 FROM inscripciones i
    LEFT JOIN calificaciones c ON i.id_inscripcion = c.id_inscripcion
    WHERE i.id_estudiante = e.id_estudiante
      AND (c.nota IS NULL OR c.nota < 3.0)
);

-- Ejemplo: asignaturas con al menos 2 estudiantes inscritos (subconsulta existencial)
SELECT a.id_asignatura, a.nombre
FROM asignaturas a
WHERE EXISTS (
    SELECT 1 FROM cursos cu JOIN inscripciones i ON cu.id_curso = i.id_curso
    WHERE cu.id_asignatura = a.id_asignatura
    GROUP BY cu.id_asignatura
    HAVING COUNT(DISTINCT i.id_estudiante) >= 2
);

-- ============================================================
-- 9) LIMPIEZA OPCIONAL (instrucciones)
-- ============================================================
/*
Para limpiar todo:
    DROP DATABASE IF EXISTS gestion_academica;
*/

-- ============================================================
-- FIN. 
-- ============================================================

