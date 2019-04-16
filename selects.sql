--- usando windows para ayudar a calcular cortes
drop view segmentando_facil;
create or replace view segmentando_facil as 
with deseado as (
    select 40 as deseado),
    separados as (
    SELECT frac_comun, radio_comu::integer, mza_comuna::integer, clado, hn, hp, hd, id, 
        row_number() OVER w as row, rank() OVER w as rank
    FROM comuna11
    WINDOW w AS (PARTITION BY comunas, frac_comun, radio_comu::integer, mza_comuna::integer
    ORDER BY comunas, frac_comun, radio_comu::integer, mza_comuna::integer, clado, id)
    ),
    sumados as (
    select frac_comun, radio_comu::integer, mza_comuna::integer, count(*) as cant
    from comuna11
    group by comunas, frac_comun, radio_comu::integer, mza_comuna::integer
    ),
    parejo as (
    select ceil(cant/deseado)*deseado as redondo
    from sumados, deseado
    )
select frac_comun, radio_comu, mza_comuna, clado, hn, hp, ceil(rank/deseado) + 1 as segmento_manzana
from deseado, separados
left join sumados
using(frac_comun, radio_comu, mza_comuna)
order by frac_comun, radio_comu::integer, mza_comuna::integer, clado, id
;

---------------------------------

alter table comuna11 add column segmento_en_manzana integer;
update comuna11 l
set segmento_en_manzana = segmento_manzana
from segmentando_facil f
where (l.frac_comun, l.radio_comu::integer, l.mza_comuna::integer, l.clado, l.hn, case when l.hp is Null then 0 else l.hp end) = 
    (f.frac_comun, f.radio_comu, f.mza_comuna, f.clado, f.hn, case when f.hp is Null then 0 else f.hp end)
;

-----------------------------------------------------


select frac_comun, radio_comu, mza_comuna, clado, hn, hp, segmento_en_manzana 
from comuna11
order by frac_comun, radio_comu, mza_comuna, clado, id
;


