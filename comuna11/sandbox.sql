/*
título: sandbox
descripción: para jugar y haceer castillito de arena
autor: -h
fecha: 2019-04-26 Vi
*/

-- parte para funcioes sql y pgsql

with segs as (
  select frac_comun, radio_comu, mza_comuna, array_agg(segmento_en_manzana_equilibrado) as sgm, count(*) as vivs
  from comuna11
  group by frac_comun, radio_comu, mza_comuna)
  
select * from segs
;
select frac_comun, radio_comu, mza_comuna, array_agg(sgm), vivs
from segs
group by frac_comun, radio_comu, mza_comuna, vivs
having cardinality(array_agg(sgm)) = 1
order by frac_comun, radio_comu, mza_comuna
;



