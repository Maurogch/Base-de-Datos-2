/*1 - Generar un stored procedure que liste los jugadores y a que equipo pertenecen
utilizando cursores.*/
drop procedure listarJugadoresEquipo;
create procedure listarJugadoresEquipo()
begin
    declare vFin int default 0;
    declare vApellido varchar(50);
    declare vNombre varchar(50);
    declare vEquipo varchar(50);

    declare leerJugadores cursor for select apellido, nombre, equipo
                                    from jugadores j
                                    inner join equipos e
                                    on j.idEquipo = e.idEquipo
                                    order by equipo, apellido;
    declare continue handler for not found set vFin = 1;
    open leerJugadores;

    leer: LOOP
        fetch leerJugadores into vApellido, vNombre, vEquipo;
        select vApellido, vNombre, vEquipo;

        if vFin = 1 then
            leave leer;
        end if;
    END LOOP leer;

    close leerJugadores;
end;

call listarJugadoresEquipo();

/*2 - Generar un stored procedure que liste los resultados de todos los partidos.*/

#Query for equipo and puntos
select el.equipo as "Equipo Local", ev.equipo as "Equipo Visitante", 
    ifnull((select sum(puntos)
    from jugadores_x_equipo_x_partido jxe
    where jxe.idPartido = el.idEquipo),0) as"Puntos Local",
    ifnull((select sum(puntos)
    from jugadores_x_equipo_x_partido jxe
    where jxe.idPartido = ev.idEquipo),0) as"Puntos Visitante"
from partidos p 
inner join equipos el
on p.idEquipoLocal = el.idEquipo
inner join equipos ev
on p.idEquipoVisitante = ev.idEquipo

#Stored Procedure
drop procedure resultadosPartidos;
create procedure resultadosPartidos()
begin
    declare vEquipoLocal varchar(50);
    declare vEquipoVisitante varchar(50);
    declare vPuntosLocal int;
    declare vPuntosVisitante int;
    declare vFin int default 0;

    declare leerPartidos cursor for select el.equipo, ev.equipo, 
                                        ifnull((select sum(puntos)
                                        from jugadores_x_equipo_x_partido jxe
                                        where jxe.idPartido = el.idEquipo),0),
                                        ifnull((select sum(puntos)
                                        from jugadores_x_equipo_x_partido jxe
                                        where jxe.idPartido = ev.idEquipo),0)
                                    from partidos p 
                                    inner join equipos el
                                    on p.idEquipoLocal = el.idEquipo
                                    inner join equipos ev
                                    on p.idEquipoVisitante = ev.idEquipo;
    
    declare continue handler for not found set vFin = 1;
    open leerPartidos;

    leer: loop
        fetch leerPartidos into vEquipoLocal, vEquipoVisitante, vPuntosLocal, vPuntosVisitante;
        select vEquipoLocal, vEquipoVisitante, vPuntosLocal, vPuntosVisitante;

        if vFin = 1 then
            leave leer;
        end if;
    end loop leer;
end;

call resultadosPartidos();

/*3 - Generar un stored procedure que agregue el resultado del partido en la 
tabla partidos*/

#If table is old and doesn't have these columns
alter table partidos
add column puntosEquipoLocal int default 0;

alter table partidos
add column puntosEquipoVisitante int default 0;
#----------

drop procedure agregarResultadoPartido;
create procedure agregarResultadoPartido()
begin
    declare vIdPartido int;
    declare vPuntosLocal int;
    declare vPuntosVisitante int;
    declare vFin int default 0;

    declare leerPartidos cursor for select p.idPartido, 
                                        ifnull((select sum(puntos)
                                        from jugadores_x_equipo_x_partido jxe
                                        where jxe.idPartido = el.idEquipo),0),
                                        ifnull((select sum(puntos)
                                        from jugadores_x_equipo_x_partido jxe
                                        where jxe.idPartido = ev.idEquipo),0)
                                    from partidos p 
                                    inner join equipos el
                                    on p.idEquipoLocal = el.idEquipo
                                    inner join equipos ev
                                    on p.idEquipoVisitante = ev.idEquipo;
    
    declare continue handler for not found set vFin = 1;
    open leerPartidos;

    leer: loop
        fetch leerPartidos into vIdPartido, vPuntosLocal, vPuntosVisitante;
        
        if vFin = 1 then
            leave leer;
        end if;
         
        update partidos
        set puntosEquipoLocal = vPuntosLocal,
            puntosEquipoVisitante = vPuntosVisitante
        where idPartido = vIdPartido;
    end loop leer;
end;

select * from partidos;

call agregarResultadoPartido();

select * from partidos;

/*4 - Generar un stored procedure que calcule el promedio de puntos realizado por cada
jugador y lo guarde en un campo en la tabla jugador*/

#Add columns if not exist
alter table jugadores
add column promedio float default 0;
#

drop procedure agregarPromedioJugadores;
create procedure agregarPromedioJugadores()
begin
    declare vIdJugador int;
    declare vPromedio float;
    declare vFin int default 0;

    declare leerJugadores cursor for select j.idJugador, avg(puntos)
                                    from jugadores j
                                    inner join jugadores_x_equipo_x_partido jxe
                                    on j.idJugador = jxe.idJugador
                                    group by j.idJugador;
    
    declare continue handler for not found set vFin = 1;
    open leerJugadores;

    leer: loop
        fetch leerJugadores into vIdJugador, vPromedio;
        
        if vFin = 1 then
            leave leer;
        end if;
        
        update jugadores
        set promedio = vPromedio
        where idJugador = vIdJugador;
    end loop leer;
end;

select * from jugadores;

call agregarPromedioJugadores();

select * from jugadores;

/*5 - Generar una tabla con el nombre records_jugadores, donde se guarde la máxima
cantidad de puntos hecha por un jugador y en que partido lo hizo.*/

