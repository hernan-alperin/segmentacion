/*
titulo: segmentar_equilibradosql
descripción: con circuitos definidos por manzanas independientes
va segemnta en forma equilibrada sin cortar piso, balanceando la
cantidad deseada de viviendas por segmento 
y la cantidad de viviendas en la manzana
para que los segmentos se aparten lo mínimo de la cantidad deseada
autor: -h
fecha: 2019-06-05 Mi
*/

--- usando ventanas para ayudar a calcular cortes

create schema if not exists segmentaciones;

drop table if exists segmentaciones.eq_sgm_radio;
create table segmentaciones.eq_sgm_radio as
with deseado as (select 
-------- cantidad de viviendas por segmentos ----
    20
-------------------------------------------------
    ::float as deseado),
    casos as (
    select depto, frac, radio, mza,
           count(*) as vivs,
           ceil(count(*)/deseado) as max,
           greatest(1, floor(count(*)/deseado)) as min
    from listados.caba, deseado
    group by depto, frac, radio, mza, deseado
    ),
    deseado_manzana as (
    select depto, frac, radio, mza, vivs,
        case when abs(vivs/max - deseado) < abs(vivs/min - deseado) then max
        else min end as segs_x_mza
    from casos, deseado
    ),
    pisos_enteros as (
        select depto, frac, radio, mza, lado, numero, piso, min(id) as min_id
        from listados.caba
        group by depto, frac, radio, mza, lado, numero, piso
        order by depto, frac, radio, mza, lado, numero, min_id
    ),    
    pisos_abiertos as (
        select id, depto, frac, radio, mza, lado, numero, piso, apt, min_id,
            row_number() over w as row, rank() over w as rank
        from pisos_enteros
        natural join listados.caba
        window w as (
            partition by depto, frac, radio, mza
            -- separa las manzanas
            order by depto, frac, radio, mza, lado, min_id
            -- rankea por min_id (como corresponde pares y pisos descendiendo)
        )
    )
select id, depto, frac, radio, mza, lado, numero, piso, apt, 
    floor((rank - 1)*segs_x_mza/vivs) + 1 as sgm_mza, rank
from deseado_manzana
join pisos_abiertos
using (depto, frac, radio, mza)
---join casos
---using (depto, frac, radio, mza)
--order by depto, frac, radio, mza, lado, min_id
;
-- sgm_mza indica el número de segmento dentro de cada mza independiente
------------------------------------------------------------------------

/*
with segs_x_mza as (
    select depto, frac, radio, mza, sgm_mza, count(*) 
    from segmentaciones.eq_sgm_radio
    group by depto, frac, radio, mza, sgm_mza
    )
select depto, frac, radio, mza, count(*) cant_sgms, round(avg(count)) as promedio
from segs_x_mza
group by depto, frac, radio, mza
having count(*) > 1
order by random()
limit 10
;
 depto | frac | radio | mza | cant_sgms | promedio 
-------+------+-------+-----+-----------+----------
    11 |   10 |     2 |   4 |         8 |       19
    15 |    4 |     1 |   2 |         3 |       17
    11 |    9 |     9 |  33 |        14 |       20
    15 |    3 |     6 |  34 |         2 |       16
    11 |    3 |     2 |   9 |         5 |       18
    11 |   11 |     7 |  51 |         4 |       16
    15 |    3 |    13 |   6 |         4 |       19
    11 |    3 |     5 |  38 |         8 |       20
    15 |    5 |     7 |  24 |         3 |       18
     8 |    4 |     4 |   8 |         2 |       11
(10 rows)

*/
---- ahora un único segmento_id
---- usando depto, frac, radio, mza, sgm_mza

drop table if exists segmentaciones.equilibrado;
create table segmentaciones.equilibrado as
with segmentos_id as (
    select row_number() over (order by depto, frac, radio, mza, sgm_mza) as segmento_id, 
        depto, frac, radio, mza, sgm_mza
    from segmentaciones.eq_sgm_radio
    group by depto, frac, radio, mza, sgm_mza
    )
select id as listado_id, segmento_id --, esto era para verificar
--    depto, frac, radio, mza, lado, numero, piso, apt, sgm_mza
from segmentos_id
join segmentaciones.eq_sgm_radio
using (depto, frac, radio, mza, sgm_mza)
order by depto, frac, radio, mza, lado, id
;

/*
select segmento_id, count(*)
from segmentaciones.equilibrado
group by segmento_id
limit 10
;
 segmento_id | count 
-------------+-------
        1489 |     8
        4790 |    20
         273 |     3
        3936 |    21
        2574 |    17
         951 |    19
        5761 |     6
        5843 |    17
        5729 |     5
        5468 |    22
(10 rows)
*/


/*

---- algunas estadísticas
---- Distribución de longitudes de segmentos:

with conteo as (
    select segmento_id, count(*) as vivs
    from segmentaciones.equilibrado
    group by segmento_id
    )
select vivs, count(*)
from conteo
group by vivs
order by vivs desc
;
 vivs | count 
------+-------
   48 |     1
   47 |     1
   43 |     1
   40 |     1
   39 |     1
   38 |     1
   36 |     2
   35 |     1
   34 |     2
   33 |     3
   32 |     5
   31 |     2
   30 |     8
   29 |     6
   28 |    17
   27 |    19
   26 |    15
   25 |    24
   24 |   181
   23 |   149
   22 |   334
   21 |   673
   20 |  1431
   19 |   977
   18 |   450
   17 |   189
   16 |   156
   15 |   100
   14 |    94
   13 |    83
   12 |   104
   11 |    78
   10 |    69
    9 |    93
    8 |    87
    7 |    88
    6 |    91
    5 |    94
    4 |    89
    3 |    99
    2 |   100
    1 |    74
(42 rows)
*/

