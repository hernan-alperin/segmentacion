/*
titulo: CortarDeseadoPorManzana.sql
descripción: con circuitos definidos por manzanas indeendientes
va cortando de a $d$, cantidad deseada de viviendas por segmento sin cortar piso
autor: -h
fecha: 2019-04-18 Ju
*/

--- usando windows para ayudar a calcular cortes
drop view segmentando_facil;
create or replace view segmentando_facil as 
with deseado as (
    select 40 as deseado),
    separados as (
    SELECT frac_comun, radio_comu::integer, mza_comuna::integer, clado, hn, hp, hd, id, 
        row_number() OVER w as row, rank() OVER w as rank
    FROM comuna11
    WINDOW w AS (PARTITION BY comunas, frac_comun, radio_comu::integer, mza_comuna::integer
    ORDER BY comunas, frac_comun, radio_comu::integer, mza_comuna::integer, clado, id)
    ),
    sumados as (
    select frac_comun, radio_comu::integer, mza_comuna::integer, count(*) as cant
    from comuna11
    group by comunas, frac_comun, radio_comu::integer, mza_comuna::integer
    ),
    parejo as (
    select ceil(cant/deseado)*deseado as redondo
    from sumados, deseado
    )
select frac_comun, radio_comu, mza_comuna, clado, hn, hp, ceil(rank/deseado) + 1 as segmento_manzana
from deseado, separados
left join sumados
using(frac_comun, radio_comu, mza_comuna)
order by frac_comun, radio_comu::integer, mza_comuna::integer, clado, id
;

---------------------------------
