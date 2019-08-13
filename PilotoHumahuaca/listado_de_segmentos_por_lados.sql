WITH 
e00 as (
SELECT codigo10, nomencla, codigo20, ancho, anchomed, tipo, nombre, ladoi, ladod, desdei, desded, hastai, hastad, mzai, mzad, 
    codloc20, nomencla10, nomenclai, nomenclad, wkb_geometry,'e0359'::text cover,
    segi, segd FROM e0359.arc
)
,lados_de_manzana as (
    select codigo20,mzai||'-'||ladoi as lado_id, mzai as mza, ladoi as lado, avg(anchomed) as anchomed,
        st_linemerge(st_union(st_reverse(wkb_geometry))) as geom,cover, segi seg
    from e00
    where mzai is not Null and mzai != ''
    group by codigo20,mzai, ladoi,cover,segi
    union
    select codigo20,mzad||'-'||ladod as lado_id, mzad as mza, ladod as lado, avg(anchomed) as anchomed,
        st_linemerge(st_union(wkb_geometry)) as geom,cover, segd seg
    from e00
    where mzad is not Null and mzad != ''
    group by codigo20,mzad, ladod,cover,segd
),
lados_codigos as (
    select codigo20, lado_id, mza, lado, seg,
        st_simplifyVW(st_linemerge(st_union(geom)),10) as geom,cover
    from lados_de_manzana
    group by codigo20,lado_id, mza, lado,cover,seg
),
lado_manzana AS (
    select substring(mza,1,2)::integer as prov,substring(mza,3,3)::integer as depto,substring(mza,6,3)::integer as codloc,
    substring(mza,9,2)::integer as frac, substring(mza,11,2)::integer radio, substring(mza,13,3)::integer as mza, 
    substring(cover,2,4) codaglo,
        codigo20,lado_id, mza link, lado::integer,seg::integer, 
        st_buffer(st_OffsetCurve(ST_LineSubstring(geom,0.10,0.90),-6),4,'endcap=flat join=round') geom,
        CASE WHEN st_geometrytype(geom) != 'ST_LineString' THEN 'Lado discontinuo' END as error_msg,
        row_number() OVER w as ranking
    from lados_codigos
        WINDOW w AS (PARTITION BY mza ORDER BY st_y(st_startpoint(geom))  desc, --y_start
                                                                            st_x(st_startpoint(geom))  ASC)   -- x_start 
    ORDER BY mza,lado),
final AS (
     
SELECT  prov||'-'||depto||'-'||codloc||'-'||frac||'-'||radio||'-'||seg as gid, prov,depto,codloc,frac,radio,codaglo,seg,mza,lado, sum(conteo) vivseg
,'*'::char(1) "final", st_union(geom) geom
FROM lado_manzana
LEFT JOIN segmentacion.conteos USING (prov,depto,codloc,frac,radio,mza,lado)
    WHERE seg!=0
GROUP BY 1,2,3,4,5,6,7,8,9,10
ORDER BY 1,2,3,4,5,6, 7,8,9,10
), mi_tabla AS (
SELECT --st_asText(geom) geom_text,
row_number() OVER() id, *
--into segmentacion.poligonos 
FROM final
    )
    SELECT id, LPAD(prov::text, 2, '0')::char(2) prov, '0105'::char(4) codmuni,'MU'::char(2) catmuni,
    codaglo, '01'::char(2) nroentidad,
    LPAD(depto::text, 3, '0')::char(3) depto,
LPAD(codloc::text, 3, '0')::char(3) codloc,
LPAD(frac::text, 2, '0')::char(2) frac, LPAD(radio::text, 2, '0')::char(2) radio, 'U'::char(1) tiporad,
LPAD(mza::text, 3, '0')::char(3) mza,LPAD(lado::text, 2, '0')::char(2) lado,
null::char(1) tipoform,
LPAD(seg::text, 2, '0')::char(2) seg, 
null::char(2) ve_cc_bc_ca, CASE WHEN codloc=000 THEN 1 ELSE 0 END::char(1) rural,
COALESCE(vivseg,0) vivseg, final::char(1)
--, geom
FROM mi_tabla
    --WHERE (frac,radio) in (('30','11'))
;
