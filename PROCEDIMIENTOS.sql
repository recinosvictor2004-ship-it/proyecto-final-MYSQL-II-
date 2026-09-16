-- ============================================
-- 06_Procedimientos.sql
-- 20 procedimientos almacenados para PROYECTO_FINAL
-- ============================================

DELIMITER $$

-- 1. sp_CrearCliente
CREATE PROCEDURE sp_CrearCliente (
    IN p_nombre VARCHAR(100),
    IN p_apellido VARCHAR(100),
    IN p_email VARCHAR(150),
    IN p_contraseña VARCHAR(255),
    IN p_direccion_envio TEXT,
    IN p_fecha_nacimiento DATE
)
BEGIN
    INSERT INTO clientes (nombre, apellido, email, contraseña, direccion_envio, fecha_nacimiento)
    VALUES (p_nombre, p_apellido, p_email, p_contraseña, p_direccion_envio, p_fecha_nacimiento);
END$$

-- 2. sp_ActualizarCliente
CREATE PROCEDURE sp_ActualizarCliente (
    IN p_id_cliente INT,
    IN p_nombre VARCHAR(100),
    IN p_apellido VARCHAR(100),
    IN p_email VARCHAR(150),
    IN p_direccion_envio TEXT
)
BEGIN
    UPDATE clientes
    SET nombre = p_nombre,
        apellido = p_apellido,
        email = p_email,
        direccion_envio = p_direccion_envio
    WHERE id_cliente = p_id_cliente;
END$$

-- 3. sp_EliminarCliente
CREATE PROCEDURE sp_EliminarCliente (
    IN p_id_cliente INT
)
BEGIN
    DELETE FROM clientes
    WHERE id_cliente = p_id_cliente;
END$$

-- 4. sp_CrearProducto
CREATE PROCEDURE sp_CrearProducto (
    IN p_nombre VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_precio DECIMAL(10,2),
    IN p_costo DECIMAL(10,2),
    IN p_stock INT,
    IN p_sku VARCHAR(50),
    IN p_id_categoria INT,
    IN p_id_proveedor INT,
    IN p_umbral_minimo INT
)
BEGIN
    INSERT INTO productos (nombre, descripcion, precio, costo, stock, sku, id_categoria, id_proveedor, umbral_minimo)
    VALUES (p_nombre, p_descripcion, p_precio, p_costo, p_stock, p_sku, p_id_categoria, p_id_proveedor, p_umbral_minimo);
END$$

-- 5. sp_ActualizarProducto
CREATE PROCEDURE sp_ActualizarProducto (
    IN p_id_producto INT,
    IN p_nombre VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_precio DECIMAL(10,2),
    IN p_costo DECIMAL(10,2),
    IN p_stock INT,
    IN p_umbral_minimo INT
)
BEGIN
    UPDATE productos
    SET nombre = p_nombre,
        descripcion = p_descripcion,
        precio = p_precio,
        costo = p_costo,
        stock = p_stock,
        umbral_minimo = p_umbral_minimo
    WHERE id_producto = p_id_producto;
END$$

-- 6. sp_EliminarProducto
CREATE PROCEDURE sp_EliminarProducto (
    IN p_id_producto INT
)
BEGIN
    DELETE FROM productos
    WHERE id_producto = p_id_producto;
END$$

-- 7. sp_CrearVenta
CREATE PROCEDURE sp_CrearVenta (
    IN p_id_cliente INT,
    IN p_estado VARCHAR(20)
)
BEGIN
    INSERT INTO ventas (id_cliente, estado)
    VALUES (p_id_cliente, p_estado);
END$$

-- 8. sp_AgregarDetalleVenta
CREATE PROCEDURE sp_AgregarDetalleVenta (
    IN p_id_venta INT,
    IN p_id_producto INT,
    IN p_cantidad INT,
    IN p_precio_unitario DECIMAL(10,2)
)
BEGIN
    INSERT INTO detalle_ventas (id_venta, id_producto, cantidad, precio_unitario_congelado)
    VALUES (p_id_venta, p_id_producto, p_cantidad, p_precio_unitario);
END$$

-- 9. sp_EliminarDetalleVenta
CREATE PROCEDURE sp_EliminarDetalleVenta (
    IN p_id_detalle INT
)
BEGIN
    DELETE FROM detalle_ventas
    WHERE id_detalle = p_id_detalle;
END$$

-- 10. sp_ActualizarEstadoVenta
CREATE PROCEDURE sp_ActualizarEstadoVenta (
    IN p_id_venta INT,
    IN p_estado VARCHAR(20)
)
BEGIN
    UPDATE ventas
    SET estado = p_estado
    WHERE id_venta = p_id_venta;
END$$

-- 11. sp_ObtenerHistorialComprasCliente
CREATE PROCEDURE sp_ObtenerHistorialComprasCliente (
    IN p_id_cliente INT
)
BEGIN
    SELECT v.id_venta,
           v.fecha_venta,
           v.estado,
           v.total
    FROM ventas v
    WHERE v.id_cliente = p_id_cliente
    ORDER BY v.fecha_venta DESC;
END$$

-- 12. sp_ObtenerDetallesVenta
CREATE PROCEDURE sp_ObtenerDetallesVenta (
    IN p_id_venta INT
)
BEGIN
    SELECT d.id_detalle,
           p.nombre,
           d.cantidad,
           d.precio_unitario_congelado,
           (d.cantidad * d.precio_unitario_congelado) AS subtotal
    FROM detalle_ventas d
    JOIN productos p ON d.id_producto = p.id_producto
    WHERE d.id_venta = p_id_venta;
END$$

-- 13. sp_ProductosBajoStock
CREATE PROCEDURE sp_ProductosBajoStock ()
BEGIN
    SELECT id_producto, nombre, stock, umbral_minimo
    FROM productos
    WHERE stock < umbral_minimo;
END$$

-- 14. sp_ReporteVentasPorMes
CREATE PROCEDURE sp_ReporteVentasPorMes (
    IN p_anio INT,
    IN p_mes INT
)
BEGIN
    SELECT v.id_venta,
           v.fecha_venta,
           v.total,
           c.nombre,
           c.apellido
    FROM ventas v
    JOIN clientes c ON v.id_cliente = c.id_cliente
    WHERE YEAR(v.fecha_venta) = p_anio
      AND MONTH(v.fecha_venta) = p_mes
    ORDER BY v.fecha_venta;
END$$

-- 15. sp_ReporteVentasPorCliente
CREATE PROCEDURE sp_ReporteVentasPorCliente (
    IN p_id_cliente INT
)
BEGIN
    SELECT v.id_venta,
           v.fecha_venta,
           v.total,
           v.estado
    FROM ventas v
    WHERE v.id_cliente = p_id_cliente
    ORDER BY v.fecha_venta DESC;
END$$

-- 16. sp_ActualizarContraseñaCliente
CREATE PROCEDURE sp_ActualizarContraseñaCliente (
    IN p_id_cliente INT,
    IN p_nueva_contraseña VARCHAR(255)
)
BEGIN
    UPDATE clientes
    SET contraseña = p_nueva_contraseña
    WHERE id_cliente = p_id_cliente;
END$$

-- 17. sp_BuscarProductosPorCategoria
CREATE PROCEDURE sp_BuscarProductosPorCategoria (
    IN p_id_categoria INT
)
BEGIN
    SELECT id_producto, nombre, precio, stock
    FROM productos
    WHERE id_categoria = p_id_categoria;
END$$

-- 18. sp_BuscarProductosPorProveedor
CREATE PROCEDURE sp_BuscarProductosPorProveedor (
    IN p_id_proveedor INT
)
BEGIN
    SELECT id_producto, nombre, precio, stock
    FROM productos
    WHERE id_proveedor = p_id_proveedor;
END$$

-- 19. sp_ReporteTopProductos
CREATE PROCEDURE sp_ReporteTopProductos (
    IN p_limite INT
)
BEGIN
    SELECT 
        p.id_producto,
        p.nombre,
        SUM(d.cantidad * d.precio_unitario_congelado) AS ingresos_totales
    FROM detalle_ventas d
    JOIN productos p ON d.id_producto = p.id_producto
    GROUP BY p.id_producto, p.nombre
    ORDER BY ingresos_totales DESC
    LIMIT p_limite;
END$$

-- 20. sp_ReporteClientesVIP
CREATE PROCEDURE sp_ReporteClientesVIP (
    IN p_limite INT
)
BEGIN
    SELECT 
        c.id_cliente,
        c.nombre,
        c.apellido,
        SUM(d.cantidad * d.precio_unitario_congelado) AS total_gastado
    FROM detalle_ventas d
    JOIN ventas v ON d.id_venta = v.id_venta
    JOIN clientes c ON v.id_cliente = c.id_cliente
    GROUP BY c.id_cliente, c.nombre, c.apellido
    ORDER BY total_gastado DESC
    LIMIT p_limite;
END$$

DELIMITER ;
