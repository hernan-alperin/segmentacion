Especificaciones 

Listado a segmentar

tabla listado
cada registro debe contener (al menos) los siguientes campos
	id
	depto
	frac
	radio
	mnza
	lado
	cod_calle
	numero
	cuerpo (distintas torres, monoblocks con el mismo direccion)
	piso
	apt (timbre o departamento dentro del piso)

Topología del radio censal
1. todos los campos de las siguientes tablas son de tipo integer
2. el par mza, lado identifica a un lado 

tabla	adyacencias_manzanas
campos
	mza, -- esta
	mnza_ady -- la otra

tabla adyacencia lados
	mza, lado, -- este lado
	lado_d, -- lado en la misma mza resultado de doblar a la derecha
	mza_v, lado_v, -- lado de darse la vuelta por el lado de enfrente una vez que se llega a la esquina
	mza_c, lado_c -- lado resultado de seguir cruzando la calle por la manza de enfrente a mza por el lado_v

tabla lados_nodos
	nodo_i, mza, lado, nodo_f
	(*) dirigido siguiendo las agujas del reloj = hombro derecho, dentro de mza
