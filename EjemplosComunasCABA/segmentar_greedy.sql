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
---- ahora hay que armar un único segmento_id
--- con depto, frac, radio, mza, sgm_mza

with segmentos_id as (
    select row_number() over (order by depto, frac, radio, mza, sgm_mza) as segmento_id, 
        depto, frac, radio, mza, sgm_mza
    from segmentaciones.greedy_sgm_radio
    group by depto, frac, radio, mza, sgm_mza
    )
select id as listado_id, segmento_id,
    depto, frac, radio, mza, lado, numero, piso, apt, sgm_mza
from segmentos_id
join segmentaciones.greedy_sgm_radio
using (depto, frac, radio, mza, sgm_mza)
order by depto, frac, radio, mza, lado, id
;
---------- parece que anda...


/*

---- algunas estadśticas
--- post evaluaciones
--- vivendas por segmento
select frac_comun, radio_comu::integer, mza_comuna::integer, sgm_mza, count(*) as cant_viv_sgm
from segmentando_greedy
group by frac_comun, radio_comu::integer, mza_comuna::integer, sgm_mza
order by count(*) desc, sgm_mza desc, frac_comun, radio_comu::integer, mza_comuna::integer
;


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
