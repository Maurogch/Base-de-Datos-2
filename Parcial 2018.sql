/*segunda parte de ejecicio 2*/
update estadisticas_por_marca
set kilometros = kilometros - (select distancia from rutas where id = old.id_ruta),
    viajes = viajes - 1
where marca = (select marca from colectivos where id = old.id_colectivo);

update estadisticas_por_marca
set kilometros = kilometros + (select distancia from rutas where id = new.id_ruta),
    viajes = viajes + 1
where marca = (select marca from colectivos where id = new.id_colectivo);

end;

/*3*/

create view viajes_echos as
select c1.nombre_ciudad as ciudad_origen, c2.nombre_ciudad as ciudad_destino, r.distancia, 
    concat(ch.apellido, " ", ch.nombre) as chofer, v.fecha
from viajes v
inner join rutas r
on v.id_ruta = r.id
inner join ciudades c1
on r.id_ciudad_origen = c1.id
inner join ciudades c2
on r.id_ciudad_destino = c2.id
inner join choferes ch
on v.id_chofer = ch.id;

/*4 extra*/

create function sumar_test(a int, b int)
returns int deterministic
return a + b;

select sumar_test(1,2)

/*4*/

create procedure (in vIdChofer int)
begin
    select ifnull(sum(sueldo),0) as"Total Sueldo"
    from sueldos
    where id_chofer = vIdChofer;
end;
