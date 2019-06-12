/*Create Administrator for database*/

create user 'KwikEMart_Admin'@'%.kwikemart.com' identified by 'admin';
#for testing
create user 'KwikEMart_Admin'@'localhost' identified by 'admin';

select user,host,Grant_priv from mysql.user;

grant all on kwikemart.* to 'KwikEMart_Admin'@'%.kwikemart.com' with grant option;
grant all on kwikemart.* to 'KwikEMart_Admin'@'localhost' with grant option;

show grants for 'KwikEMart_Admin'@'%sucursalX.kwikemart.com';
#show grants for CURRENT_USER();
#--------------------------------------------------------

/*La gerencia de RRHH se encuentra en el edificio principal. El módulo que utilizan
necesita ejecutar un procedimiento almacenado que reciba como parámetros un id
de cajero (es un empleado) y un día específico y devuelva el nombre del cajero, la
cantidad de facturas iniciadas y la cantidad de ítems fichados. Cree el/los usuarios
MySQL correspondientes, asigne los permisos que crea necesarios y luego cree el
procedimiento almacenado.*/

create definer = 'KwikEMart_Admin'@'%.kwikemart.com' procedure reviewEmployee
(in vIdEmpleado int, in vFecha date, out vNombre varchar(50), out vCantFacturas int,
 out vCantItems int)
sql security definer
begin
    select nombre into vNombre
    from empleados
    where id = vIdEmpleado;

    select count(f.id), (select count(i.id)
                        from item_factura i
                        where i.factura_id = f.id) into vCantFacturas, vCantItems
    from facturas f
    where empleado_id = vIdEmpleado
    and fecha = vFecha;
end;

#Create user for RRHH
create user 'KwikEMart_RRHH'@'principal.kwikemart.com' identified by 'rrhh';
#Grant privileges
grant execute on kwikemart.reviewEmployee to 'KwikEMart_RRHH'@'principal.kwikemart.com';

#--------------------------------------------------------------------------#

#Create user for Stock
create user 'KwikEMart_Stock'@'sucursal%.kwikemart.com' identified by 'stock';
#Grant privileges
grant select,update on kwikemart.productos to 'KwikEMart_Stock'@'sucursal%.kwikemart.com';
grant select,update on kwikemart.stock to 'KwikEMart_Stock'@'sucursal%.kwikemart.com';

create trigger tub_modificarStock before update
on stock
for each row
begin
    if (old.sucursal_id <> new.sucursal_id) then
        signal sqlstate '11111' 
            set message_text = 'Acceso al stock de otra sucursal prohibido',
                mysql_errno = 1000;
    end if;
end;

#--------------------------------------------------------------------------#

#Create user for Ventas
create user 'KwikEMart_Ventas'@'principal.kwikemart.com' identified by 'ventas';
#Grant privileges
grant execute on kwikemart.facturas to 'KwikEMart_Ventas'@'principal.kwikemart.com';
#Ejecuta un stored procedure que devuelve lo total facturado por cada sucursal

#--------------------------------------------------------------------------#

#Create users for Admin for each brach 
create user 'KwikEMart_small_Admin'@'sucursal1.kwikemart.com' identified by 'admin';
#Repeat 999 for every brach 
#Grant privileges
grant select on kwikemart.* to 'KwikEMart_Admin_sucursal1'@'sucursal%.kwikemart.com';


#--------------------------------------------------------------------------#

#Modulo gerencia corre un schedule de una api que llama a un stored procedure
#que devuelve los datos necesario, esto sirve

#suponiendo que no se puede usar un stored procedure
#usuario de gerencia
#persmiso selecet facturas
#no terminado

