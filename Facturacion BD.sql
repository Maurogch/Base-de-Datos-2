create database facturacion;
use facturacion;

create table clientes(
    idCliente int auto_increment,
    razonSocial varchar(255) not null,
    cuit int,
    constraint pk_idCliente primary key (idCliente)
);

insert into clientes (razonSocial, cuit) values ('Selma Shotboulte', '261102689');
insert into clientes (razonSocial, cuit) values ('Ally Dovey', '704571533');
insert into clientes (razonSocial, cuit) values ('Aluin Ruse', '611323350');
insert into clientes (razonSocial, cuit) values ('Randall Culross', '843673023');
insert into clientes (razonSocial, cuit) values ('Willie Gregorin', '221548850');

create table liquidaciones(
    idLiquidacion int auto_increment,
    idCliente int,
    fecha datetime,
    cantidadFacturas int,
    total float,
    constraint pk_idLiquidacion primary key (idLiquidacion),
    constraint fk_idCliente_liquidaciones foreign key (idCliente) references clientes (idCliente)
);

create table facturas(
    idFactura int auto_increment,
    numero varchar(50),
    fecha datetime,
    tipo char(1),
    idCliente int,
    idLiquidacion int,
    constraint pk_idFactra primary key (idFactura),
    constraint fk_idCliente_facturas foreign key (idCliente) references clientes (idCliente),
    constraint fk_idLiquidacion_facturas foreign key (idLiquidacion) references liquidaciones (idLiquidacion)
);

insert into facturas (numero, fecha, tipo, idCliente)
values (1111,now(),'a',1),(1112,now(),'a',1),(1113,now(),'a',1),(1114,now(),'a',1);


insert into facturas (numero, fecha, tipo, idCliente)
values (1121,now(),'a',2),(1122,now(),'a',2);

create table productos(
    idProducto int auto_increment,
    descripcion varchar(50),
    stock int,
    stock_minimo int,
    constraint pk_idProducto primary key (idProducto)
);

insert into productos (descripcion, stock, stock_minimo) values ('Campari', 66, 10);
insert into productos (descripcion, stock, stock_minimo) values ('Fish - Artic Char, Cold Smoked', 70, 10);
insert into productos (descripcion, stock, stock_minimo) values ('Soup - French Onion', 41, 10);
insert into productos (descripcion, stock, stock_minimo) values ('Curry Powder', 68, 10);
insert into productos (descripcion, stock, stock_minimo) values ('Pasta - Canelloni', 96, 10);
insert into productos (descripcion, stock, stock_minimo) values ('Jack Daniels', 65, 10);
insert into productos (descripcion, stock, stock_minimo) values ('Juice - Ocean Spray Cranberry', 42, 10);
insert into productos (descripcion, stock, stock_minimo) values ('Alize Gold Passion', 76, 10);
insert into productos (descripcion, stock, stock_minimo) values ('Pasta - Rotini, Dry', 55, 10);
insert into productos (descripcion, stock, stock_minimo) values ('Sugar - Icing', 87, 10);

create table items(
    idItem int auto_increment,
    cantidad int,
    precio_total float,
    idFactura int,
    idProducto int,
    constraint pk_idItem primary key (idItem),
    constraint fk_idFactura_items foreign key (idFactura) references facturas (idFactura),
    constraint fk_idProducto_items foreign key (idProducto) references productos (idProducto)
);

insert into items (cantidad, precio_total, idFactura, idProducto)
values (3, 379, 1, 5), (2, 532, 1, 7);

insert into items (cantidad, precio_total, idFactura, idProducto)
values (2, 423, 2, 9), (6, 742, 2, 8);

insert into items (cantidad, precio_total, idFactura, idProducto)
values (7, 233, 3, 9), (4, 231, 3, 8);

insert into items (cantidad, precio_total, idFactura, idProducto)
values (3, 342, 4, 4), (8, 543, 4, 3);

insert into items (cantidad, precio_total, idFactura, idProducto)
values (3, 123, 5, 2), (8, 234, 5, 4);

insert into items (cantidad, precio_total, idFactura, idProducto)
values (3, 234, 6, 7), (8, 654, 6, 8);

create table alertas(
    idAlerta int auto_increment,
    descripcion text,
    fecha datetime,
    constraint pk_idAlerta primary key (idAlerta)
);

#---------------------------------------------------------------------------------------
#Clientes
#---------------------------------------------------------------------------------------



#---------------------------------------------------------------------------------------

