DROP TABLE IF EXISTS items;
DROP TABLE IF EXISTS facturas;
DROP TABLE IF EXISTS liquidacion;
DROP TABLE IF EXISTS clientes;
CREATE TABLE clientes (id_cliente int AUTO_INCREMENT primary key, razon_social varchar(50), cuit varchar(50));
CREATE TABLE liquidacion (id_liquidacion int AUTO_INCREMENT primary key, id_cliente int, cantidad_facturas int, fecha datetime, total float,foreign key fk_liquidacion_clientes(id_cliente) references clientes(id_cliente));
CREATE TABLE facturas (id_factura int AUTO_INCREMENT primary key, numero varchar(50), id_cliente int, fecha date, foreign key fk_facturas_cliente (id_cliente) references clientes(id_cliente) ON DELETE CASCADE);
CREATE TABLE items(id_item int auto_increment primary key,id_factura int, numero varchar(50), producto varchar(50), precio_unitario float, cantidad float , foreign key fk_item_facturas (id_factura) references facturas(id_factura) ON DELETE CASCADE);
ALTER TABLE facturas add id_liquidacion int ;
ALTER TABLE facturas add foreign key fk_facturas_liquidacion (id_liquidacion) references liquidacion(id_liquidacion);
insert into clientes (razon_social, cuit) values ('Cliente 1','CLIENTE1');
insert into clientes (razon_social, cuit) values ('Cliente 2','CLIENTE2');
insert into clientes (razon_social, cuit) values ('Cliente 3','CLIENTE3');
insert into clientes (razon_social, cuit) values ('Cliente 4','CLIENTE4');
insert into facturas (id_factura, id_cliente, numero, fecha) values (1,1,'1','2017-01-01');
insert into items (id_factura, producto, precio_unitario,cantidad) values (1,'prd1',10,5);
insert into items (id_factura, producto, precio_unitario,cantidad) values (1,'prd2',20,3);
insert into items (id_factura, producto, precio_unitario,cantidad) values (1,'prd1',50,1);
insert into facturas (id_factura, id_cliente, numero, fecha) values (2,1,'2','2017-01-02');
insert into items (id_factura, producto, precio_unitario,cantidad) values (2,'prd3',60,5);
insert into items (id_factura, producto, precio_unitario,cantidad) values (2,'prd4',20,1);
insert into items (id_factura, producto, precio_unitario,cantidad) values (2,'prd5',10,1);
insert into facturas (id_factura, id_cliente, numero, fecha) values (3,1,'3','2017-01-03');
insert into items (id_factura, producto, precio_unitario,cantidad) values (3,'prd3',60,5);
insert into items (id_factura, producto, precio_unitario,cantidad) values (3,'prd4',20,1);
insert into items (id_factura, producto, precio_unitario,cantidad) values (3,'prd5',10,1);
insert into facturas (id_factura, id_cliente, numero, fecha) values (4,1,'4','2017-01-04');
insert into items (id_factura, producto, precio_unitario,cantidad) values (4,'prd3',60,5);
insert into items (id_factura, producto, precio_unitario,cantidad) values (4,'prd4',20,1);
insert into items (id_factura, producto, precio_unitario,cantidad) values (4,'prd5',10,1);
insert into facturas (id_factura, id_cliente, numero, fecha) values (5,2,'1','2017-01-05');
insert into items (id_factura, producto, precio_unitario,cantidad) values (5,'prd3',60,5);
insert into items (id_factura, producto, precio_unitario,cantidad) values (5,'prd4',20,1);
insert into items (id_factura, producto, precio_unitario,cantidad) values (5,'prd5',10,1);
insert into facturas (id_factura, id_cliente, numero, fecha) values (6,2,'2','2017-01-02');
insert into items (id_factura, producto, precio_unitario,cantidad) values (6,'prd3',60,5);
insert into items (id_factura, producto, precio_unitario,cantidad) values (6,'prd4',20,1);
insert into items (id_factura, producto, precio_unitario,cantidad) values (6,'prd5',10,1);
insert into facturas (id_factura, id_cliente, numero, fecha) values (7,2,'3','2017-01-03');
insert into items (id_factura, producto, precio_unitario,cantidad) values (7,'prd3',60,5);
insert into items (id_factura, producto, precio_unitario,cantidad) values (7,'prd4',20,1);
insert into items (id_factura, producto, precio_unitario,cantidad) values (7,'prd5',10,1);
insert into facturas (id_factura, id_cliente, numero, fecha) values (8,3,'1','2017-02-01');
insert into items (id_factura, producto, precio_unitario,cantidad) values (8,'prd3',60,5);
insert into items (id_factura, producto, precio_unitario,cantidad) values (8,'prd4',20,1);
insert into items (id_factura, producto, precio_unitario,cantidad) values (8,'prd5',10,1);
insert into facturas (id_factura, id_cliente, numero, fecha) values (9,3,'1','2017-02-01');
insert into items (id_factura, producto, precio_unitario,cantidad) values (9,'prd3',60,5);
insert into items (id_factura, producto, precio_unitario,cantidad) values (9,'prd4',20,1);
insert into items (id_factura, producto, precio_unitario,cantidad) values (9,'prd5',10,1);