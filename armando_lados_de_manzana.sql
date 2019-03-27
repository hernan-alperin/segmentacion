-- título: doing_dvc_adyacencias.sql
-- descripción:
--
-- trabaja sobre el ejemplo de la comuna11
-- todo: generalizar a otros deptos
--
-- autor: -h
-- fecha creación: 2019-03-26 Mi

/*
la tabla lineas contiene los ejes del shape e0211lin enviado por mail por Manu
mar 19/3, 10:38
*/

-- armando los lados para cada manzana

create table lados_de_manzana
as with pedacitos_de_lado as (-- mza como PPDDDLLLFFRRMMMselect mzad as mza, ladod as lado, avg(anchomed) as anchomed,
    select mzad as mza, ladod as lado, avg(anchomed) as anchomed,
        tipo, codigo, nombre as calle,
        ST_Union(geom) as geom_pedacito -- ST_Union por ser MultiLineString
    from e0211lin
    where mzad is not Null and mzad != '' and ladod != 0
    and substr(mzad,1,8) = '02077010' -- en la comuna
    group by mzad, ladod, tipo, codigo, nombre
    union -- duplica los pedazos de lados a derecha e izquierda
    select mzai as mza, ladoi as lado, avg(anchomed) as anchomed,
        tipo, codigo, nombre as calle,
        ST_Union(ST_Reverse(geom)) as geom_pedacito -- invierte los de mzai
		-- para respetar sentido hombro derecho
    from e0211lin
    where mzai is not Null and mzai != '' and ladoi != 0
    and substr(mzai,1,8) = '02077010'
    group by mzai, ladoi, tipo, codigo, nombre
    order by mza, lado--, tipo, codigo, calle
    ),
	lados_orientados as (
	select mza, lado, anchomed, 
		tipo, codigo, calle,
		ST_LineMerge(ST_Union(geom_pedacito)) as lado_geom -- une por mza,lado
	from pedacitos_de_lado
	group by mza, lado, anchomed,
        tipo, codigo, calle
	)
select *, ST_StartPoint(lado_geom) as nodo_i, ST_EndPoint(lado_geom) as nodo_j
from lados_orientados
;

select *
from lados_de_manzana
order by mza, lado
limit 10
;

