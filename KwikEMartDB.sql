CREATE DATABASE KwikEMart;
USE KwikEMart;

CREATE TABLE `productos` (
 `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
 `descripcion` varchar(50) NOT NULL,
 `monto` decimal(10,4) NOT NULL,
 PRIMARY KEY (`id`)
);

CREATE TABLE `clientes` (
 `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
 `razon_social` varchar(50) NOT NULL,
 `cuit` varchar(30) NOT NULL,
 PRIMARY KEY (`id`)
);

CREATE TABLE `sucursales` (
 `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
 `nombre` varchar(50) NOT NULL,
 `domicilio` varchar(50) NOT NULL,
 `host` varchar(50) NOT NULL,
 PRIMARY KEY (`id`)
);

CREATE TABLE `empleados` (
 `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
 `nombre` varchar(50) NOT NULL,
 `sucursal_id` int(10) unsigned NOT NULL,
 PRIMARY KEY (`id`)
);

CREATE TABLE `facturas` (
 `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
 `sucursal_id` int(10) unsigned NOT NULL,
 `empleado_id` int(10) unsigned NOT NULL,
 `cliente_id` int(10) unsigned NOT NULL,
 `fecha` datetime NOT NULL,
 `monto` decimal(10,4) NOT NULL,
 PRIMARY KEY (`id`)
);

CREATE TABLE `stock` (
 `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
 `sucursal_id` int(10) unsigned NOT NULL,
 `producto_id` int(10) unsigned NOT NULL,
 `cantidad` int(11) NOT NULL,
 PRIMARY KEY (`id`)
);

CREATE TABLE `item_factura` (
 `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
 `producto_id` int(10) unsigned NOT NULL,
 `factura_id` int(10) unsigned NOT NULL,
 `cantidad` int(11) NOT NULL,
 `monto` decimal(10,4) NOT NULL,
 PRIMARY KEY (`id`)
);