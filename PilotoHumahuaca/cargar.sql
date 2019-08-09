select *
from e0359.listado
where trim(nom_dpto) = 'Humahuaca'
;




---------------------------------------------------

DROP TABLE IF EXISTS segmentacion.conteos;
--delete from segmentacion.conteos
--where shape =

WITH listado_sin_vacios AS (
    SELECT 
    -------------------- campos del listado
    id, prov::integer, nom_provincia, dpto::integer, nom_dpto, codaglo, codloc::integer, nom_loc, codent, nom_ent, frac::integer, radio::integer, mza::integer,
    lado::integer,
nro_inicial, nro_final, orden_recorrido_viv, nro_listado, ccalle, ncalle, nro_catastral, nrocatastralredef, piso, pisoredef, casa,
dpto_habitacion, sector, edificio, entrada, cod_tipo_viv, cod_tipo_vivredef, cod_subt_vivloc, descripcion, descripcion_lado,
cod_postal, orden_recorrido_mza, estado, esta_supervisado,
creadoen, chequeadoen, editadoen, borradoen, creado, chequeado, editado, borrado, actualizador, supervisor, usuario, tipo_base, tipo_tarea 
    FROM 
    -------------------- listado --------------------------
    e0359.listado
    -------------------------------------------------------
    WHERE prov!='' AND dpto!=''  AND codloc!='' and frac!='' and radio!='' and mza !='' and lado!=''
    and trim(nom_dpto) = 'Humahuaca'
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
SELECT row_number() OVER () gid,'e0359.arc'::text shape, prov,dpto depto,codloc,frac,radio,mza,lado,
count(CASE WHEN trim(cod_tipo_vivredef) in ('', 'CO', 'N', 'CA/', 'LO')
 THEN NULL ELSE cod_tipo_vivredef END) conteo

--,st_line_interpolate_point(ST_OffsetCurve(((geom)),-8),0.5) geom
INTO segmentacion.conteos
FROM listado_carto
GROUP BY prov,dpto,codloc,frac,radio,mza,lado, geom
ORDER BY count(CASE WHEN trim(cod_tipo_vivredef)='' THEN NULL ELSE cod_tipo_vivredef END) desc
;



---------------------------------

delete
from segmentacion.adyacencias
where prov::integer = 38 and depto::integer = 28
;

insert into segmentacion.adyacencias (shape, prov, depto, frac, radio, mza, lado, mza_ady, lado_ady)
select 'e0359.arc' as shape, substr(mzai,1,2)::integer as prov, substr(mzai,3,3)::integer as depto
    , substr(mzai,9,2)::integer as frac, substr(mzai,11,2)::integer as radio
    , substr(mzai,13,3)::integer as mza, ladoi as lado, substr(mzad,13,3)::integer as mza_ady, ladod as lado_ady
from e0359.arc
where substr(mzai,1,12) = substr(mzad,1,12) -- mismo radio
    and mzad != '' and mzad is not Null and mzai != '' and mzai is not Null
    -- and ladod != 0 and ladod is not Null and ladoi != 0 and ladoi is not Null
union
select 'e0357a' as shape, substr(mzad,1,2)::integer as prov, substr(mzad,3,3)::integer as depto
    , substr(mzad,9,2)::integer as frac, substr(mzad,11,2)::integer as radio
    , substr(mzad,13,3)::integer as mza, ladod as lado, substr(mzai,13,3)::integer as mza_ady, ladoi as lado_ady
from e0359.arc
where substr(mzai,1,12) = substr(mzad,1,12) -- mismo radio
    and mzai != '' and mzai is not Null and mzad != '' and mzad is not Null
    -- and ladod != 0 and ladod is not Null and ladoi != 0 and ladoi is not Null
;


select frac, radio, mza, sum(conteo)
from segmentacion.conteos
group by frac, radio, mza
order by sum
;

                                                                    
                                                                    
----------------------------------

python SegmentaManzanasLados.py e0357 06 357
python SegmentaManzanasLados_manu.py shapes.e0357a 06 357 8 12 10 1
python SegmentaManzanasLados_manu.py tabla_shape prov depto min max deseado max_viv_mza_a_partir

----------------------------------
/usr/pgsql-9.5/bin/pgsql2shp -u segmentador -P rodatnemges -f shapes/e0357a censo2020 shapes."e0357a"
