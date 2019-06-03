/*
titulo: costo_segmento.sql
descripción: calcula el costo de un segmento
como la distancia absoluta de la cantidad de viviendas
al valor deseado 
autor: -h
fecha: 2019-05-01 Mi
*/

drop function costo_segmento;
create or replace function costo_segmento (
    segmento bigint, 
    deseado integer)
returns float as $$
select abs($1::integer - $2::integer)::float
$$
language sql
;


/*

solución inicial lazy de la segmentación
-- asignar segmento a manzanas completas
-- 1 segmento = 1 manzana

with s as (
    select frac, radio, mza, rank()
        over (
        partition by frac, radio
        order by mza) as sgm_id
    from listados.caba
    group by frac, radio, mza)
select frac, radio, sgm_id, count(*) as vivs, costo_segmento(count(*), 40)
from s
natural join listados.caba
group by frac, radio, sgm_id
limit 10
;

 frac | radio | sgm_id | vivs | costo_segmento 
------+-------+--------+------+----------------
    1 |     1 |      1 |  249 |            209
    1 |     1 |      2 |  154 |            114
    1 |     1 |      3 |  164 |            124
    1 |     1 |      4 |  103 |             63
    1 |     1 |      5 |   73 |             33
    1 |     1 |      6 |   77 |             37
    1 |     1 |      7 |   30 |             10
    1 |     1 |      8 |   15 |             25
    1 |     2 |      1 |   20 |             20
    1 |     2 |      2 |   28 |             12
*/


                          
