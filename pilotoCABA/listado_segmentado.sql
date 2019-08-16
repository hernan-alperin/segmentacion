SELECT id, depto, idbarrio, frac, radio, mza, lado, cod_calle, nombre_calle, numero, h4, cuerpo, piso, apt, habitacion, segmento_id seg
	FROM listados.caba
    JOIN segmentaciones.equilibrado s
    ON s.listado_id=id;
