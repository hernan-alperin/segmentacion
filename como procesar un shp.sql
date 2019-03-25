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
alter table lineas add column geom_ejes geometry;
update lineas
set geom_ejes = ST_LineMerge(geom)
;







