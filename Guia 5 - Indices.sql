/* 1) Crear índices UNIQUE para que no se repita el mismo partido , no se repita un
nombre de equipo y no se pueda registrar un nombre y apellido de un jugador en el
mismo equipo. */

create unique index idx_partido_equipos
on partidos (idEquipoLocal, idEquipoVisitante);
#using btree #optional

/*2) Escribir una consulta que nos permita obtener los nombres de los equipos ordenados
por orden alfabetico descendente y realizar las estructuras de índices necesarias para
optimizar el ordenado*/

describe select *
from equipos
order by equipo;

create index idx_equipos_nombre
on equipos (equipo);

/*3) Listar nombre y apellido jugadores de los jugadores cuyo apellido comience con una
determinada letra, sin la necesidad de realizar un Full Scan.*/

describe select apellido, nombre
from jugadores
where apellido like 'a%';

create index idx_jugadores_apellido_nombre
on jugadores (apellido,nombre);

/*4) Realizar las estructuras necesarias para poder buscar jugadores optimamente por
Nombre y Apellido de manera exacta, es decir Nombre = “pepe” apellido = “juarez”*/

describe select *
from jugadores
where apellido = "Armani"
and nombre = "Franco";

create index idx_jugadores_apellido_nombre_hash
on jugadores (apellido,nombre)
using hash;