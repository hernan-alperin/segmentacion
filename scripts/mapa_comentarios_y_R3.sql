
with 
  lados_por_mza as (
  select prov, depto, frac, radio, mza, count(*) as cant_lados
  from e0359.listado_segmentos
  group by prov, depto, frac, radio, mza
  ),
  mzas_en_segmentos as (
  select prov, depto, frac, radio, mza, seg, count(*) as cant_lados_en_seg
  from e0359.listado_segmentos
  group by prov, depto, frac, radio, mza, seg
  ),
  mzas_completas as (
  select * 
  from mzas_en_segmentos
  natural join 
  lados_por_mza
  where cant_lados = cant_lados_en_seg
  )
select prov, depto, frac, radio, seg, mza, 'manzana completa' as lado
from mzas_completas
union
select prov, depto, frac, radio, seg, mza, lado
from e0359.listado_segmentos
where (prov, depto, frac, radio, seg, mza) not in (
  select prov, depto, frac, radio, seg, mza from mzas_completas
)
order by prov, depto, frac, radio, seg, mza, lado
;

