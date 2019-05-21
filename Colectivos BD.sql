create database colectivos;
use colectivos;

create table choferes(
    idChofer int auto_increment,
    nombre varchar(50),
    primary key (idChofer)
);

create table rutas(
    idRuta int auto_increment,
    distancia float,
    primary key (idRuta)
);

create table viajes(
    idViaje int auto_increment,
    idRuta int,
    idChofer int,
    primary key (idViaje),
    foreign key (idRuta) references rutas (idRuta),
    foreign key (idChofer) references choferes (idChofer)
);

insert into choferes(nombre)
values ("chofer1"),("chofer2"),("chofer3");

insert into rutas (distancia)
values (20),(50),(70);

insert into viajes (idRuta,idChofer)
values (1,1),(1,2),(2,1);

select c.idChofer, sum(distancia)
from choferes c
left join viajes v
on c.idChofer = v.idChofer
left join rutas r
on r.idRuta = v.idRuta
group by c.idChofer