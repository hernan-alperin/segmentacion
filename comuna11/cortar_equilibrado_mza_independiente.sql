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
/*
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
*/
--------------------------------------------------------------------
-- caso en comuna
----
-- chequear que lo qe sigue anda... minusculizar

drop view segmentando_equilibrado;
create or replace view segmentando_equilibrado as
with deseado as (
    select 40::float as deseado),
    casos as (
    select frac_comun, radio_comu::integer, mza_comuna::integer,
           count(*) as vivs,
           ceil(count(*)/deseado) as max,
           greatest(1, floor(count(*)/deseado)) as min
    from comuna11, deseado
    group by frac_comun, radio_comu::integer, mza_comuna::integer, deseado
    ),
    deseado_manzana as (
    select frac_comun, radio_comu::integer, mza_comuna::integer, vivs,
        case when abs(vivs/max - deseado) < abs(vivs/min - deseado) then max
        else min end as seg_x_mza
    from casos, deseado
    ),
    pisos_enteros as (
        select frac_comun, radio_comu::integer, mza_comuna::integer, clado, min(id) as min_id, hn, hp
        from comuna11
        group by frac_comun, radio_comu::integer, mza_comuna::integer, clado, hn, hp
    ),
    pisos_abiertos as (
        select frac_comun, radio_comu::integer, mza_comuna::integer, clado, hn, hp, hd, min_id,
            row_number() over w as row, rank() over w as rank
        from pisos_enteros
        natural join comuna11
        window w as (
            partition by frac_comun, radio_comu::integer, mza_comuna::integer
            -- separa las manzanas
            order by frac_comun, radio_comu::integer, mza_comuna::integer, clado, min_id, hp
            -- rankea por piso (ordena hn como corresponde pares descendiendo)
        )
    ),
    sumados as (
        select frac_comun, radio_comu::integer, mza_comuna::integer, count(*) as cant
        from comuna11
        group by frac_comun, radio_comu::integer, mza_comuna::integer
    )
select frac_comun, radio_comu, mza_comuna, clado, hn, hp, hd,
    floor((rank - 1)*seg_x_mza/vivs) + 1 as segmento, rank
from deseado_manzana
join pisos_abiertos
using(frac_comun, radio_comu, mza_comuna)
join sumados
using(frac_comun, radio_comu, mza_comuna)
order by frac_comun, radio_comu::integer, mza_comuna::integer, clado, min_id, hn, hp, hd,
    floor((rank - 1)*seg_x_mza/vivs) + 1, rank
;


---- hay cosas raras de pisos sin departamentos hp, con hd nulo

