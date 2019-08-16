/*
titulo: segmentar_equilibrado.sql
descripción: con circuitos definidos por manzanas independientes
segmenta en forma equilibrada sin cortar piso, balanceando la
cantidad deseada con la proporcional de viviendas por segmento 
usando la cantidad de viviendas en la manzana.
El objetivo es que los segmentos se aparten lo mínimo de la cantidad deseada
y que la carga de los censistas esté lo más balanceado
autor: -h+M
fecha: 2019-06-05 Mi
*/

create schema if not exists segmentaciones;

drop table if exists segmentaciones.eq_sgm_radio;
create table segmentaciones.eq_sgm_radio as
with deseado as (select 
-------- cantidad de viviendas por segmentos ----
    40
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
--- se usan ventanas para calcular cortes
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
;
-- sgm_mza indica el número de segmento dentro de cada mza independiente
------------------------------------------------------------------------

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

---- tabla con único segmento_id independiente del radio
---- usando la información de la tabla segmentaciones.eq_sgm_radio
---- depto, frac, radio, mza, sgm_mza

drop table if exists segmentaciones.equilibrado;
create table segmentaciones.equilibrado as
with segmentos_id as (
    select row_number() over (order by depto, frac, radio, mza, sgm_mza) as segmento_id, 
        depto, frac, radio, mza, sgm_mza
    from segmentaciones.eq_sgm_radio
    group by depto, frac, radio, mza, sgm_mza
    )
select id as listado_id, segmento_id 
from segmentos_id
join segmentaciones.eq_sgm_radio
using (depto, frac, radio, mza, sgm_mza)
order by depto, frac, radio, mza, lado, id
;
