/**Guia 0**/

use futbol;

/**1**/
/*create procedure agreagarEquipo(inEquipo varchar(50))
begin
    insert into equipos(equipo)
    values (inEquipo);
end;

call agregarEquipo("Boca")*/

/**2**/ /*chequear si funciona*/
/*create procedure agregarJugador (pIdEquipo int, pNombre varchar(50), pApellido varchar(50), out pIdJugador int)
begin
    declare vIdEquipo int default 0;
    select idEquipo into vIdEquipo from equipos where idEquipo = pIdEquipo;
    IF (vIdEquipo<>0) then
        insert into jugadores (nombre, apellido, idEquipo)
        values (pNombre, pApellido, pIdEquipo);
        Set pIdJugador = last_insert_id();
    ELSE
        SIGNAL SQLSTATE = '11111' SET MESSAGE_TEXT = 'No existe el equipo', mysql_errno = '10000';
    END IF;
end;*/

/**3**/ /*chequear si funciona*/
/*usar IF EXIST(select idEquipo from equipos where idEquipo = pIdEquipo)*/


/**4**/
/*creamos tabla temporal con jugadoras*/

/*create temporary table jugadoresInsertar(
    nombre varchar(50),
    apellido varchar(50)
);

insert into jugadoresInsertar (nombre, apellido)
values ('nombreTest1', 'nombreTest1'),('nombreTest2', 'nombreTest2'),('nombreTest3', 'nombreTest3');
*/

/*
create procedure altaEquipo()
begin

end;
*/

/**6**/
CREATE PROCEDURE resultadoPartido(pEquipo1 varchar(50), pEquipo2 varchar(50))
BEGIN
    
END