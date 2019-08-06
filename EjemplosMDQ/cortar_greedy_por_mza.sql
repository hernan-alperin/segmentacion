/*
titulo: CortarDeseadoPorManzana.sql
descripción: con circuitos definidos por manzanas indeendientes
va cortando de a $d$, cantidad deseada de viviendas por segmento sin cortar piso
autor: -h
fecha: 2019-04-18 Ju
*/

--- usando windows para ayudar a calcular cortes

-----------------------------------------------------
-- segamnatndo cortando a deseado unando rank
drop view segmentando_facil;
create or replace view segmentando_greedy as 
with deseado as (
        select 40 as deseado
    ),
    pisos_enteros as (
        select frac, radio::integer, mza::integer, lado, min(id) as min_id, numero, piso
        from listados.mdq
        group by frac, radio::integer, mza::integer, lado, numero, piso
    ),    
    pisos_abiertos as (
        select frac, radio::integer, mza::integer, lado, numero, piso, apt, min_id,
            row_number() over w as row, rank() over w as rank
        from pisos_enteros
        natural join listados.mdq
        window w as (
            partition by frac, radio::integer, mza::integer
            -- separa las manzanas
            order by frac, radio::integer, mza::integer, lado, min_id, piso
            -- rankea por piso (ordena numero como corresponde pares descendiendo)
        )
    )
select frac, radio, mza, lado, numero, piso, apt, ceil(rank/deseado) + 1 as sgm_mza
from deseado, pisos_abiertos
order by frac, radio::integer, mza::integer, lado, min_id
;
-- sgm_mza indica el número de segamnto dentro de a manza independiente
---------------------------------


---- algunas estadśticas
--- post evaluaciones
--- vivendas por segmento
select frac, radio::integer, mza::integer, sgm_mza, count(*) as cant_viv_sgm
from segmentando_greedy
group by frac, radio::integer, mza::integer, sgm_mza
order by count(*) desc, sgm_mza desc, frac, radio::integer, mza::integer
;


--------------------
alter table listados.mdq drop column segmento_en_manzana;
alter table listados.mdq add column sgm_mza_grd integer;
update listados.mdq l
set sgm_mza_grd = sgm_mza 
from segmentando_greedy g
where (l.frac, l.radio::integer, l.mza::integer, l.lado, l.numero, 
	        case when upper(l.piso) = 'PA' then 1
                when upper(l.piso) = 'PB' or l.piso = '  ' then 0
        else l.piso::integer end) = 
    (g.frac, g.radio, g.mza, g.lado, g.numero, 
	case when upper(g.piso) = 'PA' then 1
		when upper(g.piso) = 'PB' or g.piso = '  ' then 0
	else g.piso::integer end)
;


