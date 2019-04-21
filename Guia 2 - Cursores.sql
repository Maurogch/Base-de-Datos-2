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

    close leerPartidos;
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

    declare leerPartidos cursor for 
        select p.idPartido, 
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

    close leerPartidos;
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

    declare leerJugadores cursor for 
        select j.idJugador, avg(puntos)
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

    close leerJugadores;
end;

select * from jugadores;

call agregarPromedioJugadores();

select * from jugadores;

/*5 - Generar una tabla con el nombre recordsJugadores, donde se guarde la máxima
cantidad de puntos hecha por un jugador y en que partido lo hizo.*/

-- Tabla tiene que ser primary foreign key? Como se guarda solo el mejor record no la hice
create table recordsJugadores(
    idRecord int auto_increment,
    idJugador int not null unique,
    idPartido int not null,
    record int not null,
    primary key (idRecord),
    foreign key (idJugador) references jugadores (idJugador),
    foreign key (idPartido) references partidos (idPartido)
);

/*Append: El siguiente query no sirve ya que agrupa y devuelve el primer row del todos los max
en este caso el partido no corresponde al max del jugador

select idJugador, idPartido, max(puntos)
from jugadores_x_equipo_x_partido
group by idJugador

--Para resolver eso se usa una query especial (solo es necesario cuando se necesita más que 
  el max y el valor a group by, en este caso el partido)
--Se llama en el primer query todos los valores normalmente, luego un inner join con un
  sub query a la misma tabla haciendo el max y el valor a agrupar, y en las condiciendoes
  del on se igualan ambos valores (importante poner alias al max)

select jxe.idJugador, jxe.idPartido, jxe.puntos
from jugadores_x_equipo_x_partido jxe
inner join (
    select idJugador, max(puntos) as puntos
    from jugadores_x_equipo_x_partido
    group by idJugador
) b on jxe.idJugador = b.idJugador and jxe.puntos = b.puntos
group by jxe.idJugador

--Por ultimo el group by final es por si hay resultados repetidos, ejemplo en dos partidos un jugador
  hizo 10 puntos
*/

drop procedure agregarRecordJugadores;
create procedure agregarRecordJugadores()
begin
    declare vIdJugador int;
    declare vIdPartido int;
    declare vPuntos int;
    declare vFin int default 0;

    declare leerJugadores cursor for
        select jxe.idJugador, jxe.idPartido, jxe.puntos
        from jugadores_x_equipo_x_partido jxe
        inner join (
            select idJugador, max(puntos) as puntos
            from jugadores_x_equipo_x_partido
            group by idJugador
        ) b on jxe.idJugador = b.idJugador and jxe.puntos = b.puntos
        group by jxe.idJugador;

    declare continue handler for not found set vFin = 1;
    open leerJugadores;

    leer: loop
        fetch leerJugadores into vIdJugador, vIdPartido, vPuntos;

        if vFin = 1 then
            leave leer;
        end if;

        insert into recordsJugadores (idJugador, idPartido, record)
        values (vIdJugador, vIdPartido, vPuntos)
        on duplicate key update idPartido = values(idPartido), record = values(record);
    end loop leer;

    close leerJugadores;
end;

/*Notar uso de "on duplicate key", en caso de que ya exista un record para ese jugador*/

call agregarRecordJugadores();

select * from recordsJugadores;

/*6 - Dado un mes y año pasado por parámetro, generar una tabla llamada
estadisticas_<mes>_<año>, donde se guarden los siguientes campos :

apellido y nombre
equipo
cantidad_partidos
puntos
rebotes
asistencias

Para cada uno de los partidos y jugadores debe guardarse si esa información ya fue
tomada en cuenta para el calculo y en caso de que no actualizar los valores de la tabla.*/

/*Query obsoleta que devuelve los valores en una sola tabla, sirve para verificar
que los valores del stored procedure sean correctos

select jxe.idJugador, concat(j.apellido,' ', j.nombre), count(jxe.idJugador), ifnull(sum(puntos),0), ifnull(sum(rebotes),0), ifnull(sum(asistencias),0)
from jugadores_x_equipo_x_partido jxe
right join jugadores j
on jxe.idJugador = j.idJugador
group by j.idJugador

*/

/*Append: note te use of concat and stmt for creating tables with variable names*/

/*Jugadores sin equipo (que fueron puestos solo para testear) no son llamados, si se quisiera que se llamen
cambiar "inner join equipos e" a "left join equipos e"*/

alter table jugadores_x_equipo_x_partido
add column estadistica tinyint(1) default 0;

drop procedure estadisticasMesAno;
create procedure estadisticasMesAno(in vMes int, in vAno int)
begin
    declare vIdJugador int;
    declare vIdPartido int;
    declare vNombre varchar(255);
    declare vEquipo varchar(255);
    declare vPuntos int;
    declare vRebotes int;
    declare vAsistencias int;
    declare vFin int default 0;
    
    declare leerJugadores cursor for
        select j.idJugador, jxe.idPartido, concat(j.apellido,' ', j.nombre), e.equipo, ifnull(jxe.puntos,0), ifnull(jxe.rebotes,0), ifnull(jxe.asistencias,0)
        from jugadores_x_equipo_x_partido jxe
        right join jugadores j
        on jxe.idJugador = j.idJugador
        inner join equipos e
        on j.idEquipo = e.idEquipo
        order by j.idJugador;

    declare continue handler for not found set vFin = 1;

    set @sql_text = concat('create table estadisticas_',vMes,'_',vAno,'
    (
        idEstadisticas int auto_increment,
        idJugador int not null unique,
        apellidoNombre varchar(255) not null,
        equipo varchar(255) not null,
        cantidadPartidos int,
        puntos int,
        rebotes int,
        asistencias int,
        primary key (idEstadisticas),
        foreign key (idJugador) references jugadores (idJugador)
    )');

    PREPARE stmt from @sql_text;
    EXECUTE stmt; 
    DEALLOCATE PREPARE stmt;

    
    open leerJugadores;

    leer: loop
        fetch leerJugadores into vIdJugador, vIdPartido, vNombre, vEquipo, vPuntos, vRebotes, vAsistencias;

        if (vFin = 1) then
            leave leer;
        end if;

        set @sql_text = concat('
            insert into estadisticas_',vMes,'_',vAno,' (idJugador, apellidoNombre, equipo, cantidadPartidos, puntos, rebotes, asistencias) 
            values(',vIdJugador,',"',vNombre,'","',vEquipo,'",1,',vPuntos,',',vRebotes,',',vAsistencias,') 
            on duplicate key update cantidadPartidos = cantidadPartidos + 1, puntos = puntos + values(puntos), 
                rebotes = rebotes + values(rebotes), asistencias = asistencias + values(asistencias)
            ');
        
        PREPARE stmt from @sql_text;
        EXECUTE stmt; 
        DEALLOCATE PREPARE stmt;

        update jugadores_x_equipo_x_partido
        set estadistica = 1
        where idJugador = vIdJugador
        and idPartido = vIdPartido;

    end loop leer;

    close leerJugadores;
end;

call estadisticasMesAno(04,2019);

select * from estadisticas_4_2019;

select * from jugadores_x_equipo_x_partido;

/*7 - Agregar al ejercicio 6 un campo que indique la cantidad de triple dobles que hizo cada
jugador.*/

-- se crean variables count = 0 y vTripleDouble = 0
-- luego del fetch dentro del loop

if (vPuntos > 9) then
    count = count + 1;
end if;
if (vRebotes > 9) then
    count = count + 1;
end if;

-- lo mismo con los 5 tipos de valores (que encima hay que agregar 2 que no fueron tomados en cuenta en el anterior)
-- si count es 3 o mayor, se suma un punto a los triple-double

if(count >= 3) then
    vTripleDouble = 1;
end if;

-- y se suma en el insert y update

