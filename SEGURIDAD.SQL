-- ============================================
-- 04_Seguridad.sql
-- Roles, permisos, usuarios y políticas
-- ============================================

USE PROYECTO_FINAL;

-- 1. Crear rol Administrador_Sistema con todos los privilegios
CREATE ROLE Administrador_Sistema;
GRANT ALL PRIVILEGES ON PROYECTO_FINAL.* TO Administrador_Sistema;

-- 2. Crear rol Gerente_Marketing con acceso de solo lectura a ventas y clientes
CREATE ROLE Gerente_Marketing;
GRANT SELECT ON PROYECTO_FINAL.ventas TO Gerente_Marketing;
GRANT SELECT ON PROYECTO_FINAL.clientes TO Gerente_Marketing;

-- 3. Crear rol Analista_Datos con acceso de solo lectura a todas las tablas excepto auditoría de precios
CREATE ROLE Analista_Datos;
GRANT SELECT ON PROYECTO_FINAL.* TO Analista_Datos;
REVOKE SELECT ON PROYECTO_FINAL.log_cambios_precio FROM Analista_Datos;

-- 4. Crear rol Empleado_Inventario que solo pueda modificar stock de productos
CREATE ROLE Empleado_Inventario;
GRANT SELECT, UPDATE(stock) ON PROYECTO_FINAL.productos TO Empleado_Inventario;

-- 5. Crear rol Atencion_Cliente con acceso a clientes y ventas (solo lectura)
CREATE ROLE Atencion_Cliente;
GRANT SELECT ON PROYECTO_FINAL.clientes TO Atencion_Cliente;
GRANT SELECT ON PROYECTO_FINAL.ventas TO Atencion_Cliente;

-- 6. Crear rol Auditor_Financiero con acceso de solo lectura a ventas, productos y logs de precios
CREATE ROLE Auditor_Financiero;
GRANT SELECT ON PROYECTO_FINAL.ventas TO Auditor_Financiero;
GRANT SELECT ON PROYECTO_FINAL.productos TO Auditor_Financiero;
GRANT SELECT ON PROYECTO_FINAL.log_cambios_precio TO Auditor_Financiero;

-- 7. Crear usuario admin_user y asignarle rol administrador
CREATE USER 'admin_user'@'%' IDENTIFIED BY 'Admin123!';
GRANT Administrador_Sistema TO 'admin_user'@'%';

-- 8. Crear usuario marketing_user y asignarle rol marketing
CREATE USER 'marketing_user'@'%' IDENTIFIED BY 'Marketing123!';
GRANT Gerente_Marketing TO 'marketing_user'@'%';

-- 9. Crear usuario inventory_user y asignarle rol inventario
CREATE USER 'inventory_user'@'%' IDENTIFIED BY 'Inventario123!';
GRANT Empleado_Inventario TO 'inventory_user'@'%';

-- 10. Crear usuario support_user y asignarle rol atención al cliente
CREATE USER 'support_user'@'%' IDENTIFIED BY 'Support123!';
GRANT Atencion_Cliente TO 'support_user'@'%';

-- 11. Impedir que Analista_Datos pueda ejecutar DELETE o TRUNCATE
REVOKE DELETE, TRUNCATE ON PROYECTO_FINAL.* FROM Analista_Datos;

-- 12. Permitir que Gerente_Marketing ejecute procedimiento de reporte mensual de ventas
GRANT EXECUTE ON PROCEDURE PROYECTO_FINAL.sp_ReporteVentasPorMes TO Gerente_Marketing;

-- 13. Crear vista v_info_clientes_basica sin información sensible
CREATE VIEW v_info_clientes_basica AS
SELECT id_cliente, nombre, apellido, email
FROM clientes;

GRANT SELECT ON v_info_clientes_basica TO Atencion_Cliente;

-- 14. (Nota) REVOKE por columna no es soportado en MySQL, se controla por rol
-- No se incluye REVOKE UPDATE(precio) porque no es sintaxis válida.

-- 15. Implementar política de contraseñas seguras
SET GLOBAL validate_password.length = 8;
SET GLOBAL validate_password.mixed_case_count = 1;
SET GLOBAL validate_password.number_count = 1;

-- 16. (Nota) Cambiar host de root vía UPDATE mysql.user no es compatible con MySQL 8.0
-- Se omite para evitar errores en entornos modernos.

-- 17. Crear rol Visitante con acceso solo a productos (solo lectura)
CREATE ROLE Visitante;
GRANT SELECT ON PROYECTO_FINAL.productos TO Visitante;

-- 18. Limitar número de consultas por hora para Analista_Datos
GRANT USAGE ON *.* TO Analista_Datos WITH MAX_QUERIES_PER_HOUR 100;

-- 19. Vista de ventas por sucursal (adaptada al esquema actual)
CREATE VIEW ventas_por_sucursal AS
SELECT 
    v.id_venta,
    v.fecha_venta,
    v.estado,
    v.total,
    c.nombre AS cliente,
    c.apellido AS apellido_cliente
FROM ventas v
JOIN clientes c ON v.id_cliente = c.id_cliente;

-- 20. Auditar intentos de inicio de sesión fallidos
CREATE TABLE IF NOT EXISTS auditoria_logins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(100),
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    ip VARCHAR(50),
    descripcion TEXT
);

SET GLOBAL log_error_verbosity = 3;
