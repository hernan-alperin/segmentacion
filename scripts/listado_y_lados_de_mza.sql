TRUNCATE segmenta_caba_20 ;
INSERT into segmenta_caba_20 
with e00 as
(
SELECT min(id) gid, codigo, nomencla, codigo20, ancho, anchomed, tipo, nombre, ladoi, ladod, desdei, desded, 
    hastai, hastad, mzai, mzad, codloc20, nomencla10, nomenclai, nomenclad, codigoc,  'caba'::text cover,
    st_LineMerge(st_union(geom)) geom
	FROM carto.ecapilin_numerado
    GROUP BY codigo, nomencla, codigo20, ancho, anchomed, tipo, nombre, ladoi, ladod, desdei, desded, 
    hastai, hastad, mzai, mzad, codloc20, nomencla10, nomenclai, nomenclad, codigo, codigoc
),
lados_de_manzana as (
    select codigo,mzai||'-'||ladoi as lado_id, mzai as mza, ladoi as lado, avg(anchomed) as anchomed,
        st_linemerge(st_union(st_reverse(geom))) as geom,cover
    from e00
    where mzai is not Null and mzai != ''
    group by codigo,mzai, ladoi,cover
    union
    select codigo,mzad||'-'||ladod as lado_id, mzad as mza, ladod as lado, avg(anchomed) as anchomed,
        st_linemerge(st_union(geom)) as geom,cover
    from e00
    where mzai is not Null and mzad != ''
    group by codigo,mzad, ladod,cover
),
    lados_codigos as (
    select codigo, lado_id, mza, lado,
        st_linemerge(st_union(geom)) as geom,cover
    from lados_de_manzana
---------------------------------LIMITE DE EJEMPLO CABA ------------
    WHERE substring(mza,3,3)::integer in (8,11,14,15) 
--------------------------------------------------------------------    
    --where substr(mza,13,3)::integer not between 200 and 299
    group by codigo,lado_id, mza, lado,cover
), lado_manzana AS (
select codigo,lado_id, mza, lado, geom, st_azimuth(st_startpoint(geom),st_endpoint(geom)),cover
from lados_codigos as lado_manzana
ORDER BY mza,lado
), lados AS (
-- Cantidad de Lados de Manzana
SELECT 
	substring(mza,1,2) prov,
    substring(mza,3,3) depto,
    substring(mza,6,3) codloc,
    substring(mza,9,2) frac,
    substring(mza,11,2) radio, 
    substring(mza,13,3)::integer  mza_int,
    lado_id,mza, lado::text,st_union(geom) geom,codigo
FROM lado_manzana
GROUP BY lado_id,mza,lado,codigo
), listado AS (
	SELECT * 
    FROM listados.caba c 
    JOIN segmentaciones.equilibrado e 
    	ON c.id=e.listado_id
), cant_x_lado as (
	SELECT depto,frac, radio, mza, lado, count(*) cant_vivs_x_lado
    FROM listado
    GROUP BY depto,frac, radio, mza, lado
)
SELECT 
-- El orden dentro del lado esa dictado por el orden en el listado.
row_number() OVER(PARTITION BY lado_id ORDER BY id) orden_en_lado,
--cant_vivs_x_lado,
/*
TODO: contar solo los numero distintios y cuando el numero es el mismo hacer el desplaamiento hacia dentro (logaritmicamente) de la manzana
*/
--1.0*row_number() OVER(PARTITION BY lado_id ORDER BY id)/cant_vivs_x_lado ubicacion_escalada,
ST_LineInterpolatePoint(st_offsetcurve(ST_LineSubstring(st_LineMerge(geom),0.05,0.95),6),
  1.0*row_number() OVER(PARTITION BY lado_id ORDER BY id)/cant_vivs_x_lado                     
                       ) geom_point,
list.*
--into segmenta_caba_20
FROM listado list
 FULL JOIN lados ON list.lado=lados.lado::integer 
 AND (list.depto=lados.depto::integer) 
 AND (list.frac=lados.frac::integer) 
 AND (list.radio=lados.radio::integer) 
 AND (list.mza=lados.mza_int)
 JOIN cant_x_lado cl ON cl.depto=list.depto AND cl.frac=list.frac AND cl.radio=list.radio AND  cl.mza=list.mza AND cl.lado=list.lado
WHERE list.depto in (8,11,14,15) 

