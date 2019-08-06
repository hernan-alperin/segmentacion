alter table listados.mdq add column seg_mza_eq integer;

update listados.mdq set seg_mza_eq =
segmento_id
from segmentaciones.equilibrado
where listado_id = id
;

alter table listados.pp2_06 add column segmento integer;

update listados.pp2_06 set segmento =
seg_mza_eq
from listados.mdq
where pp2_06.id = mdq.id 
;



