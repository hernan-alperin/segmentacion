select distinct frac_comun as frac, radio_comu as radio, mza_comuna as mnza, face_id
from segmenta.comuna2
join caba.face
on ST_Within(st_transform(comuna2.the_geom,4326), st_transform(mbr,4326))
;
-- devuelve varios face_id, sera porque son boxes?

select distinct frac_comun as frac, radio_comu as radio, mza_comuna as mnza, id
from segmenta.comuna6
join segmenta.polygons
on ST_Within(the_geom, geom)
;

select ST_GeometryType(ST_Intersection(the_geom, geom)), count(*)
from segmenta.polygons
join segmenta.ecapia
on ST_Intersects(the_geom, geom)
where ST_GeometryType(ST_Intersection(the_geom, geom)) not ilike '%point%' 
group by ST_GeometryType(ST_Intersection(the_geom, geom))
;

-- contando lados por manzana
with cantLadosPorManzana as (
    select depto, frac, radio, mzatxt, count(*)
    from segmenta.polygons
    join segmenta.ecapia
    on ST_Intersects(the_geom, geom)
    where ST_GeometryType(ST_Intersection(the_geom, geom)) not ilike '%point%'
    group by depto, frac, radio, mzatxt)
select count as lados, count(*)
from cantLadosPorManzana
group by count
order by count
;


drop table segmenta.ejesPorManzana;
create table segmenta.ejesPorManzana as
select distinct depto, frac, radio, mzatxt, ecapia.gid as ecapia_gid
from segmenta.polygons
join segmenta.ecapia
on ST_Intersects(the_geom, geom)
where ST_GeometryType(ST_Intersection(the_geom, geom)) not ilike '%point%'
order by depto, frac, radio, mzatxt, ecapia.gid
;


-- ver que pasa con darsena
with shared as (
    select ecapia.gid, count(*)
    from segmenta.polygons
    join segmenta.ecapia
    on ST_Intersects(the_geom, geom)
    where
    --ST_GeometryType(ST_Intersection(the_geom, geom)) not ilike '%point%' and
    depto = '001' and frac = '01' and radio = '01' and mzatxt ='1'
    or depto = '001' and frac = '01' and radio = '01' and mzatxt ='4'
    group by ecapia.gid
    )
select depto, frac, radio, mzatxt, shared.gid, ST_GeometryType(ST_Intersection(the_geom, geom))
from shared
join segmenta.ecapia
using(gid)
join segmenta.polygons
on ST_Intersects(the_geom, geom)
where count > 1
and (
    depto = '001' and frac = '01' and radio = '01' and mzatxt ='1'
    or depto = '001' and frac = '01' and radio = '01' and mzatxt ='4'
)
;

select ecapia.gid,  depto, frac, radio, mzatxt, ST_GeometryType(ST_Intersection(the_geom, geom))
from segmenta.polygons
join segmenta.ecapia
on ecapia.gid = 6386
and depto = '001' and frac = '01' and radio = '01' and mzatxt ='1'
;


with ejesDeDarsena as (
    select ecapia_gid as ejes_0010101001
    from segmenta.ejesPorManzana
    where depto = '001' and frac = '01' and radio = '01' and mzatxt ='1'
    )
select *
from segmenta.ejesPorManzana
join ejesDeDarsena
on ecapia_gid = ejes_0010101001

;


-- manzanas adjacentes
drop table segmenta.manzanasAdjacentes;
create table segmenta.manzanasAdjacentes as
select a.depto, a.frac, a.radio, a.mzatxt as mnza, b.mzatxt as neighbor, ecapi_id as ecapia_id
from segmenta.ejesPorManzana a
join segmenta.ejesPorManzana b
using (depto, frac, radio, ecapi_id)
where a.mzatxt != b.mzatxt
;

select a.depto, a.frac, a.radio, a.mzatxt as mnza, b.mzatxt as neighbor, ecapi_id as ecapia_id
from segmenta.ejesPorManzana a
join segmenta.ejesPorManzana b
using (depto, frac, radio, ecapi_id)
where a.depto = '001' and a.frac = '01' and a.radio = '01' and a.mzatxt ='1'
;




select *
from segmenta.ejesPorManzana
where ecapi_id = 6448
or depto = '001' and frac = '01' and radio = '01' and mzatxt ='1'
;




with edgesByFace as (
    select face_id, abs((ST_GetFaceEdges('caba', face_id)).edge) as edge
    from caba.face)
select a.face_id, b.face_id 
from edgesByFace a
join edgesByFace b
using (edge)
where a.face_id != b.face_id
and a.face_id != 0 and b.face_id != 0
order by a.face_id
;




