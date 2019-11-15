/*
título: descripcion.sql
descripción: 
genera descripcion para segmentos, xej:
[halperin@arswebdev043 scripts]$ psql -h 172.26.67.239 -U halpe censo2020 -c 'select * from e0359.descripcion_segmentos limit 10'
prov | depto | frac | radio | seg |        descripcion
------+-------+------+-------+-----+-------------------------------------------------------------------------------------------------------------------------
 38   | 028   | 04   | 01    | 01  | manzana 001 completa, manzana 002 lados 03 04 01, manzana 019 completa, manzana 020 completa, manzana 021 completa
 38   | 028   | 04   | 01    | 02  | manzana 002 lado 02, manzana 003 lados 03 04, manzana 022 completa
 38   | 028   | 04   | 01    | 03  | manzana 003 lados 01 02, manzana 004 lados 03 04, manzana 006 lados 03 04
 38   | 028   | 04   | 01    | 04  | manzana 004 lados 01 02, manzana 005 lados 03 04, manzana 006 lado 01
.
.
.
autor: -h
fecha: 2019-11-15
*/


create or replace view e0359.descripcion_segmentos as (
with
  listado_segmentos as (
   select *
-----------------------------------------------------------------  
  from e0359.listado_segmentos
-----------------------------------------------------------------
  ),
  lados_por_mza as (
  select prov, depto, frac, radio, mza, count(*) as cant_lados
  from listado_segmentos
  group by prov, depto, frac, radio, mza
  ),
  mzas_en_segmentos as (
  select prov, depto, frac, radio, mza, seg, count(*) as cant_lados_en_seg
  from listado_segmentos
  group by prov, depto, frac, radio, mza, seg
  ),
  mzas_completas as (
  select *
  from mzas_en_segmentos
  natural join
  lados_por_mza
  where cant_lados = cant_lados_en_seg
  ),
  lados_de_mzas_incompletas as (
  select prov, depto, frac, radio, seg, mza, lado, lado::integer as i
  from listado_segmentos
  where (prov, depto, frac, radio, seg, mza) not in (
    select prov, depto, frac, radio, seg, mza
    from mzas_completas
    )
  ),
  serie as (
  select prov, depto, frac, radio, seg, mza, generate_series(1, cant_lados) as i
  from lados_de_mzas_incompletas
  natural join lados_por_mza
  group by prov, depto, frac, radio, seg, mza, cant_lados
  ),
  junta as (
  select *
  from lados_de_mzas_incompletas
  natural full join
  serie   
  ),
  no_estan as (
  select prov, depto, frac, radio, seg, mza,
    max(i) as max_no_esta, min(i) as min_no_esta
  from junta
  where lado is Null
  group by prov, depto, frac, radio, seg, mza, lado
  ), 
  lados_ordenados as (
  select prov, depto, frac, radio, seg, mza, lado, 
  case
  when lado::integer > max_no_esta then lado::integer - max_no_esta -- el hueco está abajo
  when min_no_esta > lado::integer then cant_lados - max_no_esta + lado::integer -- el hueco está arriba
  when min_no_esta = 1 and max_no_esta = cant_lados then lado::integer -- hay hueco a ambos lados, no empieza en 1 
  end
  as orden
  from no_estan
  natural join
  lados_de_mzas_incompletas
  natural join
  lados_por_mza
  natural join
  mzas_en_segmentos), 
  descripcion_mza as (
  select prov, depto, frac, radio, seg, 'manzana '||mza||' completa' as descripcion
  from mzas_completas
  union
  select prov, depto, frac, radio, seg,
    'manzana '||mza||' '|| replace(replace(replace(array_agg(lado order by orden)::text, '{',
      case
        when cardinality(array_agg(lado)) = 1 then 'lado '
        else 'lados ' end
                                                  ), '}',''), ',', ' ')
    as descripcion
  from lados_ordenados
  group by prov, depto, frac, radio, seg, mza
  order by prov, depto, frac, radio, seg, descripcion
  )
select prov, depto, frac, radio, seg, string_agg(descripcion,', ') as descripcion
from descripcion_mza
group by prov, depto, frac, radio, seg
order by prov, depto, frac, radio, seg
)
;


