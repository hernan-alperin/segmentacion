/*
titulo: agrupar_mzas_adys.sql
descripción
genera una tabla o vista con grupos de mzas adys
fecha: 2019-05-22 Mi
autor: -h
*/


select frac, radio, mza, vivs_mza,
    mza || array_agg(distinct mza_ady order by mza_ady) as clausura_adyacencias
from adyacencias_mzas
natural join conteos_manzanas
group by frac, radio, mza, vivs_mza
having vivs_mza < 30
order by frac, radio, mza
;

