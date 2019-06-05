/*
titulo: segmentar_greedy.sql.sql
descripción: con circuitos definidos por manzanas indeendientes
va cortando de a _d_, cantidad deseada de viviendas por segmento sin cortar piso
autor: -h
fecha: 2019-06-04 Ma
*/

--- usando ventanas para ayudar a calcular cortes

create schema if not exists segmentaciones;

drop table if exists segmentaciones.greedy_sgm_radio;
create table segmentaciones.greedy_sgm_radio as
with deseado as (select 
-------- cantidad de viviendas por segmentos ----
    20 
-------------------------------------------------
    as deseado), 
    pisos_enteros as (
        select depto, frac, radio, mza, lado, numero, piso, min(id) as min_id
        from listados.caba
        group by depto, frac, radio, mza, lado, numero, piso
        order by depto, frac, radio, mza, lado, numero, min_id
    ),    
    pisos_abiertos as (
        select id, depto, frac, radio, mza, lado, numero, piso, apt, min_id,
            row_number() over w as row, rank() over w as rank
        from pisos_enteros
        natural join listados.caba
        window w as (
            partition by depto, frac, radio, mza
            -- separa las manzanas
            order by depto, frac, radio, mza, lado, min_id
            -- rankea por min_id (como corresponde pares y pisos descendiendo)
        )
    )
select id, depto, frac, radio, mza, lado, numero, piso, apt, 
    ceil(rank/deseado) + 1 as sgm_mza
from deseado, pisos_abiertos
--order by depto, frac, radio, mza, lado, min_id
;
-- sgm_mza indica el número de segmento dentro de cada mza independiente
------------------------------------------------------------------------

/*
select depto, frac, radio, mza, sgm_mza, count(*) 
from segmentaciones.greedy_sgm_radio
where sgm_mza > 1 -- hay al menos 2
group by depto, frac, radio, mza, sgm_mza
order by depto, frac, radio, mza, sgm_mza
limit 10
;
 depto | frac | radio | mza | sgm_mza | count 
-------+------+-------+-----+---------+-------
     8 |    1 |     8 |  89 |       2 |     4
     8 |    1 |     8 |  90 |       2 |    11
     8 |    2 |     1 | 501 |       2 |    21
     8 |    2 |     1 | 501 |       3 |    19
     8 |    2 |     1 | 501 |       4 |    18
     8 |    2 |     1 | 501 |       5 |    20
     8 |    2 |     1 | 501 |       6 |    23
     8 |    2 |     1 | 501 |       7 |    17
     8 |    2 |     1 | 501 |       8 |    22
     8 |    2 |     1 | 501 |       9 |    19
(10 rows)
*/
---- ahora un único segmento_id
---- usando depto, frac, radio, mza, sgm_mza

drop table if exists segmentaciones.greedy;
create table segmentaciones.greedy as
with segmentos_id as (
    select row_number() over (order by depto, frac, radio, mza, sgm_mza) as segmento_id, 
        depto, frac, radio, mza, sgm_mza
    from segmentaciones.greedy_sgm_radio
    group by depto, frac, radio, mza, sgm_mza
    )
select id as listado_id, segmento_id --, esto era para verificar
--    depto, frac, radio, mza, lado, numero, piso, apt, sgm_mza
from segmentos_id
join segmentaciones.greedy_sgm_radio
using (depto, frac, radio, mza, sgm_mza)
order by depto, frac, radio, mza, lado, id
;

/*
select segmento_id, count(*)
from segmentaciones.greedy
group by segmento_id
limit 10
;
 segmento_id | count 
-------------+-------
        1489 |     8
        4790 |    20
         273 |     3
        3936 |    21
        2574 |    17
         951 |    19
        5761 |     6
        5843 |    17
        5729 |     5
        5468 |    22
(10 rows)
*/


/*

---- algunas estadísticas
---- Distribución de longitudes de segmentos:

with conteo as (
    select segmento_id, count(*) as vivs
    from segmentaciones.greedy
    group by segmento_id
    )
select vivs, count(*)
from conteo
group by vivs
order by vivs desc
;
 vivs | count 
------+-------
   48 |     1
   47 |     1
   43 |     1
   40 |     1
   39 |     1
   38 |     1
   36 |     2
   35 |     1
   34 |     2
   33 |     3
   32 |     5
   31 |     2
   30 |     8
   29 |     6
   28 |    17
   27 |    19
   26 |    15
   25 |    24
   24 |   181
   23 |   149
   22 |   334
   21 |   673
   20 |  1431
   19 |   977
   18 |   450
   17 |   189
   16 |   156
   15 |   100
   14 |    94
   13 |    83
   12 |   104
   11 |    78
   10 |    69
    9 |    93
    8 |    87
    7 |    88
    6 |    91
    5 |    94
    4 |    89
    3 |    99
    2 |   100
    1 |    74
(42 rows)
*/






--------------------
alter table comuna11 drop column segmento_en_manzana;
alter table comuna11 add column sgm_mza_grd integer;
update comuna11 l
set sgm_mza_grd = sgm_mza 
from segmentando_greedy g
where (l.frac_comun, l.radio_comu::integer, l.mza_comuna::integer, l.clado, l.hn, case when l.hp is Null then 0 else l.hp end) = 
    (g.frac_comun, g.radio_comu, g.mza_comuna, g.clado, g.hn, case when g.hp is Null then 0 else g.hp end)
;

*/
