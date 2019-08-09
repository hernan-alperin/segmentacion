drop table if exists lados_de_manzana;
-- tabla con los ejes unidos, lados duplicado y dirigidos por
-- mzad, ladod en sentido y mzai, ladoi en sentido contrario
-- para respetar regla hombro derecho
--
drop table lados_de_manzana cascade;
create table lados_de_manzana
as with pedacitos_de_lado as (-- mza como PPDDDLLLFFRRMMMselect mzad as mza, ladod as lado, avg(anchomed) as anchomed,
    select mzad as mza, ladod as lado,
        array_agg(distinct tipo) as tipos,
        array_agg(distinct codigo20) as codigos,
        array_agg(distinct nombre) as calles,
        ST_Union(wkb_geometry) as geom_pedacito -- ST_Union por ser MultiLineString
    from e0359.arc
    where mzad is not Null and mzad != '' and ladod != 0
    group by mzad, ladod
    union -- duplica los pedazos de lados a derecha e izquierda
    select mzai as mza, ladoi as lado,
        array_agg(distinct tipo) as tipos,
        array_agg(distinct codigo20) as codigos,
        array_agg(distinct nombre) as calles,
        ST_Union(ST_Reverse(wkb_geometry)) as geom_pedacito -- invierte los de mzai
        -- para respetar sentido hombro derecho
    from e0359.arc
    where mzai is not Null and mzai != '' and ladoi != 0
    group by mzai, ladoi, tipo, codigo20, nombre
    order by mza, lado--, tipo, codigo20, calle
    ),
    lados_orientados as (
    select mza as nomencla, 
        substr(mza,9,2)::integer as frac, substr(mza,11,2)::integer as radio, 
        substr(mza,13,3)::integer as mza, lado,
        tipos, codigos, calles,
        ST_LineMerge(ST_Union(geom_pedacito)) as lado_geom -- une por mza,lado
    from pedacitos_de_lado
    group by mza, lado, tipos, codigos, calles
    order by mza, lado
    )
select row_number() over() as id, *,
    ST_StartPoint(lado_geom) as nodo_i_geom, ST_EndPoint(lado_geom) as nodo_j_geom
from lados_orientados
order by mza, lado
;

----------------------------------------------------------------------
---- doblar
drop view if exists doblar;
create view doblar as
with max_lado as (
    select nomencla, frac, radio, mza, max(lado) as max_lado
    from lados_de_manzana
    group by nomencla, frac, radio, mza
    ),
    doblar as (
    select id as de_id, nomencla, frac, radio, mza, lado as de_lado,
        case when lado < max_lado then lado + 1 else 1 end as lado
        -- lado el lado que dobla de la misma mza
    from max_lado
    join lados_de_manzana l
    using (nomencla, frac, radio, mza)
    where lado != '0'
    )
select nomencla, frac, radio, mza, de_lado, a.lado as a_lado, 
    de_id, a.id as a_id
from doblar d
join lados_de_manzana a
using(nomencla, frac, radio, mza, lado)
order by frac, radio, mza, de_lado
;
                     
-----------------------------------------------------------
---- Grafo de adyacencias
drop table if exists grafo_adyacencias_lados;
create table grafo_adyacencias_lados (
lado_id integer,
lado_ady integer,
tipo_ady text
);

delete grafo_adyacencias_lados;
insert into grafo_adyacencias_lados
select de_id as lado_id, a_id as lado_ady, 'doblar'
from doblar
;

-------------------------------------------------------------------
-------------------------------------------------------------------
--  creando grafo de adyacencias entre manzanas
--  para calcular los lados de cruzar y volver
-------------------------------------------------------------------

----- adyacencias

drop view codigos_manzanas_adyacentes cascade;
create view codigos_manzanas_adyacentes as
select mzad as mza_i, mzai as mza_j
from e0359.arc
where substr(mzad,1,12) = substr(mzai,1,12) -- mismo PPDDDLLLFFRR
and mzad is not Null and mzad != '' and ladod != 0
and mzai is not Null and mzai != '' and ladod != 0
union -- hacer simétrica
select mzai, mzad
from e0359.arc
where substr(mzad,1,12) = substr(mzai,1,12) -- mismo PPDDDLLLFFRR
and mzad is not Null and mzad != '' and ladod != 0
and mzai is not Null and mzai != '' and ladod != 0
;

---------------------------------------------------
--- volver, fin(lado_i) = inicio(lado_j) y mza_i ady mza_j y la intersección es 1 linea

drop view if exists lado_de_enfrente_para_volver;
create view lado_de_enfrente_para_volver as
select i.nomencla as mza_i, i.lado as lado_i,
    j.nomencla as mza_j, j.lado as lado_j
from lados_de_manzana i
join lados_de_manzana j
on i.nodo_j_geom = j.nodo_i_geom -- el lado_i termina donde el lado_j empieza
-- los lados van de nodo_i a nodo_j
join codigos_manzanas_adyacentes a
on i.nomencla = a.mza_i and j.nomencla = a.mza_j -- las manzanas son adyacentes
where ST_Dimension(ST_Intersection(i.lado_geom,j.lado_geom)) = 1
order by mza_i, mza_j, lado_i, lado_j
;
                                   
                                   
---------------------------------------------------
--- cruzar, fin(lado_i) = inicio(lado_j) y mza_i ady mza_j y la intersección es 1 punto

drop view if exists lado_para_cruzar;
create view lado_para_cruzar as
select i.nomencla as mza_i, i.lado as lado_i,
    j.nomencla as mza_j, j.lado as lado_j
from lados_de_manzana i
join lados_de_manzana j
on i.nodo_j_geom = j.nodo_i_geom -- el lado_i termina donde el lado_j empieza
-- los lados van de nodo_i a nodo_j
join codigos_manzanas_adyacentes a
on i.nomencla = a.mza_i and j.nomencla = a.mza_j -- las manzanas son adyacentes
where ST_Dimension(ST_Intersection(i.lado_geom,j.lado_geom)) = 0
order by mza_i, mza_j, lado_i, lado_j
;
                     
                                   
                                   
insert into grafo_adyacencias_lados
select de_id as lado_id, a_id as lado_ady, 'volver'
from para_volver
;


--buscar ids de lados para_cruzar
drop view if exists para_cruzar;
create view para_cruzar as
select de.nomencla as de_nomencla, a.nomencla as a_nomencla,
    de.frac, de.radio, de.mza as de_mza, de.lado as de_lado,
    a.mza as a_mza, a.lado as a_lado,
    de.id as de_id, a.id as a_id
from lados_de_manzana de
join lado_para_cruzar
on de.nomencla = mza_i and de.lado = lado_i
join lados_de_manzana a
on a.nomencla = mza_j and a.lado = lado_j
order by de.frac, de.radio, de.mza, de.lado, a.mza, a.lado
;

                                   
--------------------------------------------

drop table adyacencias;
create table adyacencias as
select i.frac, i.radio, i.mza, i.lado, 
    j.mza as mza_ady, j.lado as lado_ady, 
    i.id as lado_id, j.id as ady_id, tipo_ady
from grafo_adyacencias_lados g
join lados_de_manzana i
on lado_id = i.id
join lados_de_manzana j
on lado_ady = j.id
order by frac, radio, mza, i.lado, j.mza, j.lado
;

                                   
----------------------------------------------
                                   
insert into segmentacion.adyacencias
select 'e0359.arc' as shape, 38 as prov, 28 as depto,
    frac, radio, mza, lado, mza_ady, lado_ady
from adyacencias
;                                   

                                   
                                   
