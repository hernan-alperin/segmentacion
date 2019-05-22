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

drop view segmentando_equilibrado cascade;
create or replace view segmentando_equilibrado as
with deseado as (
    select 40::float as deseado),
    casos as (
    select frac, radio, mza,
           count(*) as vivs,
           ceil(count(*)/deseado) as max,
           greatest(1, floor(count(*)/deseado)) as min
    from comuna11, deseado
    group by frac, radio, mza, deseado
    ),
    deseado_manzana as (
    select frac, radio, mza, vivs,
        case when abs(vivs/max - deseado) < abs(vivs/min - deseado) then max
        else min end as seg_x_mza
    from casos, deseado
    ),
    pisos_enteros as (
        select frac, radio, mza, lado, min(id) as min_id, hn, hp
        from comuna11
        group by frac, radio, mza, lado, hn, hp
    ),
    pisos_abiertos as (
        select frac, radio, mza, lado, hn, hp, hd, min_id,
            row_number() over w as row, rank() over w as rank
        from pisos_enteros
        natural join comuna11
        window w as (
            partition by frac, radio, mza
            -- separa las manzanas
            order by frac, radio, mza, lado, min_id, hp
            -- rankea por piso (ordena hn como corresponde pares descendiendo)
        )
    ),
    sumados as (
        select min(id) as id_cmpnt, 
            frac, radio, mza, count(*) as cant
        from comuna11
        group by frac, radio, mza
    )
select id_cmpnt, frac, radio, mza, lado, hn, hp, hd,
    floor((rank - 1)*seg_x_mza/vivs) + 1 as sgm_mza, rank
from deseado_manzana
join pisos_abiertos
using(frac, radio, mza)
join sumados
using(frac, radio, mza)
order by frac, radio, mza, lado, min_id, hn, hp, hd,
    floor((rank - 1)*seg_x_mza/vivs) + 1, rank
;

-- TODO ver esto
---- hay cosas raras de pisos sin departamentos hp, con hd nulo


-----
drop view segmentando_equilibrado_numerado cascade;
create view segmentando_equilibrado_numerado as
with numerando_en_radio as (
    select frac, radio, mza, sgm_mza, row_number() over w as segmento
    from segmentando_equilibrado
    group by frac, radio, mza, sgm_mza
    window w as (
        partition by frac, radio
      order by frac, radio
        )
    )
select segmentando_equilibrado.*, segmento
from segmentando_equilibrado
natural join numerando_en_radio
;
---- esto numera los segmentos dentro del radio,


copy (select * from segmentando_equilibrado_numerado)
to '/home/alpe/indec/segmentacion/comuna11/segmentando_equilibrado_numerado.csv'
delimiter ',' csv header
;

