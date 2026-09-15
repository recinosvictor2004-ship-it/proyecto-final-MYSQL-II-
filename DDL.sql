CREATE DATABASE PROYECTO_FINAL;
USE PROYECTO_FINAL;

-- 1. TABLA CATEGORIAS
CREATE TABLE categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
);

-- 2. TABLA PROVEEDORES
CREATE TABLE proveedores (
    id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    email_contacto VARCHAR(150) UNIQUE,
    telefono_contacto VARCHAR(30),
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 3. TABLA CLIENTES
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    contraseña VARCHAR(255) NOT NULL,
    direccion_envio TEXT,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_nacimiento DATE
);

CREATE TABLE productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    costo DECIMAL(10,2) NOT NULL CHECK (costo >= 0),
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    sku VARCHAR(50) NOT NULL UNIQUE,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    
    id_categoria INT NOT NULL,
    id_proveedor INT NOT NULL,

    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria),
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor)
);


-- 5. TABLA VENTAS
CREATE TABLE ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('Pendiente de Pago','Procesando','Enviado','Entregado','Cancelado') NOT NULL,
    total DECIMAL(10,2) NOT NULL DEFAULT 0,
    id_cliente INT NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- 6. TABLA DETALLE_VENTAS
CREATE TABLE detalle_ventas (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario_congelado DECIMAL(10,2) NOT NULL,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    FOREIGN KEY (id_venta) REFERENCES ventas(id_venta),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);
