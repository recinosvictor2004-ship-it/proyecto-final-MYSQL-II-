-- 1. fn_CalcularTotalVenta
CREATE FUNCTION fn_CalcularTotalVenta(idVenta INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN (
        SELECT SUM(cantidad * precio_unitario_congelado)
        FROM detalle_ventas
        WHERE id_venta = idVenta
    );
END;


-- 2. fn_VerificarDisponibilidadStock
CREATE FUNCTION fn_VerificarDisponibilidadStock(idProducto INT, cantidadSolicitada INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    RETURN (
        SELECT stock >= cantidadSolicitada
        FROM productos
        WHERE id_producto = idProducto
    );
END;


-- 3. fn_ObtenerPrecioProducto
CREATE FUNCTION fn_ObtenerPrecioProducto(idProducto INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN (
        SELECT precio
        FROM productos
        WHERE id_producto = idProducto
    );
END;


-- 4. fn_CalcularEdadCliente
CREATE FUNCTION fn_CalcularEdadCliente(idCliente INT)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN (
        SELECT TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE())
        FROM clientes
        WHERE id_cliente = idCliente
    );
END;


-- 5. fn_FormatearNombreCompleto
CREATE FUNCTION fn_FormatearNombreCompleto(idCliente INT)
RETURNS VARCHAR(300)
DETERMINISTIC
BEGIN
    RETURN (
        SELECT CONCAT(nombre, ' ', apellido)
        FROM clientes
        WHERE id_cliente = idCliente
    );
END;


-- 6. fn_EsClienteNuevo
CREATE FUNCTION fn_EsClienteNuevo(idCliente INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    RETURN (
        SELECT fecha_registro >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
        FROM clientes
        WHERE id_cliente = idCliente
    );
END;


-- 7. fn_CalcularCostoEnvio
CREATE FUNCTION fn_CalcularCostoEnvio(pesoTotal DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN pesoTotal * 5.00; -- costo fijo por kg
END;


-- 8. fn_AplicarDescuento
CREATE FUNCTION fn_AplicarDescuento(monto DECIMAL(10,2), porcentaje INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN monto - (monto * (porcentaje / 100));
END;


-- 9. fn_ObtenerUltimaFechaCompra
CREATE FUNCTION fn_ObtenerUltimaFechaCompra(idCliente INT)
RETURNS DATETIME
DETERMINISTIC
BEGIN
    RETURN (
        SELECT MAX(fecha_venta)
        FROM ventas
        WHERE id_cliente = idCliente
    );
END;


-- 10. fn_ValidarFormatoEmail
CREATE FUNCTION fn_ValidarFormatoEmail(email VARCHAR(255))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    RETURN email LIKE '%_@_%._%';
END;


-- 11. fn_ObtenerNombreCategoria
CREATE FUNCTION fn_ObtenerNombreCategoria(idProducto INT)
RETURNS VARCHAR(200)
DETERMINISTIC
BEGIN
    RETURN (
        SELECT c.nombre
        FROM productos p
        JOIN categorias c ON p.id_categoria = c.id_categoria
        WHERE p.id_producto = idProducto
    );
END;


-- 12. fn_ContarVentasCliente
CREATE FUNCTION fn_ContarVentasCliente(idCliente INT)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN (
        SELECT COUNT(*)
        FROM ventas
        WHERE id_cliente = idCliente
    );
END;


-- 13. fn_CalcularDiasDesdeUltimaCompra
CREATE FUNCTION fn_CalcularDiasDesdeUltimaCompra(idCliente INT)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN (
        SELECT DATEDIFF(CURDATE(), MAX(fecha_venta))
        FROM ventas
        WHERE id_cliente = idCliente
    );
END;


-- 14. fn_DeterminarEstadoLealtad
CREATE FUNCTION fn_DeterminarEstadoLealtad(idCliente INT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE gastoTotal DECIMAL(10,2);

    SET gastoTotal = (
        SELECT SUM(d.cantidad * d.precio_unitario_congelado)
        FROM ventas v
        JOIN detalle_ventas d ON v.id_venta = d.id_venta
        WHERE v.id_cliente = idCliente
    );

    IF gastoTotal >= 5000 THEN
        RETURN 'Oro';
    ELSEIF gastoTotal >= 2000 THEN
        RETURN 'Plata';
    ELSE
        RETURN 'Bronce';
    END IF;
END;


-- 15. fn_GenerarSKU
CREATE FUNCTION fn_GenerarSKU(nombreProd VARCHAR(100), categoria VARCHAR(100))
RETURNS VARCHAR(200)
DETERMINISTIC
BEGIN
    RETURN CONCAT('SKU-', UPPER(LEFT(nombreProd,3)), '-', UPPER(LEFT(categoria,3)), '-', FLOOR(RAND()*9999));
END;


-- 16. fn_CalcularIVA
CREATE FUNCTION fn_CalcularIVA(monto DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN monto * 0.12;
END;


-- 17. fn_ObtenerStockTotalPorCategoria
CREATE FUNCTION fn_ObtenerStockTotalPorCategoria(idCategoria INT)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN (
        SELECT SUM(stock)
        FROM productos
        WHERE id_categoria = idCategoria
    );
END;


-- 18. fn_EstimarFechaEntrega
CREATE FUNCTION fn_EstimarFechaEntrega(idCliente INT)
RETURNS DATE
DETERMINISTIC
BEGIN
    RETURN DATE_ADD(CURDATE(), INTERVAL 5 DAY);
END;


-- 19. fn_ConvertirMoneda
CREATE FUNCTION fn_ConvertirMoneda(monto DECIMAL(10,2), tasa DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN monto * tasa;
END;


-- 20. fn_ValidarComplejidadContraseña
CREATE FUNCTION fn_ValidarComplejidadContraseña(pass VARCHAR(255))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    RETURN (
        pass REGEXP '[A-Z]' AND
        pass REGEXP '[a-z]' AND
        pass REGEXP '[0-9]' AND
        LENGTH(pass) >= 8
    );
END;
