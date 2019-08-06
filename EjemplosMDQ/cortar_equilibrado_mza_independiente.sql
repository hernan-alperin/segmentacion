/*
titulo: cortar_equilibrado_mza_independiente.sql
descripción:
-- separando listado por segmentos en manzanas independientes
-- donde la distribución de viviendas en cada segmento en la manzana es equilibrado
-- y rank es el orden de visita en el segmento
autor: -h
fecha: 2019-04-19 Vi
*/

-------------------------------------------------------------------
-- calcula la cantidad de viviendas por segmento que menor se aparte
-- de la catidad deseaado
-------------------------------------------------------------------
-- caso en comuna
----
-- chequear que lo qe sigue anda... minusculizar

drop view segmentando_equilibrado cascade;
create or replace view segmentando_equilibrado as
with deseado as (
    select 40::float as deseado),
    casos as (
    select frac, radio, mza,
           count(*) as vivs,
           ceil(count(*)/deseado) as max,
           greatest(1, floor(count(*)/deseado)) as min
    from listados.mdq, deseado
    group by frac, radio, mza, deseado
    ),
    deseado_manzana as (
    select frac, radio, mza, vivs,
        case when abs(vivs/max - deseado) < abs(vivs/min - deseado) then max
        else min end as seg_x_mza
    from casos, deseado
    ),
    pisos_enteros as (
        select frac, radio, mza, lado, min(id) as id_cmpnt, numero, piso
        from listados.mdq
        group by frac, radio, mza, lado, numero, piso
    ),
    pisos_abiertos as (
        select p.frac, p.radio, p.mza, p.lado, p.numero, p.piso, apt, id_cmpnt,
            row_number() over w as row, rank() over w as rank
        from pisos_enteros p
        join listados.mdq c
        on p.frac = c.frac
        and p.radio = c.radio
        and p.mza = p.mza
        and p.lado = c.lado
        and p.numero = c.numero
        and case when c.numero is Null then true
                else p.numero = c.numero
            end
        window w as (
            partition by p.frac, p.radio, p.mza
            -- separa las manzanas
            order by p.frac, p.radio, p.mza, p.lado, id_cmpnt, p.piso
            -- rankea por piso (ordena numero como corresponde pares descendiendo)
        )
    ),
    sumados as (
        select frac, radio, mza, count(*) as cant
        from listados.mdq
        group by frac, radio, mza
    )
select id_cmpnt, frac, radio, mza, lado, numero, piso, apt,
    floor((rank - 1)*seg_x_mza/vivs) + 1 as sgm_mza, rank
from deseado_manzana
join pisos_abiertos
using(frac, radio, mza)
join sumados
using(frac, radio, mza)
order by frac, radio, mza, lado, id_cmpnt, numero, piso, apt,
    floor((rank - 1)*seg_x_mza/vivs) + 1, rank
;

-- TODO ver esto
---- hay cosas raras de pisos sin departamentos piso, con apt nulo


-----
drop view segmentando_equilibrado_numerado cascade;
create view segmentando_equilibrado_numerado as
with numerando_en_radio as (
    select frac, radio, mza, sgm_mza, row_number() over w as segmento
    from segmentando_equilibrado
    group by frac, radio, mza, sgm_mza
    window w as (
        partition by frac, radio
      order by frac, radio
        )
    )
select segmentando_equilibrado.*, segmento
from segmentando_equilibrado
natural join numerando_en_radio
;
---- esto numera los segmentos dentro del radio,


copy (select * from segmentando_equilibrado_numerado)
to '/tmp/segmentando_equilibrado_numerado.csv'
delimiter ',' csv header
;

