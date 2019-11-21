\set shape e0595
\echo :shape
\echo :'shape'

SET SEARCH_PATH=:'shape','public';

drop table if exists lados_de_manzana;
-- tabla con los ejes unidos, lados duplicado y dirigidos por
-- mzad, ladod en sentido y mzai, ladoi en sentido contrario
-- para respetar regla hombro derecho
--
--drop table lados_de_manzana cascade;
create table lados_de_manzana
as with pedacitos_de_lado as (-- mza como PPDDDLLLFFRRMMMselect mzad as mza, ladod as lado, avg(anchomed) as anchomed,
    select mzad as mza, ladod as lado,
        array_agg(distinct tipo) as tipos,
        array_agg(distinct codigo20) as codigos,
        array_agg(distinct nombre) as calles,
        ST_Union(geom) as geom_pedacito -- ST_Union por ser MultiLineString
    from arc
    where mzad is not Null and mzad != '' and ladod != 0
    group by mzad, ladod
    union -- duplica los pedazos de lados a derecha e izquierda
    select mzai as mza, ladoi as lado,
        array_agg(distinct tipo) as tipos,
        array_agg(distinct codigo20) as codigos,
        array_agg(distinct nombre) as calles,
        ST_Union(ST_Reverse(geom)) as geom_pedacito -- invierte los de mzai
        -- para respetar sentido hombro derecho
    from arc
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

select *
from lados_de_manzana
order by id
limit 10;

/*
select prov, dpto, codloc, frac, radio, mza, lado, count( NULLIF(trim(cod_tipo_v),''))
from listado
--where radio = '3' and prov = '38' and dpto = '028' and frac = '04'
--and trim(cod_tipo_vivredef) not in ('', 'CO', 'N', 'CA/', 'LO')
group by prov, dpto, codloc, frac, radio, mza, lado
order by prov, dpto, codloc, frac, radio, mza, lado
;
*/

-------------------------------------
/*
alter table e0595.arc drop column conteoi;
alter table e0595.arc drop column conteod;
*/
alter table arc add column conteoi integer;
alter table arc add column conteod integer;
/*
create function isdigits(text) returns boolean as '
select $1 ~ ''^(-)?[0-9]+$'' as result
' language sql;
*/
update arc a
set conteoi = conteo
from
(
select mzai, ladoi, prov, depto, frac, radio, mza, lado, conteo
from segmentacion.conteos
join arc
on
  case when mzai = '' then 0 else substr(mzai, 13, 3)::integer end = mza::integer and ladoi = lado::integer
  and case when mzai = '' then 0 else substr(mzai, 11, 2)::integer end = radio::integer
  and case when mzai = '' then 0 else substr(mzai, 9, 2)::integer end = frac::integer
  and case when mzai = '' then 0 else substr(mzai, 6, 3)::integer end = codloc::integer
  and case when mzai = '' then 0 else substr(mzai, 3, 3)::integer end = depto::integer
  and case when mzai = '' then 0 else substr(mzai, 1, 2)::integer end = prov::integer
--where prov = '38' and depto = '028'
group by mzai, ladoi, mzad, ladod, prov, depto, frac, radio, mza, lado, conteo
order by prov, depto, frac, radio, mza, lado
)
as b
where a.mzai = b.mzai and a.ladoi = b.ladoi
;

update arc a
set conteod = conteo
from

(
select mzad, ladod, prov, depto, codloc, frac, radio, mza, lado, conteo
from segmentacion.conteos
join arc
on
  case when mzad = '' then 0 else substr(mzad, 13, 3)::integer end = mza::integer and ladod = lado::integer
  and case when mzad = '' then 0 else substr(mzad, 11, 2)::integer end = radio::integer
  and case when mzad = '' then 0 else substr(mzad, 9, 2)::integer end = frac::integer
  and case when mzad = '' then 0 else substr(mzad, 6, 3)::integer end = codloc::integer
  and case when mzad = '' then 0 else substr(mzad, 3, 3)::integer end = depto::integer
  and case when mzad = '' then 0 else substr(mzad, 1, 2)::integer end = prov::integer
--where prov = '38' and depto = '028'
group by mzad, ladod, prov, depto, codloc, frac, radio, mza, lado, conteo
order by prov, depto, frac, radio, mza, lado
)
as b
where a.mzad = b.mzad and a.ladod = b.ladod
;

CREATE OR REPLACE VIEW conteos_lados AS
 SELECT trim(listado.prov)::character varying(2) prov,
    (listado.dpto)::character varying(3) dpto,
    (listado.codloc)::character varying(3) codloc,
    (listado.frac)::character varying(2) frac,
    (listado.radio)::character varying(2) radio,
    (listado.mza)::character varying(4) mza,
    (listado.lado)::character varying(3) lado,
    count(NULLIF(btrim(listado.cod_tipo_v::text), ''::text)) AS vivs_lado
   FROM listado
  GROUP BY listado.prov, listado.dpto, listado.codloc, listado.frac, listado.radio, listado.mza, listado.lado;

CREATE OR REPLACE VIEW conteos_manzanas AS
 SELECT trim(listado.prov)::character varying(2) prov,
    (listado.dpto)::character varying(3) dpto,
    (listado.codloc)::character varying(3) codloc,
    (listado.frac)::character varying(2) frac,
    (listado.radio)::character varying(2) radio,
    (listado.mza)::character varying(4) mza,
    count(NULLIF(btrim(listado.cod_tipo_v::text), ''::text)) AS vivs_mza
   FROM listado
  GROUP BY listado.prov, listado.dpto, listado.codloc, listado.frac, listado.radio, listado.mza;

----
DELETE FROM segmentacion.conteos WHERE tabla='e0595.arc'::text; -- ver como generalizar e0595
INSERT INTO 
segmentacion.conteos
SELECT --row_number() OVER () gid,
'e0595.arc'::text shape, prov::integer,dpto::integer depto,codloc::integer,frac::integer,radio::integer,mza::integer,lado::integer,
vivs_lado conteo
FROM conteos_lados
GROUP BY prov,dpto,codloc,frac,radio,mza,lado,vivs_lado
;

ALTER TABLE lados_de_manzana
    ADD COLUMN prov integer DEFAULT 58;
ALTER TABLE lados_de_manzana
    ADD COLUMN tabla character varying DEFAULT 'e0595';
ALTER TABLE lados_de_manzana
    ADD COLUMN depto integer DEFAULT 63;  

ALTER TABLE lados_de_manzana
    ADD COLUMN codloc integer DEFAULT 020;    
ALTER TABLE lados_de_manzana
    ADD COLUMN ppdddlllffrrmmm character varying;
UPDATE lados_de_manzana 
    SET ppdddlllffrrmmm = '58063020'||LPAD(frac::text,2,'0'::text)||LPAD(radio::text,2,'0')||LPAD(mza::text,3,'0');

ALTER TABLE arc
    ADD COLUMN tabla character varying DEFAULT 'e0595.arc'; 
UPDATE lados_de_manzana SET tabla='e0595.arc';

                 
drop view if exists lados_adyacentes; 

---- doblar ----------------------------------------------------------
drop view if exists doblar;
create view doblar as
with max_lado as (
    select tabla, ppdddlllffrrmmm, max(lado) as max_lado
    from lados_de_manzana
    group by tabla, ppdddlllffrrmmm
    ),
    doblar as (
    select tabla, ppdddlllffrrmmm,
        lado as de_lado,
        case when lado < max_lado then lado + 1 else 1 end as lado
        -- lado el lado que dobla de la misma mza
    from max_lado
    join lados_de_manzana l
    using (tabla, ppdddlllffrrmmm)
    where lado != 0
    )
select tabla, ppdddlllffrrmmm as mza_i, de_lado as lado_i, 
    ppdddlllffrrmmm as mza_j, a.lado as lado_j, Null::text as tipo
from doblar d
join lados_de_manzana a
using(tabla, ppdddlllffrrmmm, lado)
order by ppdddlllffrrmmm, lado_i, lado_j, tabla
;


--  adyacencias entre manzanas ------------------------------------
--  para calcular los lados de cruzar y volver

drop view if exists lado_de_enfrente_para_volver;
drop view if exists lado_para_cruzar;
                 
drop view if exists manzanas_adyacentes;
create view manzanas_adyacentes as
select tabla, mzad as mza_i, mzai as mza_j, tipo
from arc
where substr(mzad,1,12) = substr(mzai,1,12) -- mismo PPDDDLLLFFRR
and mzad is not Null and mzad != '' and ladod != 0
and mzai is not Null and mzai != '' and ladod != 0
union -- hacer simétrica
select tabla, mzai, mzad, tipo
from arc
where substr(mzad,1,12) = substr(mzai,1,12) -- mismo PPDDDLLLFFRR
and mzad is not Null and mzad != '' and ladod != 0
and mzai is not Null and mzai != '' and ladod != 0
;
                     
---- volver ---------------------------------------------------------
---- fin(lado_i) = inicio(lado_j), 
---- mza_i ady mza_j, y
---- la intersección es 1 linea

drop view if exists lado_de_enfrente_para_volver;
create view lado_de_enfrente_para_volver as
select i.tabla, i.ppdddlllffrrmmm as mza_i, i.lado as lado_i,
    j.ppdddlllffrrmmm as mza_j, j.lado as lado_j, tipo
from lados_de_manzana i
join lados_de_manzana j
on i.nodo_j_geom = j.nodo_i_geom -- el lado_i termina donde el lado_j empieza
-- los lados van de nodo_i a nodo_j
and i.tabla = j.tabla
join manzanas_adyacentes a
on i.ppdddlllffrrmmm = a.mza_i and j.ppdddlllffrrmmm = a.mza_j -- las manzanas son adyacentes
and a.tabla = i.tabla
where ST_Dimension(ST_Intersection(i.lado_geom,j.lado_geom)) = 1
order by mza_i, mza_j, lado_i, lado_j
;
 

---- cruzar -----------------------------------------------------------
---- fin(lado_i) = inicio(lado_j), 
---- mza_i ady mza_j, y
---- la intersección es 1 punto

drop view if exists lado_para_cruzar;
create view lado_para_cruzar as
select i.tabla, i.ppdddlllffrrmmm as mza_i, i.lado as lado_i,
    j.ppdddlllffrrmmm as mza_j, j.lado as lado_j, tipo
from lados_de_manzana i
join lados_de_manzana j
on i.nodo_j_geom = j.nodo_i_geom 
-- el lado_i termina donde el lado_j empieza
-- los lados van de nodo_i a nodo_j
and i.tabla = j.tabla
join manzanas_adyacentes a
on i.ppdddlllffrrmmm = a.mza_i and j.ppdddlllffrrmmm = a.mza_j 
-- las manzanas son adyacentes
and a.tabla = i.tabla
where ST_Dimension(ST_Intersection(i.lado_geom,j.lado_geom)) = 0
order by mza_i, mza_j, lado_i, lado_j, tabla
;
                                   
create view lados_adyacentes as
select *, 'doblar'::text as accion from doblar
union
select *, 'volver'::text as accion from lado_de_enfrente_para_volver
union
select *, 'cruzar'::text as accion from lado_para_cruzar
;

-----------------------------------------------------------------------
-- alter table segmentacion.adyacencias add column tipo text;

delete from segmentacion.adyacencias
where shape = 'e0595.arc'
;

insert into segmentacion.adyacencias
select tabla as shape, substr(mza_i,1,2)::integer as prov, 
    substr(mza_i,3,3)::integer as depto,
    substr(mza_i,6,3)::integer as codloc,
    substr(mza_i,9,2)::integer as frac, 
    substr(mza_i,11,2)::integer as radio, 
    substr(mza_i,13,3)::integer as mza, lado_i,
    substr(mza_j,13,3)::integer as mza_ady, lado_j as lado_ady,
    tipo
from lados_adyacentes
; 

/*
select *
from segmentacion.adyacencias
where shape = 'e0595.arc'
order by prov, depto, frac, radio, mza, lado, tipo
;
*/
                                   
