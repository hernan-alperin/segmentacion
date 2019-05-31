/*
manzanas_con_pocas_viviendas
con menos de un mínimo de viviendas
para agrupar usando algoritmo de agregar manzanas

-----------

drop function manzanas_con_pocas_viviendas(frac integer, radio integer, minimo integer);
create function manzanas_con_pocas_viviendas(frac integer, radio integer, minimo integer) 
returns table (
    frac integer, radio integer, mza integer, 
    vivs integer)
as $$
select frac, radio, mza, count(*)::integer as vivs
from comuna11
where frac = $1 
and radio = $2
group by frac, radio, mza
having count(*) < $3
$$
language sql
;
*/

/*
select * from manzanas_con_pocas_viviendas(1,2,30);
 frac | radio | mza | vivs 
------+-------+-----+------
    1 |     2 |  12 |    1
    1 |     2 |  14 |   19
    1 |     2 |  33 |    8
(3 rows)
 
*/

/*
with radios as (
    select distinct frac, radio 
    from comuna11)
select manzanas_con_pocas_viviendas(frac, radio, 30)
from radios
limit 10
;

-- devuelve tuplas
-- ver como haces que devuelva las columnas
 manzanas_con_pocas_viviendas 
------------------------------
 (1,1,11,15)
 (4,8,78,15)
 (5,4,63,29)
 (5,4,66,4)
 (1,11,80,12)
 (1,11,86,1)
 (3,3,5,18)
 (3,3,6,25)
 (4,1,19,28)
 (10,8,20,3)
(10 rows)

TODO: resolver este problema de tuplas para poder usar function

*/
copy (
select frac, radio, mza, count(*) as vivs
from comuna11
group by frac, radio, mza
having count(*) < 30
order by frac, radio, mza
--limit 10
) to '/home/alpe/indec/segmentacion/comuna11/manzanas_con_pocas_viviendas.csv'
delimiter ',' csv header
;

/*
 frac | radio | mza | vivs 
------+-------+-----+------
    1 |     1 |  11 |   15
    1 |     2 |  12 |    1
    1 |     2 |  14 |   19
    1 |     2 |  33 |    8
    1 |     6 |  48 |   20
    1 |    10 |  74 |   21
    1 |    11 |  80 |   12
    1 |    11 |  86 |    1
    1 |    12 |  62 |   21
    1 |    12 |  64 |    1
(10 rows)
*/


create view manzanas_con_pocas_viviendas as
select frac, radio, mza, count(*) as vivs
from comuna11
group by frac, radio, mza
having count(*) < 30
order by frac, radio, mza
;

create view radios_con_bloques_de_manzanas_con_pocas_viviendas as
select frac, radio, sum(vivs) as vivs
from manzanas_con_pocas_viviendas
group by frac, radio
having sum(vivs) < 30
order by frac, radio
;


/*
select * from radios_con_bloques_de_manzanas_con_pocas_viviendas ;
 frac | radio | vivs 
------+-------+------
    1 |     1 |   15
    1 |     2 |   28
    1 |     6 |   20
    1 |    10 |   21
    1 |    11 |   13
    2 |     2 |   12
    2 |     8 |    7
    2 |    10 |   15
    3 |     5 |    4
    3 |     8 |   24
    3 |    10 |    2
    3 |    11 |   26
    4 |     1 |   28
    4 |     6 |   21
    4 |     8 |   15
    5 |     1 |   20
    9 |     1 |    1
    9 |     2 |   21
    9 |     3 |    3
   10 |     2 |    4
   11 |     4 |   17
   11 |     7 |   27
   12 |     3 |   25
   13 |     6 |    1
(24 rows)
*/
