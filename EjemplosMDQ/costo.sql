/*
titulo: indec.costo_segmento.sql
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
alter table listados.mdq add column sgm integer;


with s as (
    select frac, radio, mza, rank()
        over (
        partition by frac, radio 
        order by mza) as sgm_id
    from listados.mdq
    group by frac, radio, mza)
update listados.mdq l
set sgm = sgm_id
from s
where l.frac = s.frac
and l.radio = s.radio
and l.mza = s.mza
; 


/*
select frac, radio, mza, sgm
from listados.mdq
order by frac, radio, mza
;
*/


 

drop function indec.costo_segmento;
create or replace function indec.costo_segmento (
    frac integer,
    radio integer,
    segmento integer, 
    deseado integer)
returns float as $$
select abs(count(*) - $4)::float
from listados.mdq
where (frac, radio, sgm) = ($1, $2, $3)
$$
language sql
;


/*

select frac::integer, radio::integer, sgm, count(*),
    indec.costo_segmento(frac::integer, radio::integer, sgm, 40)
from listados.mdq
group by frac::integer, radio::integer, sgm
order by frac::integer, radio::integer, sgm
;
 frac | radio | sgm | count | indec.costo_segmento 
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
select max(indec.costo_segmento($1, $2, sgm, $3))
from listados.mdq
where (frac, radio) = ($1, $2)
group by frac, radio
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

create index sgm_idx on listados.mdq (sgm);
                          
 costo_segmentacion
--------------------
                 37
(1 fila)

Duración: 681,010 ms
-----
                         
se cuelga...
mucho tiempo de ejecucion
;

                          
                          
*/

create index mza_idx on listados.mdq (mza);
create index lado_idx on listados.mdq (mza, clado);
                          
                          
