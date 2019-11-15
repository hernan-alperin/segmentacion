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
  )
select prov, depto, frac, radio, seg, mza, lado
from no_estan
natural join
lados_de_mzas_incompletas
natural join
lados_por_mza
order by prov, depto, frac, radio, seg, mza, lado, 
  case
  when lado::integer > max_no_esta then lado::integer - max_no_esta
  when min_no_esta > lado::integer then cant_lados - max_no_esta + lado::integer
  end

/*
  descripcion_mza as (
  select prov, depto, frac, radio, seg, 'manzana '||mza||' completa' as descripcion
  from mzas_completas
  union
  select prov, depto, frac, radio, seg,
    'manzana '||mza||' '|| replace(replace(replace(array_agg(lado)::text, '{',
      case
        when cardinality(array_agg(lado)) = 1 then 'lado '
        else 'lados ' end
                                                  ), '}',''), ',', ' ')
    as descripcion
  from listado_segmentos
  where (prov, depto, frac, radio, seg, mza) not in (
    select prov, depto, frac, radio, seg, mza
    from mzas_completas
    )
  group by prov, depto, frac, radio, seg, mza
  order by prov, depto, frac, radio, seg, descripcion
  )
select prov, depto, frac, radio, seg, string_agg(descripcion,', ') as descripcion
from descripcion_mza
group by prov, depto, frac, radio, seg
order by prov, depto, frac, radio, seg
*/
;


