/*
titulo: 
descripción:
autor: -h
fecha: 2019-04-18 Ju
*/




--- usando windows para ayudar a calcular cortes
drop view segmentando_facil;
create or replace view segmentando_facil as 
with deseado as (
    select 40 as deseado),
    separados as (
    SELECT frac_comun, radio_comu::integer, mza_comuna::integer, clado, hn, hp, hd, id, 
        row_number() OVER w as row, rank() OVER w as rank
    FROM comuna11
    WINDOW w AS (PARTITION BY comunas, frac_comun, radio_comu::integer, mza_comuna::integer
    ORDER BY comunas, frac_comun, radio_comu::integer, mza_comuna::integer, clado, id)
    ),
    sumados as (
    select frac_comun, radio_comu::integer, mza_comuna::integer, count(*) as cant
    from comuna11
    group by comunas, frac_comun, radio_comu::integer, mza_comuna::integer
    ),
    parejo as (
    select ceil(cant/deseado)*deseado as redondo
    from sumados, deseado
    )
select frac_comun, radio_comu, mza_comuna, clado, hn, hp, ceil(rank/deseado) + 1 as segmento_manzana
from deseado, separados
left join sumados
using(frac_comun, radio_comu, mza_comuna)
order by frac_comun, radio_comu::integer, mza_comuna::integer, clado, id
;

---------------------------------

alter table comuna11 add column segmento_en_manzana integer;
update comuna11 l
set segmento_en_manzana = segmento_manzana
from segmentando_facil f
where (l.frac_comun, l.radio_comu::integer, l.mza_comuna::integer, l.clado, l.hn, case when l.hp is Null then 0 else l.hp end) = 
    (f.frac_comun, f.radio_comu, f.mza_comuna, f.clado, f.hn, case when f.hp is Null then 0 else f.hp end)
;

-----------------------------------------------------


select frac_comun, radio_comu, mza_comuna, clado, hn, hp, segmento_en_manzana 
from comuna11
order by frac_comun, radio_comu, mza_comuna, clado, id
;


-------------------------------------------------------------------
-- calcula la cantidad de viviendas por segmento que menor se aparte
-- de la catidad deseaado
-------------------------------------------------------------------
-- caso para testear

with deseado as (
    select 40::float as deseado
    ),
    casos as (
    select generate_series(1, 1000) as vivs
    ),
    posibles_segs_mza as (
    select vivs, greatest(1, floor(vivs/deseado)) as min, ceil(vivs/deseado) as max
    from casos, deseado
    ),
    mejor_diferencia as (
    select vivs, min, max, 
           case when abs(vivs/max - deseado) < abs(vivs/min - deseado) then max
           else min end as seg_x_mza
    from posibles_segs_mza, deseado
    )
select * from mejor_diferencia
;
-----------------------------------------------------------------------------------
-- separando listado por segmentos en manzanas independientes
-- donde la distribución de viviendas en cada segmento en la manzana es equilibrado
-- y rank es el orden de visita en el segmento
-----------------------------------------------------------------------------------
drop view segmentando_equilibrado;
create or replace view segmentando_equilibrado as 
with deseado as (
    select 40::float as deseado),
    casos as (
    select comunas, frac_comun, radio_comu::integer, mza_comuna::integer,
           count(*) as vivs,
           ceil(count(*)/deseado) as max,
           greatest(1, floor(count(*)/deseado)) as min
    from comuna11, deseado
    group by comunas, frac_comun, radio_comu::integer, mza_comuna::integer, deseado
    ),
    deseado_manzana as (
    select comunas, frac_comun, radio_comu::integer, mza_comuna::integer, vivs, 
        case when abs(vivs/max - deseado) < abs(vivs/min - deseado) then max
        else min end as seg_x_mza
    from casos, deseado
    ),
    separados as (
    SELECT frac_comun, radio_comu::integer, mza_comuna::integer, clado, hn, hp, hd, id
        row_number() OVER w as row, rank() OVER w as rank
    FROM comuna11
    WINDOW w AS (PARTITION BY comunas, frac_comun, radio_comu::integer, mza_comuna::integer
    ORDER BY comunas, frac_comun, radio_comu::integer, mza_comuna::integer, clado, id)
    ),
    sumados as (
    select frac_comun, radio_comu::integer, mza_comuna::integer, count(*) as cant
    from comuna11
    group by comunas, frac_comun, radio_comu::integer, mza_comuna::integer
    )
select frac_comun, radio_comu, mza_comuna, clado, hn, hp, hd,
    floor((rank - 1)*seg_x_mza/vivs) + 1 as segmento, rank
from deseado_manzana
join separados
using(frac_comun, radio_comu, mza_comuna)
left join sumados
using(frac_comun, radio_comu, mza_comuna)
order by frac_comun, radio_comu::integer, mza_comuna::integer, clado,
    floor((rank - 1)*seg_x_mza/vivs) + 1, rank
;
                    
--------------------------------------------------------
                    
select frac_comun, radio_comu, mza_comuna, segmento_manzana, count(*)
from segmentando_equilibrado
group by frac_comun, radio_comu, mza_comuna, segmento_manzana
order by frac_comun, radio_comu, mza_comuna, segmento_manzana
;

                                                                      
                                                                      
                                                                      
--------                 

alter table comuna11 add column segmento_en_manzana integer;
update comuna11 l
set segmento_en_manzana = segmento_manzana
from segmentando_equilibrado f
where (l.frac_comun, l.radio_comu::integer, l.mza_comuna::integer, l.clado, l.hn, case when l.hp is Null then 0 else l.hp end) = 
    (f.frac_comun, f.radio_comu, f.mza_comuna, f.clado, f.hn, case when f.hp is Null then 0 else f.hp end)
;

-----------------------------------------------------


select frac_comun, radio_comu, mza_comuna, clado, hn, hp, segmento_en_manzana
from comuna11
order by frac_comun, radio_comu, mza_comuna, clado, id
;

alter table comuna11 add column segmento_en_manzana_equilibrado integer;
update comuna11 l
set segmento_en_manzana_equilibrado = segmento_manzana
from segmentando_equilibrado f
where (l.frac_comun, l.radio_comu::integer, l.mza_comuna::integer, l.clado, l.hn, case when l.hp is Null then 0 else l.hp end) = 
    (f.frac_comun, f.radio_comu, f.mza_comuna, f.clado, f.hn, case when f.hp is Null then 0 else f.hp end)
;

-----------------------------------------------------


select frac_comun, radio_comu, mza_comuna, clado, hn, hp, segmento_en_manzana_equilibrado
from comuna11
order by frac_comun, radio_comu, mza_comuna, clado, id
;

                                                                      
                                                                      

-------------------------------------------------------
                                                                      
--DROP table if exists listado_georef_segmentado cascade;
DROP table if exists listado_georef_segmentado_equilibrado cascade;
                                                                    
WITH e0211lineas as (
SELECT min(gid) gid, codigo10, nomencla, codigo20, ancho, anchomed, tipo, nombre, ladoi, ladod, desdei, desded, 
    hastai, hastad, mzai, mzad, codloc20, nomencla10, nomenclai, nomenclad, codigo, codigoc, mci, mcd, 
    st_LineMerge(st_union(geom)) geom
	FROM public.e0211lin
    GROUP BY  codigo10, nomencla, codigo20, ancho, anchomed, tipo, nombre, ladoi, ladod, desdei, desded, 
    hastai, hastad, mzai, mzad, codloc20, nomencla10, nomenclai, nomenclad, codigo, codigoc, mci, mcd
    HAVING st_geometrytype(st_LineMerge(st_union(geom)))='ST_LineString'
)
SELECT 
CASE
	WHEN hastai-desdei>0 and e.mzai like '%'||l.mza_comuna THEN
        CASE 
           WHEN (((hn::integer-desdei)::numeric/(hastai-desdei)<0 or (hn::integer-desdei)::numeric/(hastai-desdei)>1 ) ) THEN
            ST_LineInterpolatePoint(st_offsetcurve(ST_LineSubstring(st_LineMerge(geom),0.07,0.93),8),0.5)
           WHEN (e.mzai like '%'||l.mza_comuna) THEN -- ! l.clado=e.ladoi 
            ST_LineInterpolatePoint(st_offsetcurve(ST_LineSubstring(st_LineMerge(geom),0.07,0.93),8),(hn::integer-desdei)::numeric/(hastai-desdei))
        END
    WHEN (hastad-desded>0 and (e.mzad like '%'||l.mza_comuna)) THEN
		CASE
		  WHEN ((hn::integer-desded)::numeric/(hastad-desded)<0 or (hn::integer-desded)::numeric/(hastad-desded)>1 ) THEN                    
				ST_LineInterpolatePoint(st_reverse(st_offsetcurve(ST_LineSubstring(st_LineMerge(geom),0.07,0.93),-8)),0.5)
		  WHEN (e.mzad like '%'||l.mza_comuna) THEN --l.clado=e.ladod and 
				ST_LineInterpolatePoint(st_reverse(st_offsetcurve(ST_LineSubstring(st_LineMerge(geom),0.07,0.93),-8)),(hn::integer-desded)::numeric/(hastad-desded))
		END
	WHEN (e.mzai like '%'||l.mza_comuna) THEN
       ST_LineInterpolatePoint(st_offsetcurve(ST_LineSubstring(st_LineMerge(geom),0.07,0.93),8),0.5)
	WHEN ( e.mzad like '%'||l.mza_comuna) THEN                    
       ST_LineInterpolatePoint(st_reverse(st_offsetcurve(ST_LineSubstring(st_LineMerge(geom),0.07,0.93),-8)),0.5) 
 END as geom,
e.gid||'-'||l.id id ,e.gid id_lin,l.id id_list, geom geom_lado, --fnode_, tnode_, lpoly_, rpoly_, length, ecapi_, ecapi_id, 
codigo10, nomencla, codigo20, ancho, anchomed, tipo, nombre, ladoi,
ladod, desdei, desded, hastai, hastad, mzai, mzad, codloc20, nomencla10, nomenclai, nomenclad, codigo, codigoc, mci, mcd, 
--segmento_en_manzana,
segmento_en_manzana_equilibrado,                                         
comunas, idbarrio, frac_comun, radio_comu, mza_comuna, clado, ccodigo, cnombre, hn, h4, hp, hd, nomencla_2
--into listado_georef_segmentado
into listado_georef_segmentado_equilibrado
FROM e0211lineas e JOIN comuna11 l ON l.ccodigo::integer=e.codigo10 and --l.cnombre=e.nombre and
     ((--l.clado=e.ladoi and 
         e.mzai like 
		 '%'||btrim(to_char(l.frac_comun::integer, '09'::text))::character varying(3)||btrim(to_char(l.radio_comu::integer, '09'::text))::character varying(3)||btrim(to_char(l.mza_comuna::integer, '099'::text))::character varying(3) 
		 and hn::integer between desdei and hastai) 
 or ( --l.clado=e.ladod and 
     e.mzad like  
	 '%'||btrim(to_char(l.frac_comun::integer, '09'::text))::character varying(3)||btrim(to_char(l.radio_comu::integer, '09'::text))::character varying(3)||btrim(to_char(l.mza_comuna::integer, '099'::text))::character varying(3) 
	 and hn::integer between desded and hastad))
--WHERE frac_comun=4 and radio_comu=1 --and (hn-desded)>0 and (hn-desdei)>0

 --   GROUP BY comunas, idbarrio, frac_comun, radio_comu, mza_comuna, clado, ccodigo, cnombre, hn, h4, hp, hd, nomencla_2
    --WHERE hd is not null
   -- HAVING count(*)=1
;
--------                 

 

