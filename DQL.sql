-- 1. Top 10 Productos Más Vendidos (por ingresos)
SELECT 
    p.nombre,
    SUM(d.cantidad * d.precio_unitario_congelado) AS ingresos_totales
FROM detalle_ventas d
JOIN productos p ON d.id_producto = p.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY ingresos_totales DESC
LIMIT 10;


-- 2. Productos con Bajas Ventas 
SET @limite := CEIL((SELECT COUNT(*) FROM productos) * 0.1);

SELECT 
    p.nombre,
    SUM(d.cantidad * d.precio_unitario_congelado) AS ingresos_totales
FROM detalle_ventas d
JOIN productos p ON d.id_producto = p.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY ingresos_totales ASC
LIMIT @limite;

-- 3. Clientes VIP 
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
LIMIT 5;


-- 4. Análisis de Ventas Mensuales 
SELECT 
    YEAR(fecha_venta) AS año,
    MONTH(fecha_venta) AS mes,
    SUM(total) AS ventas_totales
FROM ventas
GROUP BY año, mes
ORDER BY año, mes;
ALTER TABLE ventas ADD total DECIMAL(10,2) DEFAULT 0;

-- 5. Crecimiento de Clientes 
SELECT 
    YEAR(fecha_registro) AS año,
    QUARTER(fecha_registro) AS trimestre,
    COUNT(*) AS nuevos_clientes
FROM clientes
GROUP BY año, trimestre
ORDER BY año, trimestre;
ALTER TABLE clientes ADD fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP;


-- 6. Tasa de Compra Repetida
SELECT 
    (COUNT(*) / (SELECT COUNT(*) FROM clientes)) * 100 AS porcentaje_repetidores
FROM (
    SELECT id_cliente, COUNT(*) AS compras
    FROM ventas
    GROUP BY id_cliente
    HAVING compras > 1
) AS clientes_repetidores;


-- 7. Productos Comprados Juntos Frecuentemente
SELECT 
    p1.nombre AS producto_1,
    p2.nombre AS producto_2,
    COUNT(*) AS veces_comprados_juntos
FROM detalle_ventas d1
JOIN detalle_ventas d2 
    ON d1.id_venta = d2.id_venta
    AND d1.id_producto < d2.id_producto
JOIN productos p1 ON d1.id_producto = p1.id_producto
JOIN productos p2 ON d2.id_producto = p2.id_producto
GROUP BY producto_1, producto_2
ORDER BY veces_comprados_juntos DESC;


-- 8. Rotación de Inventario 
SELECT 
    c.nombre AS categoria,
    SUM(d.cantidad) AS unidades_vendidas,
    SUM(p.stock) AS stock_actual,
    SUM(d.cantidad) / NULLIF(SUM(p.stock),0) AS rotacion_aproximada
FROM detalle_ventas d
JOIN productos p ON d.id_producto = p.id_producto
JOIN categorias c ON p.id_categoria = c.id_categoria
GROUP BY c.id_categoria, c.nombre
ORDER BY rotacion_aproximada DESC;


-- 9. Productos que Necesitan Reabastecimiento 
SELECT 
    nombre,
    stock,
    umbral_minimo
FROM productos
WHERE stock < umbral_minimo;


-- 10. Análisis de Carrito Abandonado 
SELECT 
    c.id_cliente,
    COUNT(*) AS carritos_abandonados
FROM carritos ca
JOIN clientes c ON ca.id_cliente = c.id_cliente
WHERE ca.estado = 'Abandonado'
  AND ca.fecha_creacion BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY c.id_cliente;


-- 11. Rendimiento de Proveedores (volumen de ventas de sus productos)
SELECT 
    pr.id_proveedor,
    pr.nombre AS proveedor,
    SUM(d.cantidad * d.precio_unitario_congelado) AS ingresos_totales
FROM detalle_ventas d
JOIN productos p ON d.id_producto = p.id_producto
JOIN proveedores pr ON p.id_proveedor = pr.id_proveedor
GROUP BY pr.id_proveedor, pr.nombre
ORDER BY ingresos_totales DESC;


-- 12. Análisis Geográfico de Ventas 
SELECT 
    c.direccion_envio AS region,
    COUNT(v.id_venta) AS cantidad_ventas,
    SUM(v.total) AS total_ventas
FROM ventas v
JOIN clientes c ON v.id_cliente = c.id_cliente
GROUP BY region
ORDER BY total_ventas DESC;


-- 13. Ventas por Hora del Día (horas pico)
SELECT 
    HOUR(fecha_venta) AS hora,
    COUNT(*) AS cantidad_ventas,
    SUM(total) AS total_ventas
FROM ventas
GROUP BY hora
ORDER BY cantidad_ventas DESC;


-- 14. Impacto de Promociones 
SELECT 
    p.nombre,
    SUM(CASE WHEN v.fecha_venta < promo.fecha_inicio THEN d.cantidad * d.precio_unitario_congelado ELSE 0 END) AS ventas_antes,
    SUM(CASE WHEN v.fecha_venta BETWEEN promo.fecha_inicio AND promo.fecha_fin THEN d.cantidad * d.precio_unitario_congelado ELSE 0 END) AS ventas_durante,
    SUM(CASE WHEN v.fecha_venta > promo.fecha_fin THEN d.cantidad * d.precio_unitario_congelado ELSE 0 END) AS ventas_despues
FROM detalle_ventas d
JOIN ventas v ON d.id_venta = v.id_venta
JOIN productos p ON d.id_producto = p.id_producto
JOIN promociones promo ON promo.id_producto = p.id_producto
GROUP BY p.id_producto, p.nombre;


-- 15. Análisis de Cohort 
SELECT 
    c.id_cliente,
    MIN(DATE_FORMAT(v.fecha_venta, '%Y-%m')) AS mes_cohort,
    COUNT(*) AS compras_totales
FROM ventas v
JOIN clientes c ON v.id_cliente = c.id_cliente
GROUP BY c.id_cliente, mes_cohort
ORDER BY mes_cohort;


-- 16. Margen de Beneficio por Producto 
SELECT 
    p.id_producto,
    p.nombre,
    p.precio,
    p.costo,
    (p.precio - p.costo) AS margen_unitario,
    SUM(d.cantidad * (d.precio_unitario_congelado - p.costo)) AS margen_total
FROM productos p
JOIN detalle_ventas d ON p.id_producto = d.id_producto
GROUP BY p.id_producto, p.nombre, p.precio, p.costo
ORDER BY margen_total DESC;


-- 17. Tiempo Promedio Entre Compras 
SELECT 
    v.id_cliente,
    AVG(DATEDIFF(lead_fecha, fecha_venta)) AS dias_promedio_entre_compras
FROM (
    SELECT 
        id_cliente,
        fecha_venta,
        LEAD(fecha_venta) OVER (PARTITION BY id_cliente ORDER BY fecha_venta) AS lead_fecha
    FROM ventas
) v
WHERE lead_fecha IS NOT NULL
GROUP BY v.id_cliente;


-- 18. Productos Más Vistos vs. Comprados

SELECT 
    p.nombre,
    COALESCE(vv.vistas, 0) AS total_vistas,
    COALESCE(vc.compras, 0) AS total_compras
FROM productos p
LEFT JOIN (
    SELECT id_producto, COUNT(*) AS vistas
    FROM vistas_productos
    GROUP BY id_producto
) vv ON p.id_producto = vv.id_producto
LEFT JOIN (
    SELECT id_producto, SUM(cantidad) AS compras
    FROM detalle_ventas
    GROUP BY id_producto
) vc ON p.id_producto = vc.id_producto
ORDER BY total_vistas DESC;


-- 19. Segmentación de Clientes 
WITH rfm AS (
    SELECT 
        c.id_cliente,
        MAX(v.fecha_venta) AS ultima_compra,
        COUNT(v.id_venta) AS frecuencia,
        SUM(d.cantidad * d.precio_unitario_congelado) AS monetario
    FROM clientes c
    LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
    LEFT JOIN detalle_ventas d ON v.id_venta = d.id_venta
    GROUP BY c.id_cliente
)
SELECT 
    id_cliente,
    DATEDIFF(CURDATE(), ultima_compra) AS recencia_dias,
    frecuencia,
    monetario
FROM rfm
ORDER BY monetario DESC;


-- 20. Predicción de Demanda Simple 
WITH ventas_categoria AS (
    SELECT 
        c.id_categoria,
        c.nombre AS categoria,
        DATE_FORMAT(v.fecha_venta, '%Y-%m') AS mes,
        SUM(d.cantidad) AS unidades_vendidas
    FROM detalle_ventas d
    JOIN productos p ON d.id_producto = p.id_producto
    JOIN categorias c ON p.id_categoria = c.id_categoria
    JOIN ventas v ON d.id_venta = v.id_venta
    GROUP BY c.id_categoria, c.nombre, mes
),
ultimos_tres AS (
    SELECT 
        id_categoria,
        categoria,
        AVG(unidades_vendidas) AS promedio_3_meses
    FROM ventas_categoria
    WHERE mes >= DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 3 MONTH), '%Y-%m')
    GROUP BY id_categoria, categoria
)
SELECT 
    id_categoria,
    categoria,
    promedio_3_meses AS demanda_proyectada_proximo_mes
FROM ultimos_tres;