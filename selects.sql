/*
titulo: selects para depurar y clasificar
descripción: lo que mandó Manu
autor: -h
fecha: 2019-04-18 Ju
*/

                                                                    
                                                                      

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

 

