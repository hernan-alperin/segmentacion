/*
titulo: costo_segmento.sql
descripción: calcula el costo de un segmento
como la distancia absoluta de la cantidad de viviendas
al valor deseado 
autor: -h
fecha: 2019-05-01 Mi
*/

-- asignar segmento a manzanas completas
-- 1 segmento = 1 manzana


/*

solución inicial de la segmentación

*/

with s as (
    select frac_comun, radio_comu, mza_comuna, rank()
        over (
        partition by frac_comun, radio_comu 
        order by mza_comuna) as sgm_id
    from comuna11
    group by frac_comun, radio_comu, mza_comuna)
update comuna11 l
set sgm = sgm_id
from s
where l.frac_comun = s.frac_comun
and l.radio_comu = s.radio_comu
and l.mza_comuna = s.mza_comuna
; 


/*
select frac_comun, radio_comu, mza_comuna, sgm
from comuna11
order by frac_comun, radio_comu, mza_comuna
;
*/


alter table comuna11 add column sgm integer;
 

drop function costo_segmento;
create or replace function costo_segmento (
    frac integer,
    radio integer,
    segmento integer, 
    deseado integer)
returns float as $$
select abs(count(*) - $4)::float
from comuna11
where (frac_comun, radio_comu, sgm) = ($1, $2, $3)
$$
language sql
;


/*

select frac_comun::integer, radio_comu::integer, sgm, count(*),
    costo_segmento(frac_comun::integer, radio_comu::integer, sgm, 40)
from comuna11
where (frac_comun::integer, radio_comu::integer) = (1, 1)
group by frac_comun::integer, radio_comu::integer, sgm
order by frac_comun::integer, radio_comu::integer, sgm
;
 frac_comun | radio_comu | sgm | count | costo_segmento 
------------+------------+-----+-------+----------------
          1 |          1 |   1 |    39 |              1
          1 |          1 |   2 |    32 |              8
          1 |          1 |   3 |    47 |              7
          1 |          1 |   4 |    42 |              2
          1 |          1 |   5 |    73 |             33
          1 |          1 |   6 |    77 |             37
          1 |          1 |   7 |    30 |             10
          1 |          1 |   8 |    15 |             25
(8 rows)


*/

drop function costo_segmentacion;
create or replace function costo_segmentacion(
    frac integer,
    radio integer,
    deseado integer)
returns float as $$
select max(costo_segmento($1, $2, sgm, $3))
from comuna11
where (frac_comun, radio_comu) = ($1, $2)
group by frac_comun, radio_comu
$$
language sql
;
   
/*
select costo_segmentacion(1, 1, 40);
costo_segmentacion
--------------------
                 37
(1 fila)

Duración: 2592,502 ms

create index sgm_idx on comuna11 (sgm);
 costo_segmentacion
--------------------
                 37
(1 fila)

Duración: 681,010 ms
-----
     
select costo_segmentacion(frac_comun::integer, radio_comu::integer, 40)
from comuna11
                          
se cuelga...
mucho tiempo de ejecucion
;

*/
