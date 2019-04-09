-- 1 --
USE torneo

DELIMITER $$
create trigger TIB_jugadores_no_cargar BEFORE INSERT ON jugadores FOR EACH ROW 
BEGIN

	  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pueden cargar nuevos jugadores';

END$$

DROP TRIGGER TIB_jugadores_no_cargar ;

-- 2 --

DELIMITER $$

CREATE TRIGGER TIB_jugadores_no_repetir BEFORE INSERT ON jugadores FOR EACH ROW
begin
	
    DECLARE var_count int;
    
    select 
		count(*) into var_count 
	from 
		jugadores 
	where 
		nombre = new.nombre and
        apellido = new.apellido and
        id_equipo = new.id_equipo;
	
    if (var_count>0) then
		signal sqlstate '49445' SET MESSAGE_TEXT = 'No puede haber un jugador con el mismo nombre y apellido en el mismo equipo';
    end if;
        

end$$


select * from jugadores

-- 3 -- 

ALTER TABLE jugadores add column fecha_nacimiento datetime;
ALTER TABLE jugadores add column edad int;
DELIMITER $$
DROP TRIGGER IF EXISTS tib_jugadores_fecha_nacimeinto;
CREATE trigger tib_jugadores_fecha_nacimeinto BEFORE INSERT  ON jugadores FOR EACH ROW 
begin
		declare var_edad int;
        SET new.edad = YEAR(now()) - YEAR(new.fecha_nacimiento);
end$$

DELIMITER $$
DROP TRIGGER IF EXISTS tub_jugadores_fecha_nacimeinto;
CREATE trigger tub_jugadores_fecha_nacimeinto BEFORE UPDATE  ON jugadores FOR EACH ROW 
begin
		declare var_edad int;
        SET new.edad = YEAR(now()) - YEAR(new.fecha_nacimiento);
end$$

INSERT INTO jugadores(nombre,apellido,fecha_nacimiento) values ('Martin','Jaite','1980-01-05')

-- 4 --

use torneos;
select * from equipos
ALTER TABLE equipos add column cantidad_jugadores int default 0 ;
drop trigger tia_jugadores_cantidad_jugadores;
DELIMITER $$
create trigger tia_jugadores_cantidad_jugadores after insert on jugadores 
for each row
begin	
    update equipos 
    set cantidad_jugadores = (select count(*) from jugadores where id_equipo = new.id_equipo)
    where id_equipo = new.id_equipo;
end$$

DELIMITER $$
create trigger tda_jugadores_cantidad_jugadores after delete on jugadores 
for each row
begin	
    update equipos 
    set cantidad_jugadores = (select count(*) from jugadores where id_equipo = old.id_equipo)
    where id_equipo = old.id_equipo;
end$$


DELIMITER $$
create trigger tua_jugadores_cantidad_jugadores after update on jugadores 
for each row
begin	

	update equipos 
    set cantidad_jugadores = (select count(*) from jugadores where id_equipo = new.id_equipo)
    where id_equipo = new.id_equipo;
    
    update equipos 
    set cantidad_jugadores = (select count(*) from jugadores where id_equipo = old.id_equipo)
    where id_equipo = old.id_equipo;
end$$


