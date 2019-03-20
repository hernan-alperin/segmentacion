---
y aqui dejo volviendome loco ordenando adyacentes por numero de viviendas...
no se si vale la pena o pasar eso al algoritmo de python (!)

---
Mi 2017-01-04

todo: setear srid en coberturas (22185)
/home/halpe/segmentador/ecapiarc/ecapi (chequear que el 22185 es el que corresponde!)
[halpe@leon ecapi]$ shp2pgsql -cI -s 22185 ecapipunF5 segmenta.ecapipun | psql
[halpe@leon ecapi]$ shp2pgsql -cI -s 22185 ecapipolF5 segmenta.ecapipol | psql
[halpe@leon ecapi]$ shp2pgsql -cI -s 22185 ecapilinF5 segmenta.ecapilin | psql

[halpe@leon segmentador]$ python segmentCountRange.py 41 32 40
41 32 40 None
[halpe@leon segmentador]$ python segmentCountRange.py 200 32 40
200 32 40 (5, 6)
[halpe@leon segmentador]$ python segmentCountRange.py 159 32 40
159 32 40 (4, 4)


-----
Ma 2017-01-24

diferencias en comuna 11 entre fac||radio de etiquetas ecapipun y ecapipol (F5)

conteo por lado

select comunas as depto, frac_comun as frac, radio_comu as radio, mza_comuna as manzana, clado as lado, count(*) as viviendas
from segmenta.comuna11
group by comunas, frac_comun, radio_comu, mza_comuna, clado
order by comunas, frac_comun, radio_comu, mza_comuna, clado
;

create view segmenta.comuna11_vivs_x_mnza as
select comunas as depto, frac_comun as frac, radio_comu as radio, mza_comuna as manzana, count(*) as viviendas
from segmenta.comuna11
group by comunas, frac_comun, radio_comu, mza_comuna
order by comunas, frac_comun, radio_comu, mza_comuna
;

alter table segmenta.ecapipol add column viviendas integer;
update segmenta.ecapipol
set viviendas = comuna11_vivs_x_mnza.viviendas
from segmenta.comuna11_vivs_x_mnza
where ecapipol.depto::integer = comuna11_vivs_x_mnza.depto::integer
and ecapipol.frac::integer = comuna11_vivs_x_mnza.frac::integer
and ecapipol.radio::integer = comuna11_vivs_x_mnza.radio::integer
and ecapipol.mza::integer = comuna11_vivs_x_mnza.manzana::integer
;

cargar nueva coberturas con etiquetas corregidas 
y ladoizq y ladoder en ecaplin


[halpe@leon ecapi]$ shp2pgsql -dI -s 22185 ecapipunF5 segmenta.ecapipun | psql
[halpe@leon ecapi]$ shp2pgsql -dI -s 22185 ecapilinF5 segmenta.ecapilin | psql

select comunas as depto, frac_comun as frac, radio_comu as radio, mza_comuna as manzana, clado as lado, count(*) as viviendas, mzai
from segmenta.comuna11
join segmenta.ecapilin
on comunas::integer = substr(mzai,3,3)::integer
and frac_comun::integer = substr(mzai,6,2)::integer
and radio_comu::integer = substr(mzai,8,2)::integer
and mza_comuna::integer = substr(mzai,10,3)::integer
group by comunas, frac_comun, radio_comu, mza_comuna, clado, mzai
order by comunas, frac_comun, radio_comu, mza_comuna, clado
;

create table segmenta.manzanas_lados as

...

create index ecapipun_mza_idx on segmenta.ecapipun (depto, frac, radio, mza);
create index ecapilin_mzai_idx on segmenta.ecapilin (mzai);
create index ecapilin_mzad_idx on segmenta.ecapilin (mzad);

select count(*)
from segmenta.ecapilin
join segmenta.ecapipun
on '02'||ecapipun.depto||ecapipun.frac||ecapipun.radio||ecapipun.mza = mzai
or '02'||ecapipun.depto||ecapipun.frac||ecapipun.radio||ecapipun.mza = mzad
;

select count(*) from segmenta.ecapilin;
select count(*) from segmenta.ecapipun;

select count(*) from (
    select distinct '02'||ecapipun.depto||ecapipun.frac||ecapipun.radio||ecapipun.mza
    from segmenta.ecapipun) as foo
;

select '02'||ecapipun.depto||ecapipun.frac||ecapipun.radio||ecapipun.mza as manzana_repetida, count(*)
from segmenta.ecapipun
group by '02'||ecapipun.depto||ecapipun.frac||ecapipun.radio||ecapipun.mza
having count(*) > 1
order by count(*) desc
;

hay poligonos de etiquetas con codigo de manzana repetidos
 manzana_repetida | count
------------------+-------
 020090301132     |    14
 020081207200     |    12
 020071905507     |    11
 020090401200     |    10
 020081008075     |    10
 020081008567     |    10
 020090804200     |    10
 020071904504     |     9
 020081008596     |     9
 020120104203     |     9
 020121901505     |     9
 020120101201     |     9
 020090803201     |     9

with repes as (
    select '02'||ecapipun.depto||ecapipun.frac||ecapipun.radio||ecapipun.mza as manzana_repetida, count(*)
    from segmenta.ecapipun
    group by '02'||ecapipun.depto||ecapipun.frac||ecapipun.radio||ecapipun.mza
    having count(*) > 1
    )
select sum(count)
from repes
;

drop view segmenta.ecapiejes_reales cascade;
create view segmenta.ecapiejes_reales as
select *
from segmenta.ecapilin
where ladoi != 0 and ladod != 0
;

drop view segmenta.codigos_manzanas;
create view segmenta.codigos_manzanas as
select distinct '02'||ecapipun.depto||ecapipun.frac||ecapipun.radio||ecapipun.mza as manzana
from segmenta.ecapipun
;


select count(*) from segmenta.ecapiejes_reales;
select count(*)
from segmenta.ecapiejes_reales
join segmenta.codigos_manzanas
on manzana = mzai
or manzana = mzad
;

---
2017-01-27

lados

create view segmenta.lados as
select mzai as mza, ladoi as lado
from segmenta.ecapiejes_reales
where ladoi != 0
union
select mzad, ladod
from segmenta.ecapiejes_reales
where ladod != 0
;


select count(*)
from (
    select distinct 
--gid
--ecapi_
ecapi_id
    from segmenta.ecapiejes_reales
    ) as foo
;


drop view segmenta.lados_adjacentes_v;
create view segmenta.lados_adjacentes_v as
select * from (
    select a.mzai as mza, a.ladoi as lado, v.mzad as v_mza, v.ladod as v_lado
    from segmenta.ecapiejes_reales a
    join segmenta.ecapiejes_reales v
    on v.ecapi_id = a.ecapi_id and substr(a.mzai,1,9) = substr(v.mzad,1,9)
    union
    select a.mzad as mza, a.ladod as lado, v.mzai as v_mza, v.ladoi as v_lado
    from segmenta.ecapiejes_reales a
    join segmenta.ecapiejes_reales v
    on v.ecapi_id = a.ecapi_id and substr(a.mzai,1,9) = substr(v.mzad,1,9)
    ) as adjacent_v
where lado != 0 and mza != v_mza
and substr(mza,1,9) = '020110409'
order by mza, lado
;

select * from segmenta.lados_adjacentes_v;

drop view segmenta.lados_adjacentes_d;
create view segmenta.lados_adjacentes_d as
with max_lado as (
    select mza, max(lado)
    from segmenta.lados
    where substr(mza,1,9) = '020110409'
    group by mza
    )
select mza, lado, case when lado < max then lado + 1 else 1 end as d_lado
from segmenta.lados
natural join max_lado
;

select * from segmenta.lados_adjacentes_d
order by mza;

drop view segmenta.lados_adjacentes_c cascade; 
create view segmenta.lados_adjacentes_c as
select d.mza, d.lado, v.mza as c_mza, c.d_lado as c_lado
from segmenta.lados_adjacentes_d d
join segmenta.lados_adjacentes_v v
on d_lado = v_lado
and v_mza = d.mza
join segmenta.lados_adjacentes_d c
on c.lado = v.lado
and c.mza = v.mza
order by d.mza, d.lado
;

select * from segmenta.lados_adjacentes_c
order by mza, lado
;

drop view segmenta.lados_adjacentes_dvc;
create view segmenta.lados_adjacentes_dvc as
select *
from segmenta.lados_adjacentes_d
natural full join segmenta.lados_adjacentes_v
natural full join segmenta.lados_adjacentes_c
;

select * from segmenta.lados_adjacentes_dvc
order by mza, lado
;


select mza, count(*)
from segmenta.lados_adjacentes_dvc
where v_mza is not Null
or c_mza is not Null 
group by mza
order by count(*)
;

drop view segmenta.mzas_adjacentes;
create view segmenta.mzas_adjacentes as
select mza, v_mza as mza_adj
from segmenta.lados_adjacentes_v
;

select * from segmenta.mzas_adjacentes;


create view segmenta.comuna11_vivs_x_lado as
select comunas as depto, frac_comun as frac, radio_comu as radio, mza_comuna as manzana, clado as lado, count(*) as viviendas
from segmenta.comuna11
group by comunas, frac_comun, radio_comu, mza_comuna, clado
order by comunas, frac_comun, radio_comu, mza_comuna, clado
;

select * from segmenta.comuna11_vivs_x_lado;

----
2017-01-31

copy (
    select dvc.*, viviendas
    from segmenta.comuna11_vivs_x_lado vivs
    join segmenta.lados_adjacentes_dvc dvc
    on depto::integer = substr(dvc.mza,3,3)::integer
    and frac::integer = substr(dvc.mza,6,2)::integer
    and radio::integer = substr(dvc.mza,8,2)::integer
    and manzana::integer = substr(dvc.mza,10,3)::integer
    and vivs.lado::integer = dvc.lado::integer
) to stdout With CSV header DELIMITER ','
;



----
2017-02-07

----
2017-02-08

drop view segmenta.comuna2_vivs_x_mnza;
create view segmenta.comuna2_vivs_x_mnza as
select comunas as depto, frac_comun as frac, radio_comu as radio, mza_comuna as manzana, count(*) as viviendas
from segmenta.comuna2
group by comunas, frac_comun, radio_comu, mza_comuna
order by comunas, frac_comun, radio_comu, mza_comuna
;

update segmenta.ecapipol
set viviendas = comuna2_vivs_x_mnza.viviendas
from segmenta.comuna2_vivs_x_mnza
where ecapipol.depto::integer = comuna2_vivs_x_mnza.depto::integer
and ecapipol.frac::integer = comuna2_vivs_x_mnza.frac::integer
and ecapipol.radio::integer = comuna2_vivs_x_mnza.radio::integer
and ecapipol.mza::integer = comuna2_vivs_x_mnza.manzana::integer
;

drop view segmenta.comuna6_vivs_x_mnza;
create view segmenta.comuna6_vivs_x_mnza as
select comunas as depto, frac_comun as frac, radio_comu as radio, mza_comuna as manzana, count(*) as viviendas
from segmenta.comuna6
group by comunas, frac_comun, radio_comu, mza_comuna
order by comunas, frac_comun, radio_comu, mza_comuna
;

update segmenta.ecapipol
set viviendas = comuna6_vivs_x_mnza.viviendas
from segmenta.comuna6_vivs_x_mnza
where ecapipol.depto::integer = comuna6_vivs_x_mnza.depto::integer
and ecapipol.frac::integer = comuna6_vivs_x_mnza.frac::integer
and ecapipol.radio::integer = comuna6_vivs_x_mnza.radio::integer
and ecapipol.mza::integer = comuna6_vivs_x_mnza.manzana::integer
;


halpe=# select depto,frac,radio,mza,viviendas from segmenta.ecapipol where viviendas is not Null order by depto,frac,radio,mza;
 depto | frac | radio | mza | viviendas
-------+------+-------+-----+-----------
 002   | 12   | 04    | 006 |      1051
 006   | 06   | 02    | 003 |       975
 006   | 06   | 06    | 002 |        29
 006   | 06   | 07    | 008 |        17
 006   | 06   | 09    | 011 |         1
 011   | 04   | 09    | 060 |        28
 011   | 04   | 09    | 061 |        13
 011   | 04   | 09    | 066 |         2
 011   | 04   | 09    | 067 |        16
 011   | 04   | 09    | 068 |        52
 011   | 04   | 09    | 069 |        40
 011   | 04   | 09    | 070 |        23
 011   | 04   | 09    | 079 |         4
 011   | 04   | 09    | 080 |        14
 011   | 04   | 09    | 081 |       159
 011   | 04   | 09    | 083 |        33
 011   | 04   | 09    | 084 |        58


create view segmenta.comuna2_vivs_x_lado as
select comunas as depto, frac_comun as frac, radio_comu as radio, mza_comuna as manzana, clado as lado, count(*) as viviendas
from segmenta.comuna2
group by comunas, frac_comun, radio_comu, mza_comuna, clado
order by comunas, frac_comun, radio_comu, mza_comuna, clado
;
select * from segmenta.comuna2_vivs_x_lado;

create view segmenta.comuna6_vivs_x_lado as
select comunas as depto, frac_comun as frac, radio_comu as radio, mza_comuna as manzana, clado as lado, count(*) as viviendas
from segmenta.comuna6
group by comunas, frac_comun, radio_comu, mza_comuna, clado
order by comunas, frac_comun, radio_comu, mza_comuna, clado
;
select * from segmenta.comuna6_vivs_x_lado;


-----
2017-02-17

halpe=# select distinct st_numgeometries(geom) from segmenta.ecapipun;
 st_numgeometries
------------------
                1
(1 fila)

halpe=# select distinct st_numgeometries(geom) from segmenta.ecapilin;
 st_numgeometries
------------------
                1
(1 fila)

extraer elemento de multielement
y juntar manzanas con lados

--drop index segmenta.ecapipun_mzai;
create index ecapilin_mzai on segmenta.ecapilin (mzai);
create index ecapilin_mzad on segmenta.ecapilin (mzad);
create index ecapipun_mza on segmenta.ecapipun (prov, depto, frac, radio, mza);

drop table segmenta.ecapi_lado_mza;
create table segmenta.ecapi_lado_mza as
with lado_manzana as (
    select distinct ST_CollectionHomogenize(ecapipun.geom) as punto, ST_CollectionHomogenize(ecapilin.geom) as linea
        , case when mzai = prov||depto||frac||radio||mza then mzai when mzad = prov||depto||frac||radio||mza then mzad else Null end as mza
        , case when mzai = prov||depto||frac||radio||mza then ladoi when mzad = prov||depto||frac||radio||mza then ladod else Null end as lado
    from segmenta.ecapilin
    join segmenta.ecapipun
    on (
        mzai = prov||depto||frac||radio||mza
        or 
        mzad = prov||depto||frac||radio||mza
        )
    and mzai is not Null and mzad is not Null and mza::integer != 0
)
select mza, lado_manzana.lado, ST_Union(ST_MakePolygon(ST_AddPoint(ST_AddPoint(linea,punto,-1), ST_StartPoint(linea)))), viviendas
from lado_manzana
left join segmenta.comuna11_vivs_x_lado as vivs
    on depto::integer = substr(mza,3,3)::integer
    and frac::integer = substr(mza,6,2)::integer
    and radio::integer = substr(mza,8,2)::integer
    and manzana::integer = substr(mza,10,3)::integer
    and vivs.lado::integer = lado_manzana.lado::integer 
--
where substr(mza,1,9) = '020110409'
--
group by mza, lado_manzana.lado, viviendas
;





------------------
2017-04


