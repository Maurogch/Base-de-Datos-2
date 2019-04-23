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

/*4 - Ingresar dos equipos con sus jugadores e ingresar un partido con dichos equipos ingresados, todo 
en la misma transacción.*/

start transaction;

insert into equipos (equipo)
values ("Equipo trans1");

set @idEquipo = last_insert_id();

insert into jugadores (insert into jugadores (idEquipo, nombre, apellido, fechaNacimiento)
values (@idEquipo, "Mega", "Jugador", "1987-05-20")

insert into equipos (equipo)
values ("Equipo trans1");

set @idEquipo = last_insert_id();

insert into jugadores (insert into jugadores (idEquipo, nombre, apellido, fechaNacimiento)
values (@idEquipo, "Hyper Mega", "Jugador", "1987-05-21");

commit;

/*5 - Ejecutar la transacción del punto 1 con datos erróneos y verificar si ingreso los datos.*/

/*Rollback probado, usar workbench*/

/*6 - Ejecutar la transacción del punto 2 con datos erróneos y mostrar por pantalla un mensaje que 
indique si el error fue provocado en la inserción del equipo o del jugador.*/

#???

/*7 - Ingresar un quipo, modificarle el nombre y dejarlo en el estado original sin utilizar la sentencia 
Rollback de la manera adecuada.*/

/*Sin usar rollback, o utilizandolo mal?

/*8 - Habilitar el modo de transacciones implícitas, ejecutar el siguiente código
insert into equipo (nombre_equipo)
values ('Atenas de cordoba');
cerrar el SQL y verificar que sucede.*/

/*Autocommit on? debería comitear luego del insert, cierre o no el programa*/

