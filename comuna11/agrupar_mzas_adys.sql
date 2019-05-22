/*
titulo: agrupar_mzas_adys.sql
descripción
genera una tabla o vista con grupos de mzas adys
fecha: 2019-05-22 Mi
autor: -h
*/

create view adyacencias_orden_1 as 
select frac, radio, mza, vivs_mza,
    mza || array_agg(distinct mza_ady order by mza_ady) as ady_ord_1
from adyacencias_mzas
natural join conteos_manzanas
group by frac, radio, mza, vivs_mza
having vivs_mza < 30
order by frac, radio, mza
;

select distinct l.frac, l.radio, l.mza, i.vivs_mza, 
    mza_ady, j.vivs_mza as vivs_ady, i.vivs_mza + j.vivs_mza as suma 
from adyacencias_mzas l
natural join conteos_manzanas i
join conteos_manzanas j
on i.frac = j.frac and i.radio=j.radio and l.mza_ady = j.mza
where i.vivs_mza < 30
order by l.frac, l.radio, l.mza, mza_ady
; 
