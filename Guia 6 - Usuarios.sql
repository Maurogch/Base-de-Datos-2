/*Create Administrator for database*/

create user 'KwikEMart_Admin'@'%sucursalX.kwikemart.com' identified by 'admin';
#for testing
create user 'KwikEMart_Admin'@'localhost' identified by 'admin';

select user,host,Grant_priv from mysql.user;

grant all on kwikemart.* to 'KwikEMart_Admin'@'%sucursalX.kwikemart.com' with grant option;
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

create definer = 'KwikEMart_Admin'@'localhost' procedure reviewEmployee
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
create user 'KwikEMart_RRHH'@'localhost' identified by 'rrhh';
#Grant privileges
grant execute on kwikemart.reviewEmployee to 'KwikEMart_RRHH'@'localhost';

#--------------------------------------------------------------------------#

