
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
select prov, depto, frac, radio, seg, string_agg(descripcion,', ')
from descripcion_mza
group by prov, depto, frac, radio, seg
order by prov, depto, frac, radio, seg
;

