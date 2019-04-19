/*
titulo: CortarDeseadoPorManzana.sql
descripción: con circuitos definidos por manzanas indeendientes
va cortando de a $d$, cantidad deseada de viviendas por segmento sin cortar piso
autor: -h
fecha: 2019-04-18 Ju
*/

--- usando windows para ayudar a calcular cortes

-----------------------------------------------------
-- segamnatndo cortando a deseado unando rank
drop view segmentando_facil;
create or replace view segmentando_greedy as 
with deseado as (
        select 40 as deseado
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
            ORDER BY frac_comun, radio_comu::integer, mza_comuna::integer, clado, min_id, hp
            -- rankea por piso (ordena hn como corresponde pares descendiendo)
        )
    )
select frac_comun, radio_comu, mza_comuna, clado, hn, hp, hd, ceil(rank/deseado) + 1 as sgm_mza
from deseado, pisos_abiertos
order by frac_comun, radio_comu::integer, mza_comuna::integer, clado, min_id
;
-- sgm_mza indica el número de segamnto dentro de a manza independiente
---------------------------------



select frac_comun, radio_comu::integer, mza_comuna::integer, sgm_mza, count(*) as cant_viv_sgm
from segmentando_greedy
group by frac_comun, radio_comu::integer, mza_comuna::integer, sgm_mza
order by frac_comun, radio_comu::integer, mza_comuna::integer, sgm_mza
;




