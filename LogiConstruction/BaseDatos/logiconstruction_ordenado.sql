-- ============================================================
-- Base de datos LogiConstruction
-- Proyecto: Sistema de Gestión Logística en Construcción
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS logiconstruction
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE logiconstruction;

-- ============================================================
-- Limpieza de tablas antiguas o no usadas
-- ============================================================

DROP TABLE IF EXISTS detalleventa;
DROP TABLE IF EXISTS venta;
DROP TABLE IF EXISTS inventario;
DROP TABLE IF EXISTS producto;
DROP TABLE IF EXISTS categoria;
DROP TABLE IF EXISTS materiales;
DROP TABLE IF EXISTS proyectos;
DROP TABLE IF EXISTS usuario;
DROP TABLE IF EXISTS proveedor;
DROP TABLE IF EXISTS compras;
DROP TABLE IF EXISTS requerimientos;
DROP TABLE IF EXISTS proveedores;
DROP TABLE IF EXISTS usuarios;

SET FOREIGN_KEY_CHECKS = 1;



-- Las contraseñas se almacenan con PBKDF2-HMAC-SHA256.
CREATE TABLE usuarios (
  id_usuario INT NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  correo VARCHAR(100) NOT NULL,
  password VARCHAR(255) NOT NULL,
  rol ENUM('ADMINISTRADOR_OBRA','JEFE_LOGISTICA','GERENCIA') NOT NULL,
  estado ENUM('ACTIVO','INACTIVO') NOT NULL DEFAULT 'ACTIVO',
  fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_usuario),
  UNIQUE KEY uk_usuarios_correo (correo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



CREATE TABLE proveedores (
  id INT NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  ruc CHAR(11) DEFAULT NULL,
  telefono VARCHAR(20) DEFAULT NULL,
  correo VARCHAR(100) DEFAULT NULL,
  direccion VARCHAR(150) DEFAULT NULL,
  estado ENUM('ACTIVO','INACTIVO') NOT NULL DEFAULT 'ACTIVO',
  fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_proveedores_ruc (ruc),
  KEY idx_proveedores_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



CREATE TABLE requerimientos (
  id INT NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  area VARCHAR(100) NOT NULL,
  cantidad INT NOT NULL,
  fecha DATE NOT NULL,
  estado ENUM('PENDIENTE','APROBADO','RECHAZADO','ATENDIDO') NOT NULL DEFAULT 'PENDIENTE',
  observacion VARCHAR(255) DEFAULT NULL,
  fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_requerimientos_fecha (fecha),
  KEY idx_requerimientos_estado (estado),
  CONSTRAINT chk_requerimientos_cantidad CHECK (cantidad > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



CREATE TABLE compras (
  id INT NOT NULL AUTO_INCREMENT,
  proveedor VARCHAR(100) NOT NULL,
  producto VARCHAR(100) NOT NULL,
  cantidad INT NOT NULL,
  fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  estado ENUM('REGISTRADA','RECIBIDA','ANULADA') NOT NULL DEFAULT 'REGISTRADA',
  costo_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  observacion VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id),
  KEY idx_compras_fecha (fecha),
  KEY idx_compras_producto (producto),
  KEY idx_compras_proveedor (proveedor),
  CONSTRAINT chk_compras_cantidad CHECK (cantidad > 0),
  CONSTRAINT chk_compras_costo_unitario CHECK (costo_unitario >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



INSERT INTO usuarios (id_usuario, nombre, correo, password, rol, estado) VALUES
(1, 'Administrador Obra', 'obra@logiconstruction.com', 'pbkdf2_sha256$210000$LNmvh3f8y+NuOWY9nT7hkw==$4sP4ENQmuGocXD06NldGVIzOqzq7+7SfPT6Yq+dqsn4=', 'ADMINISTRADOR_OBRA', 'ACTIVO'),
(2, 'Jefe Logística', 'logistica@logiconstruction.com', 'pbkdf2_sha256$210000$b3pcMNI3upAQlJCp6/O7MA==$eBWg7PZTJhIqxZHM93rYJ0V/AVq/Vi01ajW56FDwBgo=', 'JEFE_LOGISTICA', 'ACTIVO'),
(3, 'Gerencia', 'gerencia@logiconstruction.com', 'pbkdf2_sha256$210000$+kEPCaDPrXR72/g7HXI3/g==$jj9G1qWEAJIPWIRgyxjn6hni9HKarnsZIDwj4xSZL1w=', 'GERENCIA', 'ACTIVO');

INSERT INTO proveedores (id, nombre, ruc, telefono, correo, direccion, estado) VALUES
(1, 'MATEL S.A.C.', '20123456789', '997011272', 'ventas@matel.com', 'Lima, Perú', 'ACTIVO'),
(2, 'Cementos del Sur S.A.C.', '20456789123', '965432100', 'contacto@cementosdelsur.com', 'Arequipa, Perú', 'ACTIVO'),
(3, 'Aceros Andinos S.A.C.', '20678912345', '954321987', 'ventas@acerosandinos.com', 'Cusco, Perú', 'ACTIVO');

INSERT INTO requerimientos (id, nombre, area, cantidad, fecha, estado, observacion) VALUES
(1, 'Yeso', 'Almacén Central', 50, '2026-05-23', 'PENDIENTE', 'Material requerido para acabados.'),
(2, 'Cemento Portland', 'Obra Principal', 120, '2026-05-24', 'APROBADO', 'Material para vaciado de concreto.'),
(3, 'Acero corrugado', 'Estructuras', 80, '2026-05-25', 'PENDIENTE', 'Varillas para armado estructural.');

INSERT INTO compras (id, proveedor, producto, cantidad, fecha, estado, costo_unitario, observacion) VALUES
(1, 'MATEL S.A.C.', 'Arena fina', 189, '2026-05-26 01:52:28', 'REGISTRADA', 35.00, 'Compra registrada para obra.'),
(2, 'MATEL S.A.C.', 'Tornillos', 189, '2026-05-26 02:01:16', 'REGISTRADA', 0.20, 'Compra de ferretería.'),
(3, 'Aceros Andinos S.A.C.', 'Acero corrugado', 189, '2026-05-26 02:01:23', 'REGISTRADA', 42.00, 'Material estructural.'),
(4, 'Cementos del Sur S.A.C.', 'Cemento Portland', 100, '2026-05-26 02:06:43', 'RECIBIDA', 31.50, 'Compra atendida.'),
(5, 'MATEL S.A.C.', 'Arena fina', 120, '2026-05-26 02:54:44', 'REGISTRADA', 35.00, 'Compra complementaria.');

-- ============================================================
-- Vistas de apoyo para reportes y validación manual
-- ============================================================

CREATE OR REPLACE VIEW vw_resumen_dashboard AS
SELECT
  (SELECT COUNT(*) FROM compras) AS total_compras,
  (SELECT COUNT(*) FROM proveedores WHERE estado = 'ACTIVO') AS total_proveedores,
  (SELECT COUNT(*) FROM requerimientos) AS total_requerimientos,
  (SELECT COUNT(*) FROM requerimientos WHERE estado = 'PENDIENTE') AS requerimientos_pendientes;

CREATE OR REPLACE VIEW vw_compras_por_producto AS
SELECT
  producto,
  COUNT(*) AS veces_comprado,
  SUM(cantidad) AS cantidad_total,
  SUM(cantidad * costo_unitario) AS costo_estimado_total
FROM compras
GROUP BY producto
ORDER BY veces_comprado DESC, cantidad_total DESC;

CREATE OR REPLACE VIEW vw_compras_por_proveedor AS
SELECT
  proveedor,
  COUNT(*) AS total_compras,
  SUM(cantidad) AS cantidad_total,
  SUM(cantidad * costo_unitario) AS costo_estimado_total
FROM compras
GROUP BY proveedor
ORDER BY total_compras DESC, cantidad_total DESC;

-- ============================================================
-- Consultas rápidas de verificación
-- ============================================================

SELECT 'Base de datos logiconstruction creada correctamente' AS mensaje;
SELECT * FROM vw_resumen_dashboard;
