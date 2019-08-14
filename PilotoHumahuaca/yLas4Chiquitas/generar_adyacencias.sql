drop table if exists lados_de_manzana;
-- tabla con los ejes unidos, lados duplicado y dirigidos por
-- mzad, ladod en sentido y mzai, ladoi en sentido contrario
-- para respetar regla hombro derecho
--

create schema if not exists carto;
grant usage on schema carto to segmentador;

drop view if exists carto.arcos;
create view carto.arcos as
select row_number() over () fid , * from (
select 'e3019.arc' as tabla, mzai, mzad, ladoi, ladod, tipo, codigo20, nombre, wkb_geometry from e3019.arc
union
select 'e5757.arc' as tabla, mzai, mzad, ladoi, ladod, tipo, codigo20, nombre, wkb_geometry from e5757.arc
union
select 'e5759.arc' as tabla, mzai, mzad, ladoi, ladod, tipo, codigo20, nombre, wkb_geometry from e5759.arc
union
select 'e5760.arc' as tabla, mzai, mzad, ladoi, ladod, tipo, codigo20, nombre, wkb_geometry from e5760.arc
) as identificados;
grant select on carto.arcos to segmentador;

delete from carto.lados_de_manzana
where tabla = 'e3019.arc'
or tabla = 'e5757.arc'
or tabla = 'e5759.arc'
or tabla = 'e5760.arc'
;

drop table if exists carto.lados_de_manzana cascade;
create table carto.lados_de_manzana as
--
with pedacitos_de_lado as (-- mza como PPDDDLLLFFRRMMM select mzad as mza, ladod as lado, avg(anchomed) as anchomed,
    select tabla, mzad as mza, ladod as lado,
        array_agg(distinct tipo) as tipos,
        array_agg(distinct codigo20) as codigos,
        array_agg(distinct nombre) as calles,
        ST_Union(wkb_geometry) as geom_pedacito -- ST_Union por ser MultiLineString
    from carto.arcos
    where mzad is not Null and mzad != '' and ladod != 0
    group by tabla, mzad, ladod
    union -- duplica los pedazos de lados a derecha e izquierda
    select tabla, mzai as mza, ladoi as lado,
        array_agg(distinct tipo) as tipos,
        array_agg(distinct codigo20) as codigos,
        array_agg(distinct nombre) as calles,
        ST_Union(ST_Reverse(wkb_geometry)) as geom_pedacito -- invierte los de mzai
        -- para respetar sentido hombro derecho
    from carto.arcos
    where mzai is not Null and mzai != '' and ladoi != 0
    group by tabla, mzai, ladoi
    order by mza, lado
    ),
    lados_orientados as (
    select tabla, mza as ppdddlllffrrmmm,
        substr(mza,1,2)::integer as prov, substr(mza,3,3)::integer as depto,
        substr(mza,6,3)::integer as codloc,
        substr(mza,9,2)::integer as frac, substr(mza,11,2)::integer as radio, 
        substr(mza,13,3)::integer as mza, lado,
        tipos, codigos, calles,
        ST_LineMerge(ST_Union(geom_pedacito)) as wkb_geometry -- une por mza,lado
    from pedacitos_de_lado
    group by tabla, mza, lado, tipos, codigos, calles
    order by tabla, mza, lado
    )
--
--insert into carto.lados_de_manzana 
--
select row_number() over() as id, *,
    ST_StartPoint(wkb_geometry) as nodo_i_geom, ST_EndPoint(wkb_geometry) as nodo_j_geom
from lados_orientados
order by tabla, prov, depto, codloc, frac, radio, mza, lado
;

---- conteos_por_lado_de_manzana ----------------------------------------------------------------
drop view carto.conteos_por_lado_de_manzana;
create view carto.conteos_por_lado_de_manzana as
select lados_de_manzana.id as id, tabla, ppdddlllffrrmmm,
    prov, depto, codloc, frac, radio, mza, lado, wkb_geometry,
    conteo
from segmentacion.conteos
join
carto.lados_de_manzana
using (tabla, prov, depto, codloc, frac, radio, mza, lado)
;

---- doblar ----------------------------------------------------------
drop view if exists carto.doblar;
create view carto.doblar as
with max_lado as (
    select tabla, ppdddlllffrrmmm, max(lado) as max_lado
    from carto.lados_de_manzana
    group by tabla, ppdddlllffrrmmm
    ),
    doblar as (
    select tabla, ppdddlllffrrmmm,
        lado as de_lado,
        case when lado < max_lado then lado + 1 else 1 end as lado
        -- lado el lado que dobla de la misma mza
    from max_lado
    join carto.lados_de_manzana l
    using (tabla, ppdddlllffrrmmm)
    where lado != 0
    )
select tabla, ppdddlllffrrmmm as mza_i, de_lado as lado_i, 
    ppdddlllffrrmmm as mza_j, a.lado as lado_j
from doblar d
join carto.lados_de_manzana a
using(tabla, ppdddlllffrrmmm, lado)
order by ppdddlllffrrmmm, lado_i, lado_j, tabla
;


--  adyacencias entre manzanas ------------------------------------
--  para calcular los lados de cruzar y volver

drop view if exists carto.manzanas_adyacentes cascade;
create view carto.manzanas_adyacentes as
select tabla, mzad as mza_i, mzai as mza_j
from carto.arcos
where substr(mzad,1,12) = substr(mzai,1,12) -- mismo PPDDDLLLFFRR
and mzad is not Null and mzad != '' and ladod != 0
and mzai is not Null and mzai != '' and ladod != 0
union -- hacer simétrica
select tabla, mzai, mzad
from carto.arcos
where substr(mzad,1,12) = substr(mzai,1,12) -- mismo PPDDDLLLFFRR
and mzad is not Null and mzad != '' and ladod != 0
and mzai is not Null and mzai != '' and ladod != 0
;

                     
---- volver ---------------------------------------------------------
---- fin(lado_i) = inicio(lado_j), 
---- mza_i ady mza_j, y
---- la intersección es 1 linea

drop view if exists carto.lado_de_enfrente_para_volver;
create view carto.lado_de_enfrente_para_volver as
select i.tabla, i.ppdddlllffrrmmm as mza_i, i.lado as lado_i,
    j.ppdddlllffrrmmm as mza_j, j.lado as lado_j
from carto.lados_de_manzana i
join carto.lados_de_manzana j
on i.nodo_j_geom = j.nodo_i_geom -- el lado_i termina donde el lado_j empieza
-- los lados van de nodo_i a nodo_j
and i.tabla = j.tabla
join carto.manzanas_adyacentes a
on i.ppdddlllffrrmmm = a.mza_i and j.ppdddlllffrrmmm = a.mza_j -- las manzanas son adyacentes
and a.tabla = i.tabla
where ST_Dimension(ST_Intersection(i.wkb_geometry,j.wkb_geometry)) = 1
order by mza_i, mza_j, lado_i, lado_j
;
 

---- cruzar -----------------------------------------------------------
---- fin(lado_i) = inicio(lado_j), 
---- mza_i ady mza_j, y
---- la intersección es 1 punto

drop view if exists carto.lado_para_cruzar;
create view carto.lado_para_cruzar as
select i.tabla, i.ppdddlllffrrmmm as mza_i, i.lado as lado_i,
    j.ppdddlllffrrmmm as mza_j, j.lado as lado_j
from carto.lados_de_manzana i
join carto.lados_de_manzana j
on i.nodo_j_geom = j.nodo_i_geom 
-- el lado_i termina donde el lado_j empieza
-- los lados van de nodo_i a nodo_j
and i.tabla = j.tabla
join carto.manzanas_adyacentes a
on i.ppdddlllffrrmmm = a.mza_i and j.ppdddlllffrrmmm = a.mza_j 
-- las manzanas son adyacentes
and a.tabla = i.tabla
where ST_Dimension(ST_Intersection(i.wkb_geometry,j.wkb_geometry)) = 0
order by mza_i, mza_j, lado_i, lado_j, tabla
;
                                   
create view carto.lados_adyacentes as
select *, 'doblar'::text as accion from carto.doblar
union
select *, 'volver'::text as accion from carto.lado_de_enfrente_para_volver
union
select *, 'cruzar'::text as accion from carto.lado_para_cruzar
;

-----------------------------------------------------------------------
insert into segmentacion.adyacencias
select tabla as shape, substr(mza_i,1,2)::integer as prov, 
    substr(mza_i,3,3)::integer as depto,
    substr(mza_i,6,3)::integer as codloc,
    substr(mza_i,9,2)::integer as frac, 
    substr(mza_i,11,2)::integer as radio, 
    substr(mza_i,13,3)::integer as mza, lado_i,
    substr(mza_j,13,3)::integer as mza_ady, lado_j as lado_ady
from carto.lados_adyacentes
;                      
