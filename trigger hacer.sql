-- Desafio 1
-- Evitar que cambien el id de jugador o partido

-- Desafio 2
-- Redicir el codigo repetido

-- Hacer guia de triggers

CREATE TRIGGER tub_jugadores_x_equipo_x_partido_restric BEFORE 
UPDATE ON jugadores_x_equipo_x_partido FOR EACH ROW
BEGIN
    if (old.idJugador <> new.idJugador) OR (old.idEquipo <> new.idEquipo)
        signal bla bla
    end if;
END;
