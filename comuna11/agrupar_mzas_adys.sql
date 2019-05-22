/*
titulo: agrupar_mzas_adys.sql
descripción
genera una tabla o vista con grupos de mzas adys
fecha: 2019-05-22 Mi
autor: -h
*/


with vivs_x_mza as (
    select frac, radio, mza, count(*) as mza_vivs
    from comuna11
    group by frac, radio, mza
    )
select frac, radio, 
    mza || array_agg(distinct mza_ady order by mza_ady) as bloque,
    count(*) as grp_vivs
from adyacencias_mzas
natural join vivs_x_mza
natural join comuna11
where mza_vivs < 30
group by frac, radio, mza
order by frac, radio, mza
;

