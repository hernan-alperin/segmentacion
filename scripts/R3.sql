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

drop view puerto_madero.r3;
create view puerto_madero.r3 as
with segmentos_ids as (
  select *
  from segmentaciones.eq_sgm_radio
  join segmentaciones.equilibrado
  on id = listado_id
  ),
  desde_ids as (
  select depto, frac, radio, mza, segmento_id, lado, min(id) as desde_id
  from segmentos_ids
  group by depto, frac, radio, mza, segmento_id, lado
  order by depto, frac, radio, mza, segmento_id, lado
  ),
  hasta_ids as (
  select depto, frac, radio, mza, segmento_id, lado, max(id) as hasta_id
  from segmentos_ids
  group by depto, frac, radio, mza, segmento_id, lado
  order by depto, frac, radio, mza, segmento_id, lado
  ), 
  desde as (select depto, frac, radio, mza, segmento_id, lado, desde_id,
  numero || ' ' || piso || '° ' || apt as desde
  from segmentos_ids as listado
  natural join desde_ids
  where id = desde_id
  ),
  hasta as (select depto, frac, radio, mza, segmento_id, lado, hasta_id,
  numero || ' ' || piso || '° ' || apt as hasta
  from segmentos_ids as listado
  natural join hasta_ids
  where id = hasta_id
  ),
  segmentos_en_manzana as (select *
  from desde
  natural join hasta
  )
select distinct segmento_id as segmento, mza as manzana, lado, 
  callecodigo || ' - ' || callenombre || ' desde ' || desde || ' hasta ' || hasta as descripcion,
  hasta_id - desde_id + 1 as viviendas
from segmentos_en_manzana as s
join puerto_madero.listado as l
on l.fraccionnumero::integer = s.frac
and l.radionumero::integer = s.radio
and l.manzananumero::integer = s.mza
and l.ladonumero::integer = s.lado
order by segmento_id, lado
;

/*
 segmento | manzana | lado |                         descripcion                          | viviendas
----------+---------+------+--------------------------------------------------------------+-----------
        1 |      46 |    1 | 10470 - AZUCENA MAIZANI desde 395 8° 801 hasta 395 4° 408    |        40
        2 |      46 |    1 | 10470 - AZUCENA MAIZANI desde 395 3° 301 hasta 395 1° 108    |        24
        2 |      46 |    2 | 10280 - JUANA MANSO desde 1161 8° 801 hasta 1161 7° 708      |        16
        3 |      46 |    2 | 10280 - JUANA MANSO desde 1161 6° 601 hasta 1161 2° 208      |        40
        4 |      46 |    2 | 10280 - JUANA MANSO desde 1161 1° 101 hasta 1181 5° 508      |        40
        5 |      46 |    2 | 10280 - JUANA MANSO desde 1181 4° 401 hasta 1181 1° 108      |        32
        5 |      46 |    3 | 10315 - AZUCENA VILLAFLOR desde 350 8° 800a hasta 350 8° 808 |         9
        6 |      46 |    3 | 10315 - AZUCENA VILLAFLOR desde 350 7° 700a hasta 350 4° 408 |        36
        7 |      46 |    3 | 10315 - AZUCENA VILLAFLOR desde 350 3° 300a hasta 350 1° 108 |        27
        7 |      46 |    4 | 10450 - OLGA COSSETTINI desde 1190 8° 801 hasta 1190 7° 708  |        16
        8 |      46 |    4 | 10450 - OLGA COSSETTINI desde 1190 6° 601 hasta 1190 2° 208  |        40
        9 |      46 |    4 | 10450 - OLGA COSSETTINI desde 1190 1° 101 hasta 1170 5° 508  |        40
       10 |      46 |    4 | 10450 - OLGA COSSETTINI desde 1170 4° 401 hasta 1170 1° 108  |        32
       11 |      47 |    2 | 10450 - OLGA COSSETTINI desde 1135 4° A hasta 1151 1° E      |        40
       12 |      47 |    2 | 10450 - OLGA COSSETTINI desde 1171 4° A hasta 1189 1° E      |        40
(15 filas)
*/
