from segmentacion.listados
;

----------------------

insert into segmentacion.conteos (shape, prov, depto, codloc, frac, radio, mza, lado, conteo)
select 'e0357' as shape,
prov::integer, dpto::integer as depto, codloc::integer, frac::integer, radio::integer, mza::integer, lado::integer, count(*) as conteo
from e0357d
group by prov, dpto, codloc, frac, radio, mza, lado
order by prov, dpto, codloc, frac, radio, mza, lado
;


select *
from segmentacion.conteos
where shape = 'e0357'
;

---------------------------------

delete
from segmentacion.adyacencias
where prov::integer = 06 and depto::integer = 357
;

insert into segmentacion.adyacencias (shape, prov, depto, frac, radio, mza, lado, mza_ady, lado_ady)
select 'e0357a' as shape, substr(mzai,1,2)::integer as prov, substr(mzai,3,3)::integer as depto
    , substr(mzai,9,2)::integer as frac, substr(mzai,11,2)::integer as radio
    , substr(mzai,13,3)::integer as mza, ladoi as lado, substr(mzad,13,3)::integer as mza_ady, ladod as lado_ady
from shapes."e0357a"
where substr(mzai,1,12) = substr(mzad,1,12) -- mismo radio
    and mzad != '' and mzad is not Null and mzai != '' and mzai is not Null
    -- and ladod != 0 and ladod is not Null and ladoi != 0 and ladoi is not Null
union
select 'e0357a' as shape, substr(mzad,1,2)::integer as prov, substr(mzad,3,3)::integer as depto
    , substr(mzad,9,2)::integer as frac, substr(mzad,11,2)::integer as radio
    , substr(mzad,13,3)::integer as mza, ladod as lado, substr(mzai,13,3)::integer as mza_ady, ladoi as lado_ady
from shapes."e0357a"
where substr(mzai,1,12) = substr(mzad,1,12) -- mismo radio
    and mzai != '' and mzai is not Null and mzad != '' and mzad is not Null
    -- and ladod != 0 and ladod is not Null and ladoi != 0 and ladoi is not Null
;


----------------------------------

python SegmentaManzanasLados.py e0357 06 357
python SegmentaManzanasLados_manu.py shapes.e0357a 06 357 8 12 10 1

----------------------------------
/usr/pgsql-9.5/bin/pgsql2shp -u segmentador -P rodatnemges -f shapes/e0357a censo2020 shapes."e0357a"

