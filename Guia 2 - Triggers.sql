/*Generar un trigger que evite la carga de nuevos jugadores.
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

/*Generar un trigger que evite la carga de jugadores con el mismo nombre y apellido en
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

/*Generar un trigger que no permita ingresar los datos de un jugador a la tabla
jugadores_x_equipo_x_partido que no haya juado el partido*/
drop trigger tib_cargaJugadorPartido;
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

