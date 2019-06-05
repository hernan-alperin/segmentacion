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
*/



/* DEBUG:
with segs_x_mza as (
    select depto, frac, radio, mza, sgm_mza, count(*) as vivs
    from segmentaciones.eq_sgm_radio
    group by depto, frac, radio, mza, sgm_mza
    )
select depto, frac, radio, mza, count(*) cant_sgms, round(avg(vivs)) as promedio
from segs_x_mza
group by depto, frac, radio, mza
having count(*) = 2 and avg(vivs) < 13
;
 depto | frac | radio | mza | cant_sgms | promedio 
-------+------+-------+-----+-----------+----------
(0 rows)
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
        6114 |    20
        4790 |    21
         273 |    19
        3936 |    18
        5761 |    20
        5468 |    19
        4326 |    16
        2520 |    20
        2466 |    21
        5697 |    20
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
   50 |     1
   48 |     1
   47 |     1
   41 |     1
   40 |     1
   38 |     1
   37 |     2
   36 |     3
   35 |     3
   34 |     3
   33 |     4
   32 |     3
   31 |     3
   30 |     6
   29 |    11
   28 |    18
   27 |    40
   26 |    42
   25 |    75
   24 |   298
   23 |   342
   22 |   659
   21 |  1050
   20 |  1585
   19 |  1121
   18 |   878
   17 |   544
   16 |   347
   15 |   183
   14 |   126
   13 |    51
   12 |    42
   11 |    15
   10 |    12
    9 |     8
    8 |     5
    7 |     6
    6 |     6
    5 |     6
    4 |    13
    3 |     7
    2 |     9
    1 |    20
(43 rows)
*/

