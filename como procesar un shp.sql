/*
Hacer a mano:

@prompt:

createdb comuna11
vi dump.sql para hacer un drop table antes del begin para evitar error
psql comuna11
create extension postgis
psql -f dump.sql comuna11
 psql comuna11
*/

-- chequear consistencias, casos

comuna11=#  select ST_NumGeometries(geom), count(*)
from lineas
group by ST_NumGeometries(geom)
;
/*
 st_numgeometries | count
------------------+-------
                1 |  2840
*/

-- qué tipo
comuna11=# select distinct ST_GeomeTrytype(geom) from lineas;
/*
 st_geometrytype
--------------------
 ST_MultiLineString
(1 fila)
*/

-- pasar a linestring para calcular extremos
comuna11=# alter table lineas add column geom_ejes geometry;
update lineas
set geom_ejes = ST_LineMerge(geom)
;


drop table lados;
create table lados as
select fnode_ as vertice_i, tnode_ as vertice_j,
    ST_StartPoint(geom_eje) as geom_i, ST_EndPoint(geom_eje) as geom_j,
    geom_eje
from lineas
;


select mzad, ladod, mzai, ladoi from lineas;
      mzad       | ladod |      mzai       | ladoi
-----------------+-------+-----------------+-------
 020770100101003 |     3 | 020770100101002 |     1
 020840102201005 |     0 | 020770100101004 |     1
 020770100101002 |     2 | 020770100101007 |     4
 020770100101200 |     0 | 020770100101002 |     3


-- armando los lados para cada manzana

with lados_de_manzana as ( -- mza como PPDDDLLLFFRRMMM y lado integer
    select mzad as mza, ladod as lado, avg(anchomed) as anchomed,
        tipo, codigo, nombre as calle,
        min(desded) as desde, max(hastad) as hasta,
        ST_LineMerge(ST_Union(geom)) as geom_lado -- ST_Union por ser MultiLineString
    from lineas
    where mzad is not Null and mzad != '' and ladod != 0
    group by mzad, ladod, tipo, codigo, nombre
    union
    select mzai as mza, ladoi as lado, avg(anchomed) as anchomed,
        tipo, codigo, nombre as calle,
        max(hastai) as desde, min(desdei) as hasta,
        ST_LineMerge(ST_Union(ST_Reverse(geom))) as geom_lado
    from lineas
    where mzai is not Null and mzai != '' and ladod != 0
    group by mzai, ladoi, tipo, codigo, nombre
    )
select substr(mza,9,2)::integer as frac, substr(mza,11,2)::integer as radio,
    substr(mza,13,3)::integer as mza, lado, calle, desde, hasta
from lados_de_manzana
order by substr(mza,9,2)::integer, substr(mza,11,2)::integer, substr(mza,13,3)::integer, lado
;







