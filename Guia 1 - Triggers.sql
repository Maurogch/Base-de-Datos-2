/*1- Generar un trigger que evite la carga de nuevos jugadores.
Si nombre y apellido ya existen*/

CREATE TRIGGER tib_cargaJugador BEFORE INSERT 
ON jugadores 
FOR EACH ROW
BEGIN
    DECLARE vIdJugador INT DEFAULT 0;

    SELECT idJugador INTO vIdJugador
    FROM jugadores
    WHERE nombre = new.nombre
    AND apellido = new.apellido;

    IF (vIdJugador <> 0) THEN
        SIGNAL SQLSTATE '11111' 
            SET MESSAGE_TEXT = 'Jugador ya existente',
                MYSQL_ERRNO = 10000;
    END IF;
END;

insert into jugadores (idEquipo,nombre, apellido)
values (1,'Franco','Armani')

/*2- Generar un trigger que evite la carga de jugadores con el mismo nombre y apellido en
el mismo equipo.*/

CREATE TRIGGER tib_cargaJugador2 BEFORE INSERT 
ON jugadores 
FOR EACH ROW
BEGIN
    DECLARE vIdJugador INT DEFAULT 0;

    SELECT idJugador INTO vIdJugador
    FROM jugadores
    WHERE nombre = new.nombre
    AND apellido = new.apellido
    AND idEquipo = new.idEquipo;

    IF (vIdJugador <> 0) THEN
        SIGNAL SQLSTATE '11111' 
            SET MESSAGE_TEXT = 'Jugador ya existente',
                MYSQL_ERRNO = 10000;
    END IF;
END;

/*3- Generar un trigger que no permita ingresar los datos de un jugador a la tabla
jugadores_x_equipo_x_partido que no haya jugado el partido*/

DROP TRIGGER tib_cargaJugadorPartido;
CREATE TRIGGER tib_cargaJugadorPartido BEFORE INSERT 
ON jugadores_x_equipo_x_partido
FOR EACH ROW
BEGIN
    DECLARE vIdEquipoLocal int;
    DECLARE vIdEquipoVisitante int;
    DECLARE vIdEquipoJugador int;

    SELECT idEquipoLocal, idEquipoVisitante INTO vIdEquipoLocal, vIdEquipoVisitante
    FROM partidos
    WHERE idPartido = new.idPartido;

    SELECT idEquipo into vIdEquipoJugador
    FROM jugadores
    WHERE idJugador = new.idJugador;

    IF (vIdEquipoLocal <> vIdEquipoJugador AND vIdEquipoVisitante <> vIdEquipoJugador) THEN
        SIGNAL SQLSTATE '11113' 
            SET MESSAGE_TEXT = 'Jugador no pertenece a un equipo participante en el partido especificado',
                MYSQL_ERRNO = 10002;
    END IF;
END;

select * from jugadores

insert into jugadores_x_equipo_x_partido (idJugador,idPartido,puntos,rebotes,asistencias,minutos,faltas)
values (7,1,5,5,5,5,5)

/*4 - Agregar el campo cantidadJugadores a la tabla equipos y calcularlo mediante los
triggers necesarios para ello.*/

alter table equipos
add column cantidadJugadores int default 0;

create trigger tia_cargaJugadorCantidadEquipo after insert -- For insert
on jugadores
for each row
begin
    update equipos
    set cantidadJugadores = (select count(idJugador) -- You could also get the current value and add 1
                            from jugadores
                            where idEquipo = new.idEquipo)
    where idEquipo = new.idEquipo;
end;

create trigger tda_cargaJugadorCantidadEquipo after delete -- For delete (same as before, except using old)
on jugadores
for each row
begin
    update equipos
    set cantidadJugadores = (select count(idJugador)
                            from jugadores
                            where idEquipo = old.idEquipo)
    where idEquipo = old.idEquipo;
end;

create trigger tua_cargaJugadorCantidadEquipo after update -- For update
on jugadores
for each row
begin
    if (old.idEquipo <> new.idEquipo) then
        update equipos
        set cantidadJugadores = (select count(idJugador)
                                from jugadores
                                where idEquipo = old.idEquipo)
        where idEquipo = old.idEquipo;

        update equipos
        set cantidadJugadores = (select count(idJugador)
                                from jugadores
                                where idEquipo = new.idEquipo)
        where idEquipo = new.idEquipo;
    end if;
end;

select * from equipos;

insert into jugadores (idEquipo,nombre,apellido)
values (1,'John','Salchichon');

/*5 - Agregar los campos fechaNacimiento y edad a la tabla de jugadores y cuando se
inserte o modifique la fecha de nacimiento recalcule la edad actual del jugador*/

alter table jugadores
add column fechaNacimiento date; --can't use a default here

    /* using DATETIME instead of DATE, you can use DEFAULT CURRENT_TIMESTAMP, to set 
    the default time to now()*/

alter table jugadores
add column edad int default 0;

select * from jugadores;

    --Testing timestampdiff, it returns the difference of two dates
    --curdate returns day month year without time (instead of now())
select nombre, fechaNacimiento, curdate(), timestampdiff(year,fechaNacimiento,curdate()) as edaD
from jugadores
where idJugador = 1;

create trigger tib_calcularEdadJugador before insert
on jugadores
for each row
begin
    set new.edad = TIMESTAMPDIFF(YEAR, new.fechaNacimiento, CURDATE());
end;

create trigger tub_calcularEdadJugador before update
on jugadores
for each row
begin
    if (old.fechaNacimiento is null) and (new.fechaNacimiento is null) then
        /*SIGNAL SQLSTATE '11114'  --For now do nothing as this singal generates problems in the future
            SET MESSAGE_TEXT = 'Debe especificar una fecha de nacimiento',
                MYSQL_ERRNO = 10004;*/
    elseif (new.fechaNacimiento is not null) then
        set new.edad = TIMESTAMPDIFF(YEAR, new.fechaNacimiento, CURDATE());
    else 
        set new.edad = TIMESTAMPDIFF(YEAR, old.fechaNacimiento, CURDATE());
    end if;
end;

insert into jugadores (idEquipo,nombre,apellido,fechaNacimiento)
values (1,'Pablo','Juanez','1980-08-21');

update jugadores
set fechaNacimiento = '1987-05-20'
where idJugador = 1;

/*6 - Agregar los campos puntosEquipoLocal y puntosEquipoVisitante a la tabla de
partidos y realizar los triggers necesarios para mantener automaticamente el resultado
del partido en base a lo cargado en la tabala jugadores_x_equipo_x_partido.*/

alter table partidos
add column puntosEquipoLocal int default 0;

alter table partidos
add column puntosEquipoVisitante int default 0;

drop trigger tia_refrescarPuntosPartido;
create trigger tia_refrescarPuntosPartido after insert
on jugadores_x_equipo_x_partido
for each row
begin
    declare vIdEquipoLocal int default 0;
    declare vIdEquipoVisitante int default 0;
    declare vIdEquipoJugador int default 0;

    select idEquipoLocal, idEquipoVisitante into vIdEquipoLocal, vIdEquipoVisitante
    from partidos
    where idPartido = new.idPartido;

    select idEquipo into vIdEquipoJugador
    from jugadores
    where idJugador = new.idJugador;

    if (vIdEquipoJugador = vIdEquipoLocal) then
        update partidos
        set puntosEquipoLocal = puntosEquipoLocal + new.puntos
        where idPartido = vIdEquipoLocal;
    elseif (vIdEquipoVisitante = vIdEquipoJugador) then
        update partidos
        set puntosEquipoLocal = puntosEquipoLocal + new.puntos
        where idPartido = vIdEquipoVisitante;
    else
        SIGNAL SQLSTATE '11115' 
            SET MESSAGE_TEXT = 'Jugador no pertenece a un equipo participante en el partido especificado',
                MYSQL_ERRNO = 10005;
    end if;
end;

create trigger tda_refrescarPuntosPartido after delete
on jugadores_x_equipo_x_partido
for each row
begin
    declare vIdEquipoLocal int default 0;
    declare vIdEquipoVisitante int default 0;
    declare vIdEquipoJugador int default 0;

    select idEquipoLocal, idEquipoVisitante into vIdEquipoLocal, vIdEquipoVisitante
    from partidos
    where idPartido = old.idPartido;

    select idEquipo into vIdEquipoJugador
    from jugadores
    where idJugador = old.idJugador;

    if (vIdEquipoJugador = vIdEquipoLocal) then
        update partidos
        set puntosEquipoLocal = puntosEquipoLocal - old.puntos
        where idPartido = vIdEquipoLocal;
    end if;
    
    if (vIdEquipoVisitante = vIdEquipoJugador) then
        update partidos
        set puntosEquipoLocal = puntosEquipoLocal - old.puntos
        where idPartido = vIdEquipoVisitante;
    end if;
end;

drop trigger tua_refrescarPuntosPartido;
create trigger tua_refrescarPuntosPartido after update
on jugadores_x_equipo_x_partido
for each row
begin
    declare vIdEquipoLocal int default 0;
    declare vIdEquipoVisitante int default 0;
    declare vIdEquipoJugador int default 0;

    select idEquipoLocal, idEquipoVisitante into vIdEquipoLocal, vIdEquipoVisitante
    from partidos
    where idPartido = new.idPartido;

    select idEquipo into vIdEquipoJugador
    from jugadores
    where idJugador = new.idJugador;

    if (vIdEquipoJugador = vIdEquipoLocal) then
        update partidos
        set puntosEquipoLocal = puntosEquipoLocal - old.puntos --substract old point done by the player
        where idPartido = vIdEquipoLocal;

        update partidos
        set puntosEquipoLocal = puntosEquipoLocal + new.puntos --add new points done, to maintain a correct score
        where idPartido = vIdEquipoLocal;
    elseif (vIdEquipoVisitante = vIdEquipoJugador) then
        update partidos
        set puntosEquipoLocal = puntosEquipoLocal - old.puntos
        where idPartido = vIdEquipoVisitante;
        
        update partidos
        set puntosEquipoLocal = puntosEquipoLocal + new.puntos
        where idPartido = vIdEquipoVisitante;
    else
        SIGNAL SQLSTATE '11115' 
            SET MESSAGE_TEXT = 'Jugador no pertenece a un equipo participante en el partido especificado',
                MYSQL_ERRNO = 10005;
    end if;
end;

select * from partidos;

insert into jugadores_x_equipo_x_partido (idJugador,idPartido,puntos)
values (9,1,3);

/*7 - Generar un stored procedure que calcule el promedio de puntos realizado por cada
jugador y lo guarde en un campo en la tabla jugador*/

alter table jugadores
add column promedio float default 0;

-- Testing a table that returns avg of every player, didn't know how to use this
select j.idJugador, j.nombre, j.apellido, ifnull((select avg(puntos)
    from jugadores_x_equipo_x_partido jx_sub
    where j.idJugador = jx_sub.idJugador
    ),0) as promedio
from jugadores j
group by j.nombre, j.apellido
order by j.idJugador;

    /*---------Doing a query for every row in jugadores-----------*/
drop procedure calcularPromedioJugadores;

create procedure calcularPromedioJugadores()
begin
    declare vCantJugadores int default 0;
    declare vContador int default 0;
    declare vPromedio float default 0;

    select count(*) into vCantJugadores
    from jugadores;

    WHILE vCantJugadores > vContador DO
        set vContador = vContador + 1;

        select avg(puntos) into vPromedio
        from jugadores_x_equipo_x_partido
        where idJugador = vContador;

        if (vPromedio is not null) then
            update jugadores
            set promedio = vPromedio
            where idJugador = vContador;
        end if;
    END WHILE;
end;

call calcularPromedioJugadores();

select * from jugadores;

    /*------Correct way to do it-------*/
create procedure calcularPromedioJugadores2()
begin
    update jugadores ju 
    set promedio = (select avg(puntos)
                    from jugadores_x_equipo_x_partido jxp  
                    where jxp.idJugador = ju.idJugador);   #Seems like if you send rows (more than one result) from a  
end;                                                       #subquerry while using a condition from the table it is  
                                                           #modifying it will do it for each row

/*8 - Generar una tabla con el nombre recordsJugadores, donde se guarde la máxima
cantidad de puntos hecha por  un jugador,  en que partido , que fecha y que edad
poseia el jugador al momento del record.*/


/*9 - Mantener una tabla estadisticasJugadores donde se generen los siguientes campos:
idJugador
puntosTotales*/


/*10 - Agregar los campos rebotesTotales, asistenciasTotales a la tabla 
estadisticasJugadores ​y mantenerlos mediante triggers.*/


/*11 - Agregar el campo cantidadPartidos y los promedios de cada uno de los items.*/


/*12 - Agregar a la tabla estadisticasJugadores, el mes en el cual se están calculando los
promedios. Por cada jugador debe haber un registro por mes que indique los promedios
de ese mes.*/