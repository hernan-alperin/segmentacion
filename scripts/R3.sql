/*
nombre: R3.sql
descripción:
genera listados desciptivos de segmentos por radio -> R3
autor: -h
fecha: 2019-11-20
*/


-- datos de segmento x listado 
-- aparentemente
-- en segmentaciones.eq_sgm_radio hecho con /EjemplosMDQ/segmentar_equilibrado.sql

with desde_ids as (
  select depto, frac, radio, mza, sgm_mza, lado, min(id) as desde
  from segmentaciones.eq_sgm_radio
  group by depto, frac, radio, mza, sgm_mza, lado
  order by depto, frac, radio, mza, sgm_mza, lado
  ),
  hasta_ids as (
  select depto, frac, radio, mza, sgm_mza, lado, max(id) as hasta
  from segmentaciones.eq_sgm_radio
  group by depto, frac, radio, mza, sgm_mza, lado
  order by depto, frac, radio, mza, sgm_mza, lado
  ), 
  desde as (select depto, frac, radio, mza, sgm_mza, lado, 
  numero || ' ' || piso || '° ' || apt as desde
  from segmentaciones.eq_sgm_radio as listado
  natural join desde_ids
  where id = desde
  ),
  hasta as (select depto, frac, radio, mza, sgm_mza, lado, 
  numero || ' ' || piso || '° ' || apt as hasta
  from segmentaciones.eq_sgm_radio as listado
  natural join hasta_ids
  where id = hasta
  )
select *
from desde
natural join hasta
order by depto, frac, radio, mza, sgm_mza, lado
;

