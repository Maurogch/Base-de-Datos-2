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

/*5) Generar las estructuras necesarias para buscar optimamente partidos jugados entre
dos fechas .*/

describe select *
from partidos
where fecha > '2018-02-01'
and fecha < '2018-08-01';

create index idx_partidos
on partidos (fecha);

/*6) Generar los índices necesarios para buscar equipos que comiencen con determinada
letra.*/

describe select *
from equipos
where equipo like 'b%';

create index idx_equipos_nombre
on equipos (equipo);

/*7) Generar los índices necesarios siendo que se va a buscar los nombres de los
jugadores desde la web (ingresando en una sola caja de texto) y se debe buscar su
apellido.*/
#ya que los nombres son solo una sola palabra es más eficiente el index hash
#pero pareciera que se quiere que se use el indice de fulltext, que es util cuando
#hay columnas con varias palabras (campos de texto), indexa cada palabra por separado

describe select nombre, apellido
from jugadores
where nombre = 'jorge' #usa fulltext
where nombre like '%jorge%' #usa hash (ya que el indice de hash es compuesto por apellido y nombre)

create fulltext index idx_nombres_jugadores_fulltext 
on jugadores (nombre);
#efectivamente sigue usando el index hash

/*8)
Investigar como realizar el 7 pero buscando indistintamente por nombre y apelido.*/

#ahora si un fulltext??
#ya está hecho un index hash con apellido-nombre