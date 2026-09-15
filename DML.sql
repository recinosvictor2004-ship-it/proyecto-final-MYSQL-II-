INSERT INTO categorias (nombre, descripcion)
VALUES 
('Electrónica', 'Productos electrónicos y gadgets'),
('Ropa', 'Prendas de vestir para todas las edades'),
('Hogar', 'Artículos para el hogar y decoración');


INSERT INTO proveedores (nombre, email_contacto, telefono_contacto)
VALUES
('TechWorld S.A.', 'contacto@techworld.com', '5555-1234'),
('ModaPlus', 'ventas@modaplus.com', '5555-5678'),
('CasaBella', 'info@casabella.com', '5555-9012');

INSERT INTO clientes (nombre, apellido, email, contraseña, direccion_envio, fecha_nacimiento)
VALUES
('Carlos', 'Ramírez', 'carlos@gmail.com', 'hash123', 'Zona 10, Guatemala', '1995-04-12'),
('Ana', 'López', 'ana@gmail.com', 'hash456', 'Mixco, Zona 4', '1998-09-22'),
('Luis', 'Martínez', 'luis@gmail.com', 'hash789', 'Villa Nueva', '1990-01-30');


INSERT INTO productos (nombre, descripcion, precio, costo, stock, sku, id_categoria, id_proveedor)
VALUES
('Laptop Lenovo', 'Laptop de 14 pulgadas', 4500.00, 3000.00, 10, 'SKU-LEN-001', 1, 1),
('Camisa Casual', 'Camisa de algodón', 150.00, 80.00, 50, 'SKU-CAM-002', 2, 2),
('Silla de Oficina', 'Silla ergonómica', 850.00, 500.00, 20, 'SKU-SIL-003', 3, 3);


INSERT INTO ventas (estado, id_cliente)
VALUES
('Procesando', 1),
('Enviado', 2),
('Pendiente de Pago', 3);


INSERT INTO detalle_ventas (cantidad, precio_unitario_congelado, id_venta, id_producto)
VALUES
(1, 4500.00, 1, 1),
(2, 150.00, 2, 2),
(1, 850.00, 3, 3);
