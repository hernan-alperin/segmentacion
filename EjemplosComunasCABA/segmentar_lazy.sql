/*
titulo: segmentar_lazy.sql.sql
descripción: 
segemntar de la forma mas facil posible 1 mza = 1 sgm
para testear el mapeo
autor: -h
fecha: 2019-06-04 Ma
*/

--- usando ventanas para ayudar a calcular cortes
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


select segmento_id, count(*)                    
from segmentaciones.facil
group by segmento_id 
order by segmento_id
limit 10 
; 


