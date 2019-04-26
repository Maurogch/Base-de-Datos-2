/*1) Realizar una vista que muestre todos los jugadores de un equipo*/
create view verJugadoresRiver as
select idJugador, nombre, apellido, fechaNacimiento, edad, promedio from jugadores
where idEquipo = 1;

select * from verJugadoresRiver;

/*2) Realizar una vista que muestre nombre un equipo con sus jugadores*/
#mostrar todos los equipos

/*3) Realizar una vista que muestre el jugador con más puntos realizados*/
create view verJugadorMaxPuntos as
select j.idJugador, j.nombre, j.apellido, j.fechaNacimiento, j.edad, j.promedio, max(puntos) as"Puntos"
from jugadores_x_equipo_x_partido jxe
inner join jugadores j 
on jxe.idJugador = j.idJugador
group by jxe.idJugador
order by max(puntos) desc
limit 1;

select * from verJugadorMaxPuntos;

/*4) Realizar una vista que muestre todos los partidos del año en curso dividido por mes*/
create view verPartidosEsteAño as
select * from partidos
where year(fecha) = year(now())
order by month(fecha);

select * from verPartidosEsteAño;

/*5) Al ingresar un jugador disparar una vista que muestre como quedo compuesto el equipo*/
#no puedo pasarle el equipo a la vista, ???
#no hacer
create trigger tia_cargaJugadorMostrarVista after insert
on jugadores
for each row
begin
    
end;