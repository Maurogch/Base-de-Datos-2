/*1) Crear un Stored Procedure que dado un cliente, se genere una liquidación
con todas las facturas no liquidadas para el mismo. Una factura no está
liquidada cuando no tiene un id_liquidacion asociado. Tener en cuenta que
se pueden insertar nuevas facturas mientras se está generando una
liquidación. Escriba también las instrucciones necesarias para garantizar
la atomicidad de la operación. */
set autocommit = 0;

/*query for cursor
select f.idFactura, sum(precio_total)
from facturas f
inner join items i
on f.idFactura = i.idFactura
where idLiquidacion is null
and idCliente = 1
group by f.idFactura
*/
drop procedure generar_liquidacion;
create procedure generar_liquidacion(in vIdCliente int)
begin
	
    declare vIdFactura int;
    declare vTotal float default 0;
    declare vFin int default 0;
    declare vTotalFacturas int default 0;
    declare vTotalLiquidacion int default 0;
    declare vIdLiquidacion int;

    declare leerFacturas cursor for
        select f.idFactura, sum(precio_total)
        from facturas f
        inner join items i
        on f.idFactura = i.idFactura
        where idLiquidacion is null
        and idCliente = vIdCliente
        group by f.idFactura;

    declare continue handler for not found set vFin = 1;

	start transaction;    

    insert into liquidaciones (idCliente, fecha)
    values (vIdCliente, now());

    set vIdLiquidacion = last_insert_id();

    open leerFacturas;

    leer: loop
        fetch leerFacturas into vIdFactura, vTotal;

        if vFin = 1 then
            leave leer;
        end if;

        set vTotalLiquidacion = vTotalLiquidacion + vTotal;
        set vTotalFacturas = vTotalFacturas + 1;

        update facturas
        set idLiquidacion = vIdLiquidacion
        where idFactura = vIdFactura;
    end loop leer;

    close leerFacturas;

    update liquidaciones
    set cantidadFacturas = vTotalFacturas, total = vTotalLiquidacion
    where idLiquidacion = vIdLiquidacion;
    
    commit;
end;

select * from liquidaciones;
select * from facturas;

call generar_liquidacion(1);

/*2) Crear los triggers necesarios para garantizar las siguientes operaciones :
○ Restar el stock de los productos cuando se ingresa un item. (1.5 puntos)*/

create trigger tia_update_stock_producto after insert
on items
for each row
begin
    update productos
    set stock = stock - new.cantidad
    where idProducto = new.idProducto;
end;

select * from productos;

insert into items (cantidad, precio_total, idFactura, idProducto)
values (1, 60, 5, 1);

create trigger tua_update_stock_producto after update
on items
for each row
begin
    update productos
    set stock = old.cantidad - new.cantidad
    where old.idProducto;
end;

create trigger tda_update_stock_producto after delete
on items
for each row
begin
    update productos
    set stock = stock + old.cantidad
    where old.idProducto;
end;

/*○ No insertar un item si no hay stock del producto seleccionado, además generar un
error para identificar el problema. (1 punto).*/

create trigger tib_check_stock_producto before insert
on items
for each row
begin
    declare vStock int;

    select stock into vStock
    from productos
    where idProducto = new.idProducto;

    if (vStock <= 0) then
        set @text = concat('Alerta intento de ingresar producto ',new.idProducto,
                                ', por falta de stock');
        
        insert into alertas (descripcion, fecha)
        values (@text, now());

        signal sqlstate '11111' 
            set message_text = 'No hay stock del producto',
                mysql_errno = 1000;
    end if;
end;

update productos
set stock = 0
where idProducto = 1;

select * from productos;

insert into items (cantidad, precio_total, idFactura, idProducto)
values (3,100, 1, 1); 
#funciona da singal

/*○ Generar un registro en la tabla Alertas, cada vez que un producto quede con menos stock
que el stock mínimo. (1.5 puntos).*/
drop trigger tia_alert_stock;

create trigger tia_alert_stock after insert
on items
for each row
begin
    declare vStock int;
    declare vStockMinimo int;
    declare vText text;

    select stock, stock_minimo into vStock, vStockMinimo
    from productos
    where idProducto = new.idProducto;

    if vStock <= vStockMinimo then
        set vText = concat("Producto id: ", new.idProducto, " está por debajo del stock mínimo");

        insert into alertas (descripcion, fecha)
        values (vText, now());
    end if;
end;

insert into items (cantidad, precio_total, idFactura, idProducto)
values (3,100, 1, 1);

select * from alertas;

/*Crear una vista que liste el total liquidado para cada cliente. En caso de
que el cliente no tenga liquidaciones asociadas, se debe mostrar 0.*/

create view total_liquidado as
select cuit, razonSocial, ifnull(sum(total),0) as total
from clientes c
left join liquidaciones l
on c.idCliente = l.idCliente
group by c.idCliente

select * from total_liquidado
