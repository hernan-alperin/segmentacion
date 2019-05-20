/*
manzanas_con_pocas_viviendas
con menos de un mínimo de viviendas
para agrupar usando algori
*/
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

*/


