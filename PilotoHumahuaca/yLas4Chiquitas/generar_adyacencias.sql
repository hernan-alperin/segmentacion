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

--drop table carto.lados_de_manzana cascade;
--create table carto.lados_de_manzana as
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
    select tabla, mza as nomencla, 
        substr(mza,9,2)::integer as frac, substr(mza,11,2)::integer as radio, 
        substr(mza,13,3)::integer as mza, lado,
        tipos, codigos, calles,
        ST_LineMerge(ST_Union(geom_pedacito)) as lado_geom -- une por mza,lado
    from pedacitos_de_lado
    group by tabla, mza, lado, tipos, codigos, calles
    order by tabla, mza, lado
    )
--
insert into carto.lados_de_manzana 
--
select row_number() over() as id, *,
    ST_StartPoint(lado_geom) as nodo_i_geom, ST_EndPoint(lado_geom) as nodo_j_geom
from lados_orientados
order by mza, lado
;

                     
-
