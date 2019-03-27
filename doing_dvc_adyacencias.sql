-- título: doing_dvc_adyacencias.sql
-- descripción:
--
-- Se hace ahora con consultas sql
-- y Armando un Grafo G(v,e,t)
-- donde 
-- v representan a lados de manzana
-- e = (v_i, v_j)
-- t el tipo de acción del censista {doblar, volver, cruzar}
-- 
-- table grafo_adyacencias_lados
--
-- trabaja sobre el ejemplo de la comuna11
-- todo: generalizar a otros deptos
--
-- autor: -h
-- fecha creación: 2019-03-25 Ma

/*
la tabla lineas contiene los ejes del shape e0211lin enviado por mail por Manu
mar 19/3, 10:38
*/

drop table if exists calles;
select distinct ST_Geometrytype(geom) from lineas;

create table ejes_de_calle as
select fnode_ as vertice_i, tnode_ as vertice_j,
    ST_StartPoint(geom_eje) as geom_i, ST_EndPoint(geom_eje) as geom_j,
    geom_eje
from lineas
;
CREATE INDEX lado_start_idx ON ejes_de_calle USING GIST (geom_i);
CREATE INDEX lado_end_idx ON ejes_de_calle USING GIST (geom_j);

select vertice_i, vertice_j, ST_AsText(geom_i), ST_AsText(geom_j), ST_AsText(geom_eje)
from ejes_de_calle;
/*
 vertice_i | vertice_j |         st_astext          |         st_astext          |                                                                                st_astext
-----------+-----------+----------------------------+----------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      3800 |      3697 | POINT(5636287 6172526)     | POINT(5636228.5 6172606.5) | LINESTRING(5636287 6172526,5636228.5 6172606.5)
      3813 |      3680 | POINT(5636483.5 6172515.5) | POINT(5636410.5 6172615.5) | LINESTRING(5636483.5 6172515.5,5636410.5 6172615.5)
      3800 |      3929 | POINT(5636287 6172526)     | POINT(5636156.5 6172437.5) | LINESTRING(5636287 6172526,5636156.5 6172437.5)
      3697 |      3929 | POINT(5636228.5 6172606.5) | POINT(5636156.5 6172437.5) | LINESTRING(5636228.5 6172606.5,5636221.5 6172597,5636156.5 6172437.5)
      3614 |      3929 | POINT(5636209 6172675)     | POINT(5636156.5 6172437.5) | LINESTRING(5636209 6172675,5636209.5 6172647,5636204 6172625.5,5636189 6172576,5636164.5 6172498. 5,5636157 6172463,5636156.5 6172437.5)
      3933 |      3813 | POINT(5636542 6172434)     | POINT(5636483.5 6172515.5) | LINESTRING(5636542 6172434,5636493 6172502,5636483.5 6172515.5)
      3813 |      3945 | POINT(5636483.5 6172515.5) | POINT(5636359 6172425.5)   | LINESTRING(5636483.5 6172515.5,5636359 6172425.5)
      3945 |      3800 | POINT(5636359 6172425.5)   | POINT(5636287 6172526)     | LINESTRING(5636359 6172425.5,5636349 6172440,5636287 6172526)
      3655 |      4011 | POINT(5636171.5 6172637)   | POINT(5636044 6172385.5)   | LINESTRING(5636171.5 6172637,5636162 6172620,5636133.5 6172574,5636112.5 6172540,5636097 6172508. 5,5636077 6172465,5636058.5 6172420,5636044 6172385.5)       4020 |      3655 | POINT(5636067 6172377.5)   | POINT(5636171.5 6172637)   | LINESTRING(5636067 6172377.5,5636089 6172432.5,5636156 6172599,5636171.5 6172637)
...
*/

-- armando los lados para cada manzana

drop table if exists cuadras;
create table cuadras
as with lados_de_manzana as (-- mza como PPDDDLLLFFRRMMMselect mzad as mza, ladod as lado, avg(anchomed) as anchomed,
    select mzad as mza, ladod as lado, avg(anchomed) as anchomed,
        tipo, codigo, nombre as calle,
        min(desded) as desde, max(hastad) as hasta,
        ST_LineMerge(ST_Union(geom)) as geom_lado -- ST_Union por ser MultiLineString
    from lineas
    where mzad is not Null and mzad != '' and ladod != 0
    and substr(mzad,1,8) = '02077010' -- en la comuna
    group by mzad, ladod, tipo, codigo, nombre
    union
    select mzai as mza, ladoi as lado, avg(anchomed) as anchomed,
        tipo, codigo, nombre as calle,
        max(hastai) as desde, min(desdei) as hasta,
        ST_LineMerge(ST_Union(ST_Reverse(geom))) as geom_lado
    from lineas
    where mzai is not Null and mzai != '' and ladoi != 0
    and substr(mzai,1,8) = '02077010'
    group by mzai, ladoi, tipo, codigo, nombre
    order by mza, lado--, tipo, codigo, calle
    )
select * from lados_de_manzana
;

select mza, lado
from cuadras
;

/*
       mza       | lado
-----------------+------
 020770100101001 |    1
 020770100101001 |    2
 020770100101001 |    3
 020770100101002 |    1
 020770100101002 |    2
 020770100101002 |    3
 020770100101003 |    1
 020770100101003 |    2
 020770100101003 |    3
 020770100101003 |    4
*/

-- ver si hay cuadras cortadas
select ST_GeometryType(geom_lado), count(*)
from cuadras
group by ST_GeometryType(geom_lado)
;
/*
  st_geometrytype   | count
--------------------+-------
 ST_LineString      |  4831
 ST_MultiLineString |     3
(2 filas)
*/
                              
-- ver cuáles son 
select mza, lado, tipo, codigo, calle, desde, hasta
from cuadras
where ST_GeometryType(geom_lado) = 'ST_MultiLineString'
;

/*
       mza       | lado | tipo  | codigo |      calle      | desde | hasta
-----------------+------+-------+--------+-----------------+-------+-------
 020770100103028 |    3 | AV    |   4005 | AV JOSE FAGNANO |     0 |  3599
 020770100111091 |    4 | CALLE |   4880 | GUTENBERG       |     0 |     0
 020770101301005 |    3 | AV    |   6915 | AV NAZCA        |     0 |  3093
(3 filas)
*/

-- poníendole los puntos geográfico de inicio y fin a las cuadras
drop table lados_manzanas;
create table lados_manzanas as
select substr(mza,9,2)::integer as frac, substr(mza,11,2)::integer as radio,
    substr(mza,13,3)::integer as mza, lado, codigo, calle, desde, hasta,
    ST_StartPoint(geom_lado) as geom_i, ST_EndPoint(geom_lado) as geom_j
from cuadras
-- ver qué hacer con estos...
where ST_GeometryType(geom_lado) != 'ST_MultiLineString'
--
order by substr(mza,9,2)::integer, substr(mza,11,2)::integer, substr(mza,13,3)::integer, lado
;

CREATE INDEX cuadra_start_idx ON lados_manzanas USING GIST (geom_i);
CREATE INDEX cuadra_end_idx ON lados_manzanas USING GIST (geom_j);

---- Creación de los lados (vertices del Grafo de Adyacencias, bifurcaciones de recorridos)
\timing
drop table if exists lados_info;
create table lados_info as
select row_number() over () as id, frac, radio, mza, lado,
    codigo, calle, desde, hasta, vertice_i, vertice_j
from ejes_de_calle c
join lados_manzanas l
on c.geom_i = l.geom_i and c.geom_j = l.geom_j
or c.geom_i = l.geom_j and c.geom_j = l.geom_i
order by frac, radio, mza, lado, calle
;

select * from lados_info;
/*
  id  | frac | radio | mza | lado | codigo |             calle             | desde | hasta | vertice_i | vertice_j
------+------+-------+-----+------+--------+-------------------------------+-------+-------+-----------+-----------
    1 |    1 |     1 |   1 |    1 |   1805 | CAMPANA                       |  5700 |  5602 |      3586 |      3478
    2 |    1 |     1 |   1 |    2 |   5670 | LARSEN                        |  3301 |  3399 |      3586 |      3697
    3 |    1 |     1 |   1 |    3 |   7430 | AV GRL PAZ                    |  5900 |  5792 |      3478 |      3697
    4 |    1 |     1 |   2 |    1 |   5930 | LLAVALLOL                     |  5600 |  5502 |      3800 |      3697
    5 |    1 |     1 |   2 |    2 |   2375 | COCHRANE                      |  3401 |  3499 |      3800 |      3929
    6 |    1 |     1 |   2 |    3 |   7430 | AV GRL PAZ                    |  6000 |  5902 |      3697 |      3929
    7 |    1 |     1 |   3 |    1 |   1805 | CAMPANA                       |  5600 |  5502 |      3680 |      3586
    8 |    1 |     1 |   3 |    2 |   2375 | COCHRANE                      |  3301 |  3399 |      3680 |      3800
...
*/

-----------------------------------------------------------
---- Grafo de adyacencias

create table grafo_adyacencias_lados (
lado_id integer,
lado_ady integer,
tipo_ady text
);

create view doblar as
with max_lado as (
    select frac, radio, mza, max(lado)
    from lados_info
    group by frac, radio, mza
    ),
    doblar as (
    select id as de_id, frac, radio,
        mza, lado as de_lado,
        case when lado < max then lado + 1 else 1 end as lado
    from max_lado
    natural join lados_info
    where lado != '0'
    ),
    doblando as (
    select *
    from doblar
    join lados_info
    using (frac, radio, mza, lado)
    )
select frac, radio, mza, de_lado, lado as a_lado, de_id, id as a_id
    , calle, desde, hasta
from doblando
order by frac, radio, mza, de_lado, a_lado, de_id, a_id
;

select * from doblar;

/*
 frac | radio | mza | de_lado | a_lado | de_id | a_id |             calle             | desde | hasta
------+-------+-----+---------+--------+-------+------+-------------------------------+-------+-------
    1 |     1 |   1 |       1 |      2 |     1 |    2 | LARSEN                        |  3301 |  3399
    1 |     1 |   1 |       2 |      3 |     2 |    3 | AV GRL PAZ                    |  5900 |  5792
    1 |     1 |   1 |       3 |      1 |     3 |    1 | CAMPANA                       |  5700 |  5602
    1 |     1 |   2 |       1 |      2 |     4 |    5 | COCHRANE                      |  3401 |  3499
    1 |     1 |   2 |       2 |      3 |     5 |    6 | AV GRL PAZ                    |  6000 |  5902
    1 |     1 |   2 |       3 |      1 |     6 |    4 | LLAVALLOL                     |  5600 |  5502
    1 |     1 |   3 |       1 |      2 |     7 |    8 | COCHRANE                      |  3301 |  3399
    1 |     1 |   3 |       2 |      3 |     8 |    9 | LLAVALLOL                     |  5501 |  5599
    1 |     1 |   3 |       3 |      4 |     9 |   10 | LARSEN                        |  3400 |  3302
    1 |     1 |   3 |       4 |      1 |    10 |    7 | CAMPANA                       |  5600 |  5502
...
*/

insert into grafo_adyacencias_lados
select de_id as lado_id, a_id as lado_ady, 'doblar'
from doblar
;

-- ver que onda
select * from grafo_adyacencias_lados;
/*
 lado_id | lado_ady | tipo_ady
---------+----------+----------
       1 |        2 | doblar
       2 |        3 | doblar
       3 |        1 | doblar
       4 |        5 | doblar
       5 |        6 | doblar
       6 |        4 | doblar
       7 |        8 | doblar
       8 |        9 | doblar
       9 |       10 | doblar
      10 |        7 | doblar
      11 |       12 | doblar
      12 |       13 | doblar
      13 |       14 | doblar
      14 |       11 | doblar
...
*/



