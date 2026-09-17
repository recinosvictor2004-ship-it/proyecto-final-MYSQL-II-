# 📘 README — PROYECTO_FINAL

## 🧾 Descripción General  
Este proyecto implementa un sistema completo de gestión para productos, clientes, ventas, inventario y auditorías utilizando MySQL. Incluye el diseño del esquema, funciones, procedimientos almacenados, triggers, consultas avanzadas y configuración de seguridad con roles y permisos.

El objetivo es demostrar dominio total de SQL mediante la construcción de una base de datos robusta, automatizada y segura.

---

## 🗂️ Diagrama de Base de Datos  
Aquí va la imagen del diagrama  
*(cuando la tengas, la insertás en esta sección)*

---

## 🧱 Componentes del Proyecto

### 1. Esquema de Base de Datos  
Incluye todas las tablas principales del sistema, relaciones, claves primarias, claves foráneas, restricciones y tablas de auditoría.  
Se agregaron campos esenciales como `total`, `fecha_registro` y `umbral_minimo`.

### 2. Consultas Avanzadas  
Se desarrollaron 20 consultas que permiten obtener información relevante del sistema, como:  
- Ventas por cliente  
- Productos más vendidos  
- Carritos abandonados  
- Promociones activas  
- Vistas de productos  
- Reportes por mes y por categoría  

### 3. Funciones Almacenadas  
Incluye 20 funciones que realizan cálculos y validaciones importantes, como:  
- Calcular total de venta  
- Verificar disponibilidad de stock  
- Calcular edad  
- Formatear nombre completo  
- Validar email  
- Determinar estado de lealtad  
- Convertir moneda  
- Validar complejidad de contraseña  

### 4. Procedimientos Almacenados  
Se implementaron 20 procedimientos para operaciones CRUD y reportes, incluyendo:  
- Crear, actualizar y eliminar clientes  
- Crear y actualizar productos  
- Crear ventas y agregar detalles  
- Reportes mensuales y por cliente  
- Actualización de contraseñas  
- Búsqueda por categoría o proveedor  

### 5. Triggers  
Se desarrollaron 20 triggers que automatizan procesos críticos del sistema, como:  
- Auditoría de cambios de precio  
- Auditoría de stock  
- Auditoría de clientes y ventas  
- Validación de stock antes de vender  
- Actualización automática del total de venta  
- Bloqueo de eliminación de productos con ventas  
- Validación de SKU único  
- Registro de cambios de categoría  
- Registro de cambios de email y contraseña  

### 6. Seguridad y Roles  
Incluye la creación de roles, usuarios y permisos específicos para cada área del sistema, como:  
- Administrador del sistema  
- Gerente de marketing  
- Analista de datos  
- Empleado de inventario  
- Atención al cliente  
- Auditor financiero  
- Visitante  

También se implementaron políticas de contraseñas seguras y vistas protegidas para evitar exposición de información sensible.

---

## 🎯 Objetivo del Proyecto  
El objetivo es demostrar dominio completo de MySQL mediante:  
- Diseño profesional de base de datos  
- Automatización con triggers  
- Reutilización con funciones  
- Operaciones con procedimientos  
- Consultas avanzadas  
- Seguridad y control de acceso  

---

## 🛠️ Tecnologías Utilizadas  
- MySQL 8.0  
- Workbench / CLI  
- SQL estándar  

---

## 👤 Autor  
**Victor Manuel Recinos Gómez**  
Universidad de San Carlos de Guatemala y Campuslands Guatemala 
Ingeniería en Ciencias y Sistemas
