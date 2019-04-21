delimiter $$
drop procedure eliminar_liquidaciones;
CREATE PROCEDURE eliminar_liquidaciones(pIdCliente int)
begin
	update facturas set id_liquidacion =null where id_cliente = pIdCliente;
    delete from liquidacion where id_cliente = id_cliente;
end
$$

delimiter $$
#drop  procedure liquidar_cliente_tradicional;
CREATE PROCEDURE liquidar_cliente_tradicional (pIdCliente int)
BEGIN
	declare vTotal float;
    declare vCant float;
    declare vDummy int;
    declare vIdLiquidacion int;
	select count(distinct f.id_factura), sum(i.precio_unitario * i.cantidad) into vCant, vTotal from facturas f inner join items i on f.id_factura = i.id_factura where f.id_liquidacion is null and f.id_cliente = pIdCliente;
	insert into liquidacion(id_cliente,cantidad_facturas, fecha , total) values (pIdCliente,vCant,now(),vTotal);
    #Se toma el id_liquidacion
    set vIdLiquidacion = last_insert_id();
    update facturas
    set id_liquidacion = vIdLiquidacion
    where id_cliente = pIdCliente and id_liquidacion is null;
END;
$$


#CREAR LIQUIDACION CURSORES
delimiter $$
drop procedure liquidar_cliente ;
CREATE PROCEDURE liquidar_cliente (pIdCliente int)
BEGIN
    DECLARE vTotal float;
    DECLARE vIdLiquidacion int;
    DECLARE vIdFactura int;
    DECLARE vCant int default 0;
    DECLARE vFinished int DEFAULT 0;
    DECLARE vSuma float default 0 ;
    DECLARE vDummy int;
    DECLARE cur_liquidacion CURSOR FOR select f.id_factura, sum(i.precio_unitario * i.cantidad) as total from facturas f inner join items i on f.id_factura = i.id_factura where f.id_liquidacion is null and f.id_cliente = pIdCliente group by f.id_factura;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET vFinished = 1;
    #Se inserta la liquidacion pero en 0 asi se puede updatear luego
    insert into liquidacion(id_cliente, fecha , total) values (pIdCliente,now(),0);
    #Se toma el id_liquidacion
    set vIdLiquidacion = last_insert_id();

    open cur_liquidacion;
    FETCH cur_liquidacion INTO   vIdFactura, vTotal;
    WHILE (vFinished=0) DO
        #se suman los datos de las facturas
        SET vSuma = vSuma + vTotal;
        SET vCant = vCant + 1;
        #Se updatea la factura asignandole la correspondiente liquidacion
        UPDATE facturas set id_liquidacion = vIdLiquidacion where id_factura = vIdFactura;
        FETCH cur_liquidacion INTO   vIdFactura, vTotal;
    END while;
    #Se asigna el total y la cantidad de facturas a la liquidacion
    update liquidacion set cantidad_facturas = vCant, total = vSuma where id_liquidacion = vIdLiquidacion;
    close cur_liquidacion;
END
$$

CALL eliminar_liquidaciones(1);
CALL liquidar_cliente_tradicional(1);
CALL liquidar_cliente(1);
select * from facturas
# INSERTAR LUEGO#
delete from facturas where id_factura = 10;
insert into facturas (id_factura, id_cliente, numero, fecha) values (10,1,'1','2017-03-01');
insert into items (id_factura, producto, precio_unitario,cantidad) values (10,'prd3',60,5);
insert into items (id_factura, producto, precio_unitario,cantidad) values (10,'prd4',20,1);
insert into items (id_factura, producto, precio_unitario,cantidad) values (10,'prd5',10,1);
