ALTER  TABLE equipos ADD COLUMN fundacion date not null;
ALTER  TABLE equipos ADD COLUMN antiguedad int(10);

DROP TRIGGER TIB_EQUIPOS_CALC_ANTIG;
DELIMITER $$
CREATE TRIGGER TIB_EQUIPOS_CALC_ANTIG BEFORE INSERT ON equipos FOR EACH ROW
BEGIN
	IF (NEW.fundacion > now()) then
		signal sqlstate '10001' 
		SET MESSAGE_TEXT = 'La fecha no puede ser mayor al dia de hoy', 
		MYSQL_ERRNO = 2.2;
	END IF;
    SET NEW.antiguedad = DATEDIFF(NOW(),NEW.fundacion) / 365;
END
$$
DELIMITER ; 


DELIMITER $$
CREATE TRIGGER TUB_JUGADORES_X_EQ_X_PARTIDO_RESTRICT BEFORE UPDATE ON jugadores_x_partido
BEGIN
		if  (old.id_jugador <> new.id_jugador) OR (old.id_partido <> new.id_partido) then
				signal sqlstate '10001' SET MESSAGE_TEXT = 'No se puede cambiar el partido o el jugador, por favor borrad y reinsertad', MYSQL_ERRNO = 2.2;
		end if;
END;
$$