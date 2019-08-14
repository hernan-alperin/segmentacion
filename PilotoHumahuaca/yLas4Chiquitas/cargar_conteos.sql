begin;
grant insert on segmentacion.conteos to segmentador;
grant delete on segmentacion.conteos to segmentador;
grant usage on schema listados to segmentador;
grant select on listados.listado_humauaca_chiquitas to segmentador;
commit;

-- hardcode ------------------------
alter table add column segi integer;
alter table add column segd integer;
------------------------------------

CREATE OR REPLACE FUNCTION indec.cargar_conteos(schema text, tabla text)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$

begin
execute 'delete from segmentacion.conteos where tabla = ''' || schema || '.' || tabla || '''';
execute 'grant usage on schema ' || schema || ' to segmentador';
execute 'grant all on ' || schema || '.' || tabla || ' to segmentador';
execute '
WITH listado_sin_vacios AS (
    SELECT
    id, prov::integer, nom_provincia, dpto::integer, nom_dpto, codaglo, codloc::integer,
    nom_loc, codent, nom_ent, frac::integer, radio::integer, mza::integer, lado::integer,
    cod_tipo_vivredef
    FROM
    -------------------- listado --------------------------
    listados.listado_humauaca_chiquitas
    -------------------------------------------------------
    WHERE prov::text!='''' AND dpto::text!=''''  AND codloc::text!=''''
    and frac::text!='''' and radio::text!='''' and mza::text !='''' and lado::text !=''''
    and mza !~* ''[A-Z]''
)
, e00 as (
    SELECT codigo10, nomencla, codigo20, ancho, anchomed, tipo, nombre, ladoi, ladod, desdei, desded, hastai, hastad, mzai, mzad,
    codloc20, nomencla10, nomenclai, nomenclad, wkb_geometry,
    -------------------- nombre de covertura y tabla de shape
    ''' || schema || '.' || tabla || '''::text as cover
    FROM ' || schema || '.' || tabla || '
    ---------------------------------------------------------
)
, lados_de_manzana as (
    select codigo20, mzai||''-''||ladoi as lado_id, mzai as mza, ladoi as lado, avg(anchomed) as anchomed,
        st_linemerge(st_union(st_reverse(wkb_geometry))) as geom, cover
    from e00
    where mzai is not Null and mzai != ''''
    group by codigo20, mzai, ladoi, cover
    union
    select codigo20, mzad||''-''||ladod as lado_id, mzad as mza, ladod as lado, avg(anchomed) as anchomed,
        st_linemerge(st_union(wkb_geometry)) as geom, cover
    from e00
    where mzad is not Null and mzad != ''''
    group by codigo20, mzad, ladod, cover
),
lados_codigos as (
    select codigo20, lado_id, mza, lado,
        st_simplifyVW(st_linemerge(st_union(geom)),10) as geom, cover
    from lados_de_manzana
    group by codigo20, lado_id, mza, lado, cover
),
lado_manzana AS (
    select substring(mza,1,2)::integer as prov,substring(mza,3,3)::integer as dpto,substring(mza,6,3)::integer as codloc,
    substring(mza,9,2)::integer as frac, substring(mza,11,2)::integer radio,
        substring(mza,13,3)::integer as mza,
        codigo20, lado_id, mza link, lado::integer,
        geom, st_azimuth(st_startpoint(geom), st_endpoint(geom)) azimuth, cover,
        CASE WHEN st_geometrytype(geom) != ''ST_LineString'' THEN ''Lado discontinuo'' END as error_msg
    from lados_codigos
    ORDER BY mza, lado
), listado_carto AS (
    SELECT *
    FROM lado_manzana
    LEFT JOIN listado_sin_vacios USING (prov,dpto,codloc,frac,radio,mza,lado)
)
-- Conteo x lado de manzna
insert INTO segmentacion.conteos
SELECT row_number() OVER () id, ''' || schema || '.' || tabla || '''::text as tabla, prov, dpto depto, codloc,
    frac, radio, mza, lado,
    count(CASE
          WHEN trim(cod_tipo_vivredef) in ('''', ''CO'', ''N'', ''CA/'', ''LO'')
            THEN NULL
            ELSE cod_tipo_vivredef END) conteo
from listado_carto
GROUP BY prov, dpto, codloc, frac, radio, mza, lado, geom
ORDER BY count(CASE WHEN trim(cod_tipo_vivredef)='''' THEN NULL ELSE cod_tipo_vivredef END) desc'
;
RETURN 1;
end;

$function$
;
