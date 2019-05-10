/*
título: sandbox
descripción: para jugar y haceer castillito de arena
autor: -h
fecha: 2019-04-26 Vi
*/

-- parte para funcioes sql y pgsql

with segs as (
  select frac_comun, radio_comu, mza_comuna, segmento_en_manzana_equilibrado as sgm, count(*) as vivs
  from comuna11
  group by frac_comun, radio_comu, mza_comuna, segmento_en_manzana_equilibrado
  ),
  dif_segs as 
  (select frac_comun, radio_comu, mza_comuna, array_agg(sgm), sum(vivs) as vivs
  from segs
  group by frac_comun, radio_comu, mza_comuna
  order by frac_comun, radio_comu, mza_comuna
  )
  select * from dif_segs
;
/*
 frac_comun | radio_comu | mza_comuna |          array_agg           | vivs
------------+------------+------------+------------------------------+------
          1 |          1 |          1 | {1}                          |   39
          1 |          1 |          2 | {1}                          |   32
          1 |          1 |          3 | {2,1}                        |   47
          1 |          1 |          4 | {2,1}                        |   42
          1 |          1 |          5 | {2,1}                        |   73
          1 |          1 |          7 | {1,2}                        |   77
          1 |          1 |          8 | {1}                          |   30
          1 |          1 |         11 | {1}                          |   15
          1 |          2 |         12 | {1}                          |    1
          1 |          2 |         13 | {1}                          |   33
          1 |          2 |         14 | {1}                          |   19
          1 |          2 |         16 | {1}                          |   33
          1 |          2 |         17 | {2,1}                        |   42
          1 |          2 |         18 | {1,2}                        |   46
*/


with segs as (
  select frac_comun, radio_comu, mza_comuna, segmento_en_manzana_equilibrado as sgm, count(*) as vivs
  from comuna11
  group by frac_comun, radio_comu, mza_comuna, segmento_en_manzana_equilibrado
  )
select frac_comun, radio_comu, mza_comuna, sum(vivs) as vivs
from segs
group by frac_comun, radio_comu, mza_comuna
having cardinality(array_agg(sgm)) = 1
order by frac_comun, radio_comu, mza_comuna
;

/*
 frac_comun | radio_comu | mza_comuna | vivs
------------+------------+------------+------
          1 |          1 |          1 |   39
          1 |          1 |          2 |   32
          1 |          1 |          8 |   30
          1 |          1 |         11 |   15
          1 |          2 |         12 |    1
          1 |          2 |         13 |   33
          1 |          2 |         14 |   19
          1 |          2 |         16 |   33
          1 |          2 |         30 |   34
          1 |          2 |         31 |   36
          1 |          2 |         33 |    8
          1 |          3 |          9 |   39
          1 |          3 |         10 |   30
*/

with segs as (
  select frac_comun, radio_comu, mza_comuna, segmento_en_manzana_equilibrado as sgm, count(*) as vivs
  from comuna11
  group by frac_comun, radio_comu, mza_comuna, segmento_en_manzana_equilibrado
  )
  mza_completas as (select frac_comun, radio_comu, mza_comuna, sum(vivs) as vivs
  from segs
  group by frac_comun, radio_comu, mza_comuna
  having cardinality(array_agg(sgm)) = 1
  order by frac_comun, radio_comu, mza_comuna
  )

;




