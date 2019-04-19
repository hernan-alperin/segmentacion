/*
titulo: estadisticas.sql
descripción:
calculando el estado de la comuna11 y lso resultados de las diferenctes métodos de esegmentacion
autor: -h
fecha: 2019-04-18 Ju
*/

------- cuantos manzanas, viviendas relacion viviendas por manzana por radio
with viviendas as (
    select frac_comun, radio_comu, count(*) as vivs
    from comuna11
    group by frac_comun, radio_comu
    ),
    lista_manzanas as (
    select distinct frac_comun, radio_comu, mza_comuna
    from comuna11
    ),
    manzanas as (
    select frac_comun, radio_comu, count(*) as mzas
    from lista_manzanas
    group by frac_comun, radio_comu
    )
select frac_comun, radio_comu, mzas, vivs, round(vivs/mzas) as rel, ceil(vivs/40) as sgms
from manzanas
join viviendas
using (frac_comun, radio_comu)
order by frac_comun, radio_comu
;



                                                                      
    


