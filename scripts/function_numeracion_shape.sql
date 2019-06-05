/*
Función de numeración, basado en la información de manzana izquierda y derecha se númeran los lados de la manzana 
iniciando por el lado mas norte y continunando en sentido horario (regla del hombro derecho :) ).
*/

CREATE OR REPLACE FUNCTION indec.numeracion_shape(esquema character varying, tabla character varying)
 RETURNS TABLE(row_id bigint, info text, info_graf text, lados_dif text, angulo_anterior_grados numeric, mza character varying, codigo20 numeric, cover text, lado_original integer, geom geometry, angulo_anterior double precision, userid text, orden integer, userid_sig text, cycle boolean, route text[], lado integer)
 LANGUAGE plpgsql
AS $function$

DECLARE 
    var_r record;
    estearc character varying;
    miquery character varying;
BEGIN

estearc = esquema||'.'||tabla;
RAISE NOTICE  'Tabla: %', estearc;

miquery = format('
WITH RECURSIVE e00 AS (
         SELECT arc.id userid,
            arc.codigo20,
            arc.tipo,
            arc.nombre,
            arc.ladoi,
            arc.ladod,
            arc.desdei,
            arc.desded,
            arc.hastai,
            arc.hastad,
            arc.mzai,
            arc.mzad,
            geom wkb_geometry,
            ''%1$s''::text AS cover,
            ''%1$s''::text AS codaglo
           FROM %2$s arc
        ), lados_de_manzana AS (
         SELECT e00.codigo20,
            e00.mzai AS mza,
            (e00.codaglo || ''.i.''::text) || e00.userid AS userid,
            e00.ladoi AS lado_original,
            st_reverse(e00.wkb_geometry) AS geom,
            e00.cover
           FROM e00
          WHERE e00.mzai IS NOT NULL AND e00.mzai::text <> ''''::text
        UNION
         SELECT e00.codigo20,
            e00.mzad AS mza,
            (e00.codaglo || ''.d.''::text) || e00.userid AS userid,
            e00.ladod AS lado_original,
            e00.wkb_geometry AS geom,
            e00.cover
           FROM e00
          WHERE e00.mzad IS NOT NULL AND e00.mzad::text <> ''''::text
        ), lado_numerado_1 AS (
         SELECT lados_de_manzana.codigo20,
            lados_de_manzana.mza,
            lados_de_manzana.userid,
            lados_de_manzana.lado_original,
            lados_de_manzana.geom,
            lados_de_manzana.cover,
                CASE
                    WHEN dense_rank() OVER norte = 1 THEN 1
                    ELSE NULL::integer
                END AS orden
           FROM lados_de_manzana
          WINDOW norte AS (PARTITION BY lados_de_manzana.mza ORDER BY (st_y(st_snaptogrid(st_startpoint(lados_de_manzana.geom), 0::double precision)))
                DESC, (st_x(st_startpoint(lados_de_manzana.geom))) , st_x(ST_PointN(lados_de_manzana.geom,2)) desc )
        ), lado_angulo_siguiente AS (
         SELECT row_number() OVER () AS id,
            l.mza,
            l.codigo20,
            l.cover,
            l.userid,
            l.orden,
            l2.userid AS userid_sig,
            l.lado_original,
            st_azimuth(st_pointn(st_rotate(l2.geom, st_azimuth(st_pointn(l.geom, st_numpoints(l.geom) - 1), st_pointn(l.geom, st_numpoints(l.geom))), 
                st_pointn(l.geom, 1)), 1), st_pointn(st_rotate(l2.geom, st_azimuth(st_pointn(l.geom, st_numpoints(l.geom) - 1), st_pointn(l.geom, 
                st_numpoints(l.geom))), st_pointn(l.geom, 1)), 2)) AS angulo_anterior,
            l.geom
           FROM lado_numerado_1 l
             JOIN lado_numerado_1 l2 ON st_buffer(st_endpoint(l.geom), 0.5::double precision) && st_buffer(st_startpoint(l2.geom), 
                0.5::double precision) AND l.mza::text = l2.mza::text
        ), lado_ordenado AS (
         SELECT l.mza,
            l.codigo20,
            l.cover,
            l.userid,
            l.orden,
            l.geom,
            l.userid_sig,
            l.lado_original,
                CASE
                    WHEN round(l.angulo_anterior::numeric, 8) >= round(pi()::numeric, 8) THEN pi() - l.angulo_anterior
                    ELSE l.angulo_anterior
                END AS angulo_anterior_original,
                CASE
                    WHEN round(l.angulo_anterior::numeric, 8) >= round(pi()::numeric, 8) THEN l.angulo_anterior - 2::double precision * pi()
                    ELSE l.angulo_anterior
                END AS angulo_anterior
           FROM lado_angulo_siguiente l
        ), lado_siguiente AS (
         SELECT foo.orden,
            foo.mza,
            foo.codigo20,
            foo.cover,
            foo.userid,
            foo.lado_original,
            foo.geom,
            foo.angulo_anterior_original,
            foo.userid_sig,
            foo.angulo_anterior
           FROM ( SELECT l.orden,
                    l.mza,
                    l.codigo20,
                    l.cover,
                    l.userid,
                    l.lado_original,
                    l.geom,
                    l.angulo_anterior_original,
                        CASE
                            WHEN dense_rank() OVER (PARTITION BY l.userid ORDER BY l.angulo_anterior DESC) = 1 THEN l.userid_sig
                            ELSE NULL::text
                        END AS userid_sig,
                    l.angulo_anterior
                   FROM lado_ordenado l) foo
          WHERE foo.userid_sig IS NOT NULL
        ), arcos_ordenados AS (
         SELECT l.mza,
            l.codigo20,
            l.cover,
            l.lado_original,
            l.geom,
            l.angulo_anterior,
            l.userid,
            l.orden,
            l.userid_sig,
            false AS cycle,
            ARRAY[l.userid] AS route,
            1 AS lado
           FROM lado_siguiente l
          WHERE l.orden = 1
        UNION ALL
         SELECT l.mza,
            l.codigo20,
            l.cover,
            l.lado_original,
            l.geom,
            abs(l.angulo_anterior) AS angulo_anterior,
            l.userid,
            la.orden + 1 AS orden,
            l.userid_sig,
            l.userid_sig = ANY (la.route) AS cycle,
            la.route || l.userid AS route,
                CASE
                    WHEN l.orden = 1 THEN 1
                    WHEN l.codigo20 = la.codigo20 AND (abs(la.angulo_anterior) < ((1::numeric / 4::numeric)::double precision * pi()) 
                OR abs(la.angulo_anterior) > ((7::numeric / 4::numeric)::double precision * pi())) THEN la.lado
                    ELSE la.lado + 1
                END AS lado
           FROM lado_siguiente l
             JOIN arcos_ordenados la ON l.userid = la.userid_sig
          WHERE la.cycle = false
        )
 SELECT row_number() OVER () AS id,
        CASE
            WHEN arcos_ordenados.lado::double precision = arcos_ordenados.lado_original::numeric THEN ''==''::text
            ELSE ''x''::text
        END AS info,
        CASE
            WHEN arcos_ordenados.orden = 1 THEN chr(9484) || chr(9488)
            WHEN arcos_ordenados.cycle THEN chr(9492) || chr(9496)
            ELSE ''| |''::text
        END AS info_graf,
        CASE
            WHEN arcos_ordenados.lado::double precision <> arcos_ordenados.lado_original::numeric THEN ((arcos_ordenados.lado::text || ''(''::text) ||
                arcos_ordenados.lado_original) || '')''::text
            ELSE arcos_ordenados.lado::text
        END AS lados_dif,
    abs(round((arcos_ordenados.angulo_anterior::numeric::double precision / (2::double precision * pi()) * 360::double precision)::numeric, 0))
                AS angulo_anterior_grados,
    arcos_ordenados.mza,
    arcos_ordenados.codigo20::NUMERIC,
    arcos_ordenados.cover,
    arcos_ordenados.lado_original::INT,
    arcos_ordenados.geom,
    arcos_ordenados.angulo_anterior,
    arcos_ordenados.userid,
    arcos_ordenados.orden,
    arcos_ordenados.userid_sig,
    arcos_ordenados.cycle,
    arcos_ordenados.route,
    arcos_ordenados.lado
   FROM arcos_ordenados
  ORDER BY arcos_ordenados.mza, arcos_ordenados.cover, arcos_ordenados.orden;
',estearc,estearc); 

RAISE NOTICE 'SQL %',miquery;
RETURN query EXECUTE miquery;
END 