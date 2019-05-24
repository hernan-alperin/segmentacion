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

/*
select * from adyacencias_orden_1
order by frac, radio, mza
limit 10;
 frac | radio | mza | vivs_mza |         ady_ord_1         
------+-------+-----+----------+---------------------------
    1 |     1 |  11 |       15 | {11,8}
    1 |     2 |  12 |        1 | {12,13}
    1 |     2 |  14 |       19 | {14,13,15,17}
    1 |     2 |  33 |        8 | {33,31,34}
    1 |    10 |  74 |       21 | {74,73,84}
    1 |    11 |  80 |       12 | {80,81,91}
    1 |    11 |  86 |        1 | {86,87,88}
    1 |    12 |  62 |       21 | {62,63,65}
    1 |    12 |  64 |        1 | {64,65,78}
    1 |    12 |  65 |        2 | {65,62,63,64,67,68,76,77}
*/

create or replace function costo(vivs bigint) returns float as $$
select abs($1 - 40)::float
$$
language sql
;

drop view desigualdad_triangular;
create view desigualdad_triangular as
select distinct l.frac, l.radio, 
    array[m.mza] as mza, m.vivs_mza, costo(m.vivs_mza) as costo_mza,
    array[a.mza] as ady, a.vivs_mza as vivs_ady, costo(a.vivs_mza) as costo_ady,
    array[m.mza, a.mza] as par, m.vivs_mza + a.vivs_mza as vivs_par, costo(m.vivs_mza + a.vivs_mza) as costo_par 
from adyacencias_mzas l
natural join conteos_manzanas m
join conteos_manzanas a
on m.frac = a.frac and m.radio=a.radio and l.mza_ady = a.mza
where m.vivs_mza < 35 and a.vivs_mza < 35
and costo(m.vivs_mza + a.vivs_mza) < costo(m.vivs_mza) + costo(a.vivs_mza)
order by l.frac, l.radio, array[m.mza], array[a.mza]
; 

/*
select * from desigualdad_triangular limit 10;
 frac | radio | mza  | vivs_mza | costo_mza | ady  | vivs_ady | costo_ady |   par   | vivs_par | costo_par 
------+-------+------+----------+-----------+------+----------+-----------+---------+----------+-----------
    1 |     1 | {8}  |       30 |        10 | {11} |       15 |        25 | {8,11}  |       45 |         5
    1 |     1 | {11} |       15 |        25 | {8}  |       30 |        10 | {11,8}  |       45 |         5
    1 |     2 | {12} |        1 |        39 | {13} |       33 |         7 | {12,13} |       34 |         6
    1 |     2 | {13} |       33 |         7 | {12} |        1 |        39 | {13,12} |       34 |         6
    1 |     2 | {13} |       33 |         7 | {14} |       19 |        21 | {13,14} |       52 |        12
    1 |     2 | {14} |       19 |        21 | {13} |       33 |         7 | {14,13} |       52 |        12
    1 |    12 | {62} |       21 |        19 | {65} |        2 |        38 | {62,65} |       23 |        17
    1 |    12 | {64} |        1 |        39 | {65} |        2 |        38 | {64,65} |        3 |        37
    1 |    12 | {64} |        1 |        39 | {78} |        5 |        35 | {64,78} |        6 |        34
    1 |    12 | {65} |        2 |        38 | {62} |       21 |        19 | {65,62} |       23 |        17
(10 rows)

*/

drop view conjunto_de_mzas;
create view conjunto_de_mzas as
select frac, radio, min(par) as par, 
    vivs_par as vivs,
    costo_par as costo 
from desigualdad_triangular
group by frac, radio, vivs_par, costo_par
order by frac, radio
;

/*
select * from conjunto_de_mzas limit 10;
 frac | radio |   min   | vivs | costo 
------+-------+---------+------+-------
    1 |     1 | {8,11}  |   45 |     5
    1 |     2 | {12,13} |   34 |     6
    1 |     2 | {13,14} |   52 |    12
    1 |    12 | {64,65} |    3 |    37
    1 |    12 | {64,78} |    6 |    34
    1 |    12 | {65,68} |   20 |    20
    1 |    12 | {62,65} |   23 |    17
    2 |     1 | {7,8}   |   33 |     7
    2 |     7 | {61,61} |   38 |     2
    2 |     9 | {87,96} |   31 |     9
(10 rows)

*/

create view conjuntos_a_iterar as
select frac, radio, par
from conjunto_de_mzas
where (frac, radio) in (
    select frac, radio
    from conjunto_de_mzas
    group by frac, radio
    having count(*) > 1)
;
/*
select * from conjuntos_a_iterar limit 10;
 frac | radio |    par    
------+-------+-----------
    1 |     2 | {12,13}
    1 |     2 | {13,14}
    1 |    12 | {64,65}
    1 |    12 | {64,78}
    1 |    12 | {65,68}
    1 |    12 | {62,65}
    2 |     9 | {87,96}
    2 |     9 | {87,88}
    2 |    11 | {108,109}
    2 |    11 | {109,111}
(10 rows)
*/

select frac, radio, count(*)
from conjuntos_a_iterar
group by frac, radio
having count(*) > 1
;

/*
 frac | radio | count 
------+-------+-------
    1 |     2 |     2
    1 |    12 |     4
    2 |     9 |     2
    2 |    11 |     3
    4 |     3 |     4
    4 |     4 |     2
    4 |     5 |     3
    4 |     9 |     5
    5 |     8 |     5
    5 |    10 |     2
   11 |     1 |     2
(11 rows)
*/

select count(*) as radios_de_muestra_comuna11
from (select distinct frac, radio from adyacencias_mzas) as radios
;
/*
 radios_de_muestra_comuna11 
----------------------------
                        223

se necesita iterar en 11 de 223 radios
para esta muestra representa el 5%


*/


