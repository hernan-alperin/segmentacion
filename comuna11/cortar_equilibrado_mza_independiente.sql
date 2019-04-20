/*
titulo: cortar_equilibrado_mza_independiente.sql
descripción:
-- separando listado por segmentos en manzanas independientes
-- donde la distribución de viviendas en cada segmento en la manzana es equilibrado
-- y rank es el orden de visita en el segmento
autor: -h
fecha: 2019-04-19 Vi
*/

-------------------------------------------------------------------
-- calcula la cantidad de viviendas por segmento que menor se aparte
-- de la catidad deseaado
-------------------------------------------------------------------
-- caso para testear

with deseado as (
    select 40::float as deseado
    ),
    casos as (
    select generate_series(1, 1000) as vivs
    ),
    posibles_segs_mza as (
    select vivs, greatest(1, floor(vivs/deseado)) as min, ceil(vivs/deseado) as max
    from casos, deseado
    ),
    mejor_diferencia as (
    select vivs, min, max, 
           case when abs(vivs/max - deseado) < abs(vivs/min - deseado) then max
           else min end as seg_x_mza
    from posibles_segs_mza, deseado
    )
select * from mejor_diferencia
;

--------------------------------------------------------------------
-- caso en comuna

drop view segmentando_equilibrado;
create or replace view segmentando_equilibrado as
with deseado as (
    select 40::float as deseado),
    casos as (
    select comunas, frac_comun, radio_comu::integer, mza_comuna::integer,
           count(*) as vivs,
           ceil(count(*)/deseado) as max,
           greatest(1, floor(count(*)/deseado)) as min
    from comuna11, deseado
    group by comunas, frac_comun, radio_comu::integer, mza_comuna::integer, deseado
    ),
    deseado_manzana as (
    select comunas, frac_comun, radio_comu::integer, mza_comuna::integer, vivs,
        case when abs(vivs/max - deseado) < abs(vivs/min - deseado) then max
        else min end as seg_x_mza
    from casos, deseado
    ),
    separados as (
    SELECT frac_comun, radio_comu::integer, mza_comuna::integer, clado, hn, hp, hd, id
        row_number() OVER w as row, rank() OVER w as rank
    FROM comuna11
    WINDOW w AS (PARTITION BY comunas, frac_comun, radio_comu::integer, mza_comuna::integer
    ORDER BY comunas, frac_comun, radio_comu::integer, mza_comuna::integer, clado, id)
    ),
    sumados as (
    select frac_comun, radio_comu::integer, mza_comuna::integer, count(*) as cant
    from comuna11
    group by comunas, frac_comun, radio_comu::integer, mza_comuna::integer
    )
select frac_comun, radio_comu, mza_comuna, clado, hn, hp, hd,
    floor((rank - 1)*seg_x_mza/vivs) + 1 as segmento, rank
from deseado_manzana
join separados
using(frac_comun, radio_comu, mza_comuna)
left join sumados
using(frac_comun, radio_comu, mza_comuna)
order by frac_comun, radio_comu::integer, mza_comuna::integer, clado,
    floor((rank - 1)*seg_x_mza/vivs) + 1, rank
;
