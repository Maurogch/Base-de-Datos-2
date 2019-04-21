DELIMITER $$

CREATE PROCEDURE armar_lista_correo()
BEGIN
	# Declaraciones.
	DECLARE correo varchar(50);
	DECLARE lista varchar(1000) DEFAULT '';
	DECLARE hecho INT DEFAULT 0;
	# El cursor se declara DESPUÉS de las variables
	# y ANTES del handler.
	DECLARE leer_correo CURSOR FOR SELECT email FROM personas;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET hecho = TRUE;

	# Siempre hay que abrir el cursos antes de usarlo.
	OPEN leer_correo;

	# Bucle para leer el cursor, puede usarse otro
	# que no sea LOOP, a criterio de ustedes.
	leer: LOOP
		# Leo info del cursor
		FETCH leer_correo INTO correo;
		# Verifico que haya info, sino salgo.
		IF hecho THEN
			LEAVE leer;
		END IF;
		# Si hay info, la utilizo.
		SET lista = concat(correo, ";", lista);
	END LOOP;

	# Cierro el cursor. No es obligatorio ya que
	# se cierra solo, pero si recomendable.
	CLOSE leer_correo;

	# Lo ideal sería que el procedimiento devuelva un
	# valor, no hacer esto. Queda como tarea...
	SELECT lista;
END $$