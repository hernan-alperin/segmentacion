begin;
grant insert on segmentacion.conteos to segmentador;
grant delete on segmentacion.conteos to segmentador;
grant usage on schema listados to segmentador;
grant select on listados.listado_humauaca_chiquitas to segmentador;
commit;

create function cargar(shape text) 
returns integer as
$$
begin
delete from segmentacion.conteos
where shape = '$1.arc';
execute 'grant usage on schema ' || shape || ' to segmentador';
execute 'grant all on ' || schema || '.arc to segmentador';
execute 'alter table ' || schema || '.e0359.arc add column segi integer';
execute 'alter table ' || schema || '.e0359.arc add column segd integer';
execute '
WITH listado_sin_vacios AS (
    SELECT 
    id, prov::integer, nom_provincia, dpto::integer, nom_dpto, codaglo, codloc::integer, 
    nom_loc, codent, nom_ent, frac::integer, radio::integer, mza::integer, lado::integer
    FROM 
    -------------------- listado --------------------------
    listados.listado_humauaca_chiquitas
    -------------------------------------------------------
    WHERE prov!='' AND dpto!=''  AND codloc!='' and frac!='' and radio!='' and mza !='' and lado!=''
)
, e00 as (
    SELECT codigo10, nomencla, codigo20, ancho, anchomed, tipo, nombre, ladoi, ladod, desdei, desded, hastai, hastad, mzai, mzad,
    codloc20, nomencla10, nomenclai, nomenclad, wkb_geometry,
    -------------------- nombre de covertura y tabla de shape
    '$1'::text cover FROM '' || $1 || ''.arc
    ---------------------------------------------------------
)
, lados_de_manzana as (
    select codigo20, mzai||'-'||ladoi as lado_id, mzai as mza, ladoi as lado, avg(anchomed) as anchomed,
        st_linemerge(st_union(st_reverse(wkb_geometry))) as geom, cover
    from e00
    where mzai is not Null and mzai != ''
    group by codigo20, mzai, ladoi, cover
    union
    select codigo20, mzad||'-'||ladod as lado_id, mzad as mza, ladod as lado, avg(anchomed) as anchomed,
        st_linemerge(st_union(wkb_geometry)) as geom, cover
    from e00
    where mzad is not Null and mzad != ''
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
        CASE WHEN st_geometrytype(geom) != 'ST_LineString' THEN 'Lado discontinuo' END as error_msg
    from lados_codigos
    ORDER BY mza, lado
), listado_carto AS (
    SELECT * 
    FROM lado_manzana
    LEFT JOIN listado_sin_vacios USING (prov,dpto,codloc,frac,radio,mza,lado)
)
-- Conteo x lado de manzna
SELECT row_number() OVER () gid,'$1.arc'::text shape, prov, dpto depto, codloc,
    frac, radio, mza, lado,
    count(CASE 
          WHEN trim(cod_tipo_vivredef) in ('', 'CO', 'N', 'CA/', 'LO')
            THEN NULL 
            ELSE cod_tipo_vivredef END) conteo
insert INTO segmentacion.conteos
FROM listado_carto
GROUP BY prov, dpto, codloc, frac, radio, mza, lado, geom
ORDER BY count(CASE WHEN trim(cod_tipo_vivredef)='' THEN NULL ELSE cod_tipo_vivredef END) desc'
;
end;
$$
language plpgsql
;

