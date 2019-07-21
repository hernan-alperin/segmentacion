/*
-- Hacer a mano:

-- createdb comuna11
-- vi dump.sql para hacer un drop table antes del begin para evitar error
-- psql comuna11
-- create extension postgis
-- psql -f dump.sql comuna11
----- xej alpe@notebook:~/indec/COMUNA11$ psql -f LadoComuna11.sql comuna11
*/

/*
-- normalización de la info del shape de lineas
comuna11=# \d e0211lin
                                        Table "public.e0211lin"
   Column   |           Type            | Collation | Nullable |                Default                
------------+---------------------------+-----------+----------+---------------------------------------
 gid        | integer                   |           | not null | nextval('e0211lin_gid_seq'::regclass)
 fnode_     | double precision          |           |          | 
 tnode_     | double precision          |           |          | 
 lpoly_     | double precision          |           |          | 
 rpoly_     | double precision          |           |          | 
 length     | double precision          |           |          | 
 ecapi_     | double precision          |           |          | 
 ecapi_id   | double precision          |           |          | 
 codigo10   | integer                   |           |          | 
 nomencla   | character varying(13)     |           |          | 
 codigo20   | integer                   |           |          | 
 ancho      | smallint                  |           |          | 
 anchomed   | double precision          |           |          | 
 tipo       | character varying(6)      |           |          | 
 nombre     | character varying(40)     |           |          | 
 ladoi      | smallint                  |           |          | 
 ladod      | smallint                  |           |          | 
 desdei     | integer                   |           |          | 
 desded     | integer                   |           |          | 
 hastai     | integer                   |           |          | 
 hastad     | integer                   |           |          | 
 mzai       | character varying(17)     |           |          | 
 mzad       | character varying(17)     |           |          | 
 codloc20   | character varying(8)      |           |          | 
 nomencla10 | character varying(13)     |           |          | 
 nomenclai  | character varying(13)     |           |          | 
 nomenclad  | character varying(13)     |           |          | 
 codigo     | integer                   |           |          | 
 codigoc    | character varying(6)      |           |          | 
 mci        | character varying(21)     |           |          | 
 mcd        | character varying(21)     |           |          | 
 geom       | geometry(MultiLineString) |           |          | 
Indexes:
    "e0211lin_pkey" PRIMARY KEY, btree (gid)

-- 1. distribución de campos

-- campo mzad mzai: 
-- PPDDDLLLFFRRMMM char
-- campo ladod ladoi int
*/

create table lados_normal as
select substr(mzad,1,2)::integer as provd, substr(mzad,3,3)::integer as deptod,
	substr(mzad,5,3)::integer as locd, 
	substr(mzad,9,2)::integer as fracd, substr(mzad,11,2);;integer as radiod,
	ladod::integer as ladod,
	substr(mzai,1,2)::integer as provi, substr(mzai,3,3)::integer as deptoi,
  substr(mzai,5,3)::integer as loci,
  substr(mzai,9,2)::integer as fraci, substr(mzai,11,2);;integer as radioi,
  ladod::integer as ladoi,
	fnode_ as nodo_i, tnode_ as nodo_j, geom, anchomed
from lineas
-- correr consistencias para lo que sigue no pase
where mzad != '' and mzad is not Null and ladod !=0
and mzai != '' and mzai is not Null and ladoi !=0
;

-- filtrar dentro del mismo radio
delete from lados_normal
where
provd != provi or
deptod != deptoi or
fracd != fraci or
radiod != radioi
;
-- provdi y deptodi son redundantes ya que en este caso usamos sólo la comuna 11
alter table lados_normal rename column provd to prov
alter table lados_normal rename column deptod to depto
alter table lados_normal rename column fracd to frac
alter table lados_normal rename column radiod to radio
alter table lados_normal drop comlumn provi
alter table lados_normal drop comlumn deptoi
alter table lados_normal drop comlumn fraci
alter table lados_normal drop comlumn radioi


-- extender ejes de calle en lados
-- ladod se recorre en sentido en el que está
-- ladoi en sentido inverso
-- hombro derecho o agujas del reloj
create table lado_de_arcos as
with lados_de_manzana as (
    select prov, depto, frac, radio, 
	ladoi as lado, mzai as mza, avg(anchomed) as anchomed,
        st_linemerge(st_union(st_reverse(geom))) as geom_lado
    from lados_normal
    group by prov. depto, frac, radio, mzai, ladoi
    union
    select lado_d, mzad as mza, avg(anchomed) as anchomed,
        St_LineMerge(St_Union(geom)) as geom_lado
    from lados_normal
		group by prov, depto, frac, radio, mza, lado
		),
    lados_codigos as (
    select prov, depto, frac, radio, lado, mza,
        St_StartPoint(geom_lado) as start
    from lados_de_manzana
    --where substr(mza,13,3)::integer not between 200 and 299
    group by prov, depto, frac, radio, lado, mza,
    --having    st_geometrytype(st_linemerge(st_union(geom))) = 'ST_LineString'
		), lado_manzana AS (
select codigo20,lado_id, mza, lado, geom, st_azimuth(st_startpoint(geom),st_endpoint(geom)),cover
from lados_codigos as lado_manzana
ORDER BY mza,lado
)
/*
SELECT string_agg(distinct codigo20::text,',') nomencla,mza,lado,count(*) as cant_nomenclas--,count(*)=max(lado) as ok
,cover
FROM lado_manzana
GROUP BY mza,lado,cover
order by count(*) desc
;
*/
-- Cantidad de Lados de Manzana
SELECT lado_id,mza, lado::text,st_union(geom) geom,codigo20
FROM lado_manzana
GROUP BY lado_id,mza,lado,codigo20

