-- ============================================
-- 05_Triggers.sql
-- Triggers del proyecto PROYECTO_FINAL
-- ============================================

-- TABLA DE AUDITORÍA DE CAMBIOS DE PRECIO
CREATE TABLE log_cambios_precio (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT,
    precio_anterior DECIMAL(10,2),
    precio_nuevo DECIMAL(10,2),
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- TABLA DE AUDITORÍA DE STOCK
CREATE TABLE log_stock (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT,
    stock_anterior INT,
    stock_nuevo INT,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- TABLA DE AUDITORÍA DE CLIENTES
CREATE TABLE log_clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    accion VARCHAR(50),
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- TABLA DE AUDITORÍA DE VENTAS
CREATE TABLE log_ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT,
    accion VARCHAR(50),
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 1. Auditoría de cambios de precio
-- ============================================
CREATE TRIGGER tr_productos_precio_update
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    IF OLD.precio <> NEW.precio THEN
        INSERT INTO log_cambios_precio (id_producto, precio_anterior, precio_nuevo)
        VALUES (OLD.id_producto, OLD.precio, NEW.precio);
    END IF;
END;

-- ============================================
-- 2. Auditoría de cambios de stock
-- ============================================
CREATE TRIGGER tr_productos_stock_update
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    IF OLD.stock <> NEW.stock THEN
        INSERT INTO log_stock (id_producto, stock_anterior, stock_nuevo)
        VALUES (OLD.id_producto, OLD.stock, NEW.stock);
    END IF;
END;

-- ============================================
-- 3. Actualizar total de venta automáticamente
-- ============================================
CREATE TRIGGER tr_ventas_actualizar_total
AFTER INSERT ON detalle_ventas
FOR EACH ROW
BEGIN
    UPDATE ventas
    SET total = (SELECT SUM(cantidad * precio_unitario_congelado)
                 FROM detalle_ventas
                 WHERE id_venta = NEW.id_venta)
    WHERE id_venta = NEW.id_venta;
END;

-- ============================================
-- 4. Recalcular total si se elimina un detalle
-- ============================================
CREATE TRIGGER tr_ventas_actualizar_total_delete
AFTER DELETE ON detalle_ventas
FOR EACH ROW
BEGIN
    UPDATE ventas
    SET total = (SELECT IFNULL(SUM(cantidad * precio_unitario_congelado),0)
                 FROM detalle_ventas
                 WHERE id_venta = OLD.id_venta)
    WHERE id_venta = OLD.id_venta;
END;

-- ============================================
-- 5. Evitar ventas con stock insuficiente
-- ============================================
CREATE TRIGGER tr_detalle_ventas_validar_stock
BEFORE INSERT ON detalle_ventas
FOR EACH ROW
BEGIN
    IF (SELECT stock FROM productos WHERE id_producto = NEW.id_producto) < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente para realizar la venta';
    END IF;
END;

-- ============================================
-- 6. Descontar stock automáticamente al vender
-- ============================================
CREATE TRIGGER tr_productos_descontar_stock
AFTER INSERT ON detalle_ventas
FOR EACH ROW
BEGIN
    UPDATE productos
    SET stock = stock - NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END;

-- ============================================
-- 7. Reponer stock si se elimina un detalle
-- ============================================
CREATE TRIGGER tr_productos_reponer_stock
AFTER DELETE ON detalle_ventas
FOR EACH ROW
BEGIN
    UPDATE productos
    SET stock = stock + OLD.cantidad
    WHERE id_producto = OLD.id_producto;
END;

-- ============================================
-- 8. Auditoría de creación de clientes
-- ============================================
CREATE TRIGGER tr_clientes_insert
AFTER INSERT ON clientes
FOR EACH ROW
BEGIN
    INSERT INTO log_clientes (id_cliente, accion)
    VALUES (NEW.id_cliente, 'Cliente creado');
END;

-- ============================================
-- 9. Auditoría de eliminación de clientes
-- ============================================
CREATE TRIGGER tr_clientes_delete
AFTER DELETE ON clientes
FOR EACH ROW
BEGIN
    INSERT INTO log_clientes (id_cliente, accion)
    VALUES (OLD.id_cliente, 'Cliente eliminado');
END;

-- ============================================
-- 10. Auditoría de creación de ventas
-- ============================================
CREATE TRIGGER tr_ventas_insert
AFTER INSERT ON ventas
FOR EACH ROW
BEGIN
    INSERT INTO log_ventas (id_venta, accion)
    VALUES (NEW.id_venta, 'Venta creada');
END;

-- ============================================
-- 11. Auditoría de eliminación de ventas
-- ============================================
CREATE TRIGGER tr_ventas_delete
AFTER DELETE ON ventas
FOR EACH ROW
BEGIN
    INSERT INTO log_ventas (id_venta, accion)
    VALUES (OLD.id_venta, 'Venta eliminada');
END;

-- ============================================
-- 12. Validar que el precio no sea negativo
-- ============================================
CREATE TRIGGER tr_productos_validar_precio
BEFORE INSERT ON productos
FOR EACH ROW
BEGIN
    IF NEW.precio <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El precio debe ser mayor a 0';
    END IF;
END;

-- ============================================
-- 13. Validar que el costo no sea negativo
-- ============================================
CREATE TRIGGER tr_productos_validar_costo
BEFORE INSERT ON productos
FOR EACH ROW
BEGIN
    IF NEW.costo < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El costo no puede ser negativo';
    END IF;
END;

-- ============================================
-- 14. Validar que el stock no sea negativo
-- ============================================
CREATE TRIGGER tr_productos_validar_stock
BEFORE INSERT ON productos
FOR EACH ROW
BEGIN
    IF NEW.stock < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El stock no puede ser negativo';
    END IF;
END;

-- ============================================
-- 15. Registrar cambios de categoría
-- ============================================
CREATE TRIGGER tr_productos_categoria_update
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
    IF OLD.id_categoria <> NEW.id_categoria THEN
        INSERT INTO log_cambios_precio (id_producto, precio_anterior, precio_nuevo)
        VALUES (OLD.id_producto, OLD.id_categoria, NEW.id_categoria);
    END IF;
END;

-- ============================================
-- 16. Bloquear eliminación de productos con ventas
-- ============================================
CREATE TRIGGER tr_productos_bloquear_delete
BEFORE DELETE ON productos
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM detalle_ventas WHERE id_producto = OLD.id_producto) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar un producto con ventas registradas';
    END IF;
END;

-- ============================================
-- 17. Registrar cambios de email de clientes
-- ============================================
CREATE TRIGGER tr_clientes_email_update
BEFORE UPDATE ON clientes
FOR EACH ROW
BEGIN
    IF OLD.email <> NEW.email THEN
        INSERT INTO log_clientes (id_cliente, accion)
        VALUES (OLD.id_cliente, 'Email actualizado');
    END IF;
END;

-- ============================================
-- 18. Registrar cambios de estado de venta
-- ============================================
CREATE TRIGGER tr_ventas_estado_update
BEFORE UPDATE ON ventas
FOR EACH ROW
BEGIN
    IF OLD.estado <> NEW.estado THEN
        INSERT INTO log_ventas (id_venta, accion)
        VALUES (OLD.id_venta, CONCAT('Estado cambiado a ', NEW.estado));
    END IF;
END;

-- ============================================
-- 19. Validar que el SKU sea único
-- ============================================
CREATE TRIGGER tr_productos_validar_sku
BEFORE INSERT ON productos
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM productos WHERE sku = NEW.sku) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El SKU ya existe';
    END IF;
END;

-- ============================================
-- 20. Auditoría de cambios de contraseña
-- ============================================
CREATE TRIGGER tr_clientes_password_update
BEFORE UPDATE ON clientes
FOR EACH ROW
BEGIN
    IF OLD.contraseña <> NEW.contraseña THEN
        INSERT INTO log_clientes (id_cliente, accion)
        VALUES (OLD.id_cliente, 'Contraseña actualizada');
    END IF;
END;
