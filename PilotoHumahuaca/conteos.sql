select mza, lado, count(CASE WHEN trim(cod_tipo_vivredef)='' THEN NULL ELSE cod_tipo_vivredef END) 
from e0359.listado 
where radio = '3' and prov = '38' and dpto = '028' and frac = '04'
--and trim(cod_tipo_vivredef) not in ('', 'CO', 'N', 'CA/', 'LO') 
group by prov, dpto, frac, radio, mza, lado
order by prov, dpto, frac, radio, mza, lado
;

-------------------------------------

alter table e0359.arc drop column conteoi;
alter table e0359.arc drop column conteod;
alter table e0359.arc add column conteoi integer;
alter table e0359.arc add column conteod integer;

create function isdigits(text) returns boolean as '
select $1 ~ ''^(-)?[0-9]+$'' as result
' language sql;

update e0359.arc a
set conteoi = conteo
from 
(
select mzai, ladoi, prov, depto, frac, radio, mza, lado, conteo
from segmentacion.conteos
join 
e0359.arc
on
  case when mzai = '' then 0 else substr(mzai, 13, 3)::integer end = mza::integer and ladoi = lado::integer
  and case when mzai = '' then 0 else substr(mzai, 11, 2)::integer end = radio::integer
  and case when mzai = '' then 0 else substr(mzai, 9, 2)::integer end = frac::integer
  and case when mzai = '' then 0 else substr(mzai, 6, 3)::integer end = codloc::integer
  and case when mzai = '' then 0 else substr(mzai, 3, 3)::integer end = depto::integer
  and case when mzai = '' then 0 else substr(mzai, 1, 2)::integer end = prov::integer
where prov = '38' and depto = '028'
group by mzai, ladoi, mzad, ladod, prov, depto, frac, radio, mza, lado, conteo
order by prov, depto, frac, radio, mza, lado
)
as b
where a.mzai = b.mzai and a.ladoi = b.ladoi

;


update e0359.arc a
set conteod = conteo
from 

(
select mzad, ladod, prov, depto, codloc, frac, radio, mza, lado, conteo
from segmentacion.conteos
join 
e0359.arc
on
  case when mzad = '' then 0 else substr(mzad, 13, 3)::integer end = mza::integer and ladod = lado::integer
  and case when mzad = '' then 0 else substr(mzad, 11, 2)::integer end = radio::integer
  and case when mzad = '' then 0 else substr(mzad, 9, 2)::integer end = frac::integer
  and case when mzad = '' then 0 else substr(mzad, 6, 3)::integer end = codloc::integer
  and case when mzad = '' then 0 else substr(mzad, 3, 3)::integer end = depto::integer
  and case when mzad = '' then 0 else substr(mzad, 1, 2)::integer end = prov::integer
where prov = '38' and depto = '028'
group by mzad, ladod, prov, depto, codloc, frac, radio, mza, lado, conteo
order by prov, depto, frac, radio, mza, lado
)
as b
where a.mzad = b.mzad and a.ladod = b.ladod

;
