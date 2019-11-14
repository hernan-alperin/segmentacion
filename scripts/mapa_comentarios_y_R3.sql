-- copy (
create or replace view e0359.descripcion as (
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
select prov, depto, frac, radio, seg, string_agg(descripcion,', ') as descripcion
from descripcion_mza
group by prov, depto, frac, radio, seg
order by prov, depto, frac, radio, seg
)
--;

--) to '/tmp/2Vero.csv' with csv header
;


---- esto es para ordenar el recorrido de los lados

drop table recorrido;
create table recorrido as 
select generate_series(1,7) as i
;

delete from recorrido
where i = 3 or i = 4 or i = 5
;

alter table recorrido add column id serial primary key;

select * from recorrido;

with primero as (
  select min(i) as primero
  from recorrido
  where i != id
  ),
  maximo as (
  select max(i) as maximo
  from recorrido
  )
select i, case
  when i != id then i - primero + 1
  else i + maximo - primero + 1
  end as orden
from recorrido, primero, maximo
order by orden
;







