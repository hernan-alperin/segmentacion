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
        select 40 as deseado
    ),
    pisos_enteros as (
        select frac_comun, radio_comu::integer, mza_comuna::integer, clado, min(id) as min_id, hn, hp
        from comuna11
        group by frac_comun, radio_comu::integer, mza_comuna::integer, clado, hn, hp
    ),    
    abriendo_pisos as (
        select frac_comun, radio_comu::integer, mza_comuna::integer, clado, hn, hp, hd,
            row_number() over w as row, rank() over w as rank
        from pisos_enteros
        natural join comuna11
        window w as (
            partition by frac_comun, radio_comu::integer, mza_comuna::integer
            -- separa las manzanas
            ORDER BY frac_comun, radio_comu::integer, mza_comuna::integer, clado, min_id, hp
            -- rankea por piso (ordena hn como corresponde pares descendiendo)
        )
    )

select * from abriendo_pisos;
---- testeando esto debería separa por pisos
    
    ,
    sumados as (
    select frac_comun, radio_comu::integer, mza_comuna::integer, count(*) as cant
    from comuna11
    group by comunas, frac_comun, radio_comu::integer, mza_comuna::integer
    )
select frac_comun, radio_comu, mza_comuna, clado, hn, hp, ceil(rank/deseado) + 1 as segmento_manzana
from deseado, separados
left join sumados
using(frac_comun, radio_comu, mza_comuna)
order by frac_comun, radio_comu::integer, mza_comuna::integer, clado, id
;

---------------------------------
