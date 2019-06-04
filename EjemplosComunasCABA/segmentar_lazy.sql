/*
titulo: segmentar_lazy.sql.sql
descripción: 
segemntar de la forma mas facil posible 1 mza = 1 sgm
para testear el mapeo
autor: -h
fecha: 2019-06-04 Ma
*/

create schema if not exists segmentaciones;

--- usando ventanas para ayudar a calcular cortes
drop table if exists segmentaciones.facil;
create table segmentaciones.facil as
with segmentos_id as (
    select row_number() 
        over () segmento_id, depto, frac, radio, mza
    from listados.caba
    group by depto, frac, radio, mza
)
select id as listado_id, segmento_id
from listados.caba listado
join segmentos_id 
using(depto, frac, radio, mza)
;

/*
select segmento_id, count(*)                    
from segmentaciones.facil
group by segmento_id 
order by segmento_id
limit 10 
; 
 segmento_id | count 
-------------+-------
           1 |    66
           2 |    15
           3 |     8
           4 |   123
           5 |   221
           6 |    42
           7 |    47
           8 |    95
           9 |    26
          10 |    59
*/

/*
select listado_id, depto, frac, radio, mza, segmento_id
from listados.caba
join segmentaciones.facil
on caba.id = listado_id
limit 10
;
 listado_id | depto | frac | radio | mza | segmento_id 
------------+-------+------+-------+-----+-------------
        387 |     8 |    1 |     2 |   1 |         205
        390 |     8 |    1 |     2 |   1 |         205
        402 |     8 |    1 |     2 |   1 |         205
        411 |     8 |    1 |     2 |   1 |         205
        417 |     8 |    1 |     2 |   1 |         205
        423 |     8 |    1 |     2 |   1 |         205
        426 |     8 |    1 |     2 |   1 |         205
        429 |     8 |    1 |     2 |   2 |         695
        442 |     8 |    1 |     2 |   2 |         695
        446 |     8 |    1 |     2 |   2 |         695
(10 rows)
*/


