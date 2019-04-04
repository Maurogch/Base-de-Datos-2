

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
        INSERT INTO jugadores (idEquipo, nombre, apellido)
        VALUES (new.idEquipo, new.nombre, new.apellido);
    ELSE
        SIGNAL SQLSTATE '11111' 
            SET MESSAGE_TEXT = 'Jugador ya existente',
                MYSQL_ERRNO = 10000;
    END IF;
END;

select * from equipos
insert into jugadores (idEquipo,nombre, apellido)
