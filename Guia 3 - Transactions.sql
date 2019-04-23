/*Transactions wont work with tables created with MyISAM engine, and it seems that Visual Studio Code is doing that*/
/*Convert tables from MyISAM (non transactiona) to inboDB, Then, copy the output and run as a new SQL query.

SET @DATABASE_NAME = 'put_database_name_here';

SELECT  CONCAT('ALTER TABLE `', table_name, '` ENGINE=InnoDB;') AS sql_statements
FROM    information_schema.tables AS tb
WHERE   table_schema = @DATABASE_NAME
AND     `ENGINE` = 'MyISAM'
AND     `TABLE_TYPE` = 'BASE TABLE'
ORDER BY table_name DESC;
*/

/*See table status
SHOW TABLE STATUS LIKE 'table_name';
*/

/*1 - Ejecutar una transacción que agregue un equipo con todos sus jugadores.*/
/*Explicit*/
start transaction;

insert into equipos (equipo)
values ("Chacarita");

set @idEquipo = last_insert_id();

insert into jugadores (idEquipo, nombre, apellido, fechaNacimiento)
values (@idEquipo, "Greg", "Alvarez", "1987-05-20"),
    (@idEquipo, "Devin", "Manning", "1985-10-02"),
    (@idEquipo, "Albert", "Thompson", "1990-04-12"),
    (@idEquipo, "Andrew", "Anderson", "1992-02-15");

commit;

/*2 - Ejecutar las estadísticas de un jugador (puntos, asistencias, rebotes, faltas).*/

select idJugador, avg(puntos), avg(asistencias), avg(rebotes), avg(faltas)
from jugadores_x_equipo_x_partido
group by idJugador

/*3 - Ingresar de forma temporal 3 partidos y mostrar cómo quedaría la grilla de partidos 
para esa fecha.*/

start transaction;

insert into partidos (idEquipoLocal,idEquipoVisitante, fecha)
values (1,2,now());

select * from partidos
where month(fecha) = 04;

