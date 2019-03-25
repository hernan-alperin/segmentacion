Hacer a mano:

- createdb comuna11
- vi dump.sql para hacer un drop table antes del begin para evitar error
- psql comuna11
- create extension postgis
- psql -f dump.sql comuna11

- psql comuna11

select ST_NumGeometries(geom), count(*)
from lineas
group by ST_NumGeometries(geom)
;

/* chequear consistencia
 st_numgeometries | count
------------------+-------
                1 |  2840
*/




