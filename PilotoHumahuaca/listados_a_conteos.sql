/*
hace join con la cartografía para recuperar los lados que no estan en el listado por no tener viviendas
además de otros controles
TODO: revisar cuales campos son necesarios, ya que la cosulta es una reutilización de otra reutilización de consultas
*/

------------------------

--DROP TABLE IF EXISTS segmentacion.conteos
delete from segmentacion.conteos
where shape like 'e0359%'
;

insert into segmentacion.conteos
WITH listado_sin_vacios AS (
    SELECT 
    -------------------- campos del listado
    id, prov::integer, nom_provincia, dpto::integer, nom_dpto, codaglo, codloc::integer, nom_loc, codent, nom_ent, frac::integer, radio::integer, mza::integer,
    lado::integer,
nro_inicial, nro_final, orden_recorrido_viv, nro_listado, ccalle, ncalle, nro_catastral, nrocatastralredef, piso, pisoredef, casa,
dpto_habitacion, sector, edificio, entrada, cod_tipo_viv, cod_tipo_vivredef, cod_subt_vivloc, descripcion, descripcion_lado,
cod_postal, orden_recorrido_mza

    FROM 
    -------------------- listado --------------------------
    e0359.listado
    -------------------------------------------------------
--    WHERE prov!='' AND dpto!=''  AND codloc!='' and frac!='' and radio!='' and mza !='' and lado!=''
  where prov = 38 and dpto = 28 and frac = 4
)
, e00 as (
    SELECT codigo10, nomencla, codigo20, ancho, anchomed, tipo, nombre, ladoi, ladod, desdei, desded, hastai, hastad, mzai, mzad,
    codloc20, nomencla10, nomenclai, nomenclad, wkb_geometry,
    -------------------- nombre de covertura y tabla de shape
    'e0359'::text cover FROM e0359.arc
    ---------------------------------------------------------
)
,lados_de_manzana as (
    select codigo20,mzai||'-'||ladoi as lado_id, mzai as mza, ladoi as lado, avg(anchomed) as anchomed,
        st_linemerge(st_union(st_reverse(wkb_geometry))) as geom,cover
    from e00
    where mzai is not Null and mzai != ''
    group by codigo20,mzai, ladoi,cover
    union
    select codigo20,mzad||'-'||ladod as lado_id, mzad as mza, ladod as lado, avg(anchomed) as anchomed,
        st_linemerge(st_union(wkb_geometry)) as geom,cover
    from e00
    where mzad is not Null and mzad != ''
    group by codigo20,mzad, ladod,cover
),
lados_codigos as (
    select codigo20, lado_id, mza, lado,
        st_simplifyVW(st_linemerge(st_union(geom)),10) as geom,cover
    from lados_de_manzana
    group by codigo20,lado_id, mza, lado,cover
),
lado_manzana AS (
    select substring(mza,1,2)::integer as prov,substring(mza,3,3)::integer as dpto,substring(mza,6,3)::integer as codloc,
    substring(mza,9,2)::integer as frac, substring(mza,11,2)::integer radio, substring(mza,13,3)::integer as mza,
        codigo20,lado_id, mza link, lado::integer, geom, st_azimuth(st_startpoint(geom),st_endpoint(geom)) azimuth,cover,
        CASE WHEN st_geometrytype(geom) != 'ST_LineString' THEN 'Lado discontinuo' END as error_msg
    from lados_codigos
    ORDER BY mza,lado
),listado_carto AS (
    SELECT * FROM lado_manzana
    LEFT JOIN listado_sin_vacios USING (prov,dpto,codloc,frac,radio,mza,lado)
)

-- Conteo x lado de manzna
SELECT row_number() OVER () gid,'e0359'::text shape, prov,dpto depto,codloc,frac,radio,mza,lado,
count(CASE WHEN trim(cod_tipo_vivredef) in ('', 'CO', 'N', 'CA/', 'LO')
 THEN NULL ELSE cod_tipo_vivredef END) conteo

--,st_line_interpolate_point(ST_OffsetCurve(((geom)),-8),0.5) geom
--INTO segmentacion.conteos
FROM listado_carto
GROUP BY prov,dpto,codloc,frac,radio,mza,lado, geom
ORDER BY count(CASE WHEN trim(cod_tipo_vivredef)='' THEN NULL ELSE cod_tipo_vivredef END) desc
;



---------------------------------



select frac, radio, mza, sum(conteo)
from segmentacion.conteos
group by frac, radio, mza
order by sum
;

          
