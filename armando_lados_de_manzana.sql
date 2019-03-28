-- título: doing_dvc_adyacencias.sql
-- descripción:
--
-- trabaja sobre el ejemplo de la comuna11
-- todo: generalizar a otros deptos
--
-- autor: -h
-- fecha creación: 2019-03-26 Mi

/*
la tabla lineas contiene los ejes del shape e0211lin enviado por mail por Manu
mar 19/3, 10:38
*/

drop table if exists lados_de_manzana;
-- tabla con los ejes unidos, lados duplicado y dirigidos por
-- mzad, ladod en sentido y mzai, ladoi en sentido contrario
-- para respetar regla hombro derecho
--
create table lados_de_manzana
as with pedacitos_de_lado as (-- mza como PPDDDLLLFFRRMMMselect mzad as mza, ladod as lado, avg(anchomed) as anchomed,
    select mzad as mza, ladod as lado,
        array_agg(distinct tipo) as tipos,
        array_agg(distinct codigo) as codigos,
        array_agg(distinct nombre) as calles,
        ST_Union(geom) as geom_pedacito -- ST_Union por ser MultiLineString
    from e0211lin
    where mzad is not Null and mzad != '' and ladod != 0
    and substr(mzad,1,8) = '02077010' -- en la comuna
    group by mzad, ladod
    union -- duplica los pedazos de lados a derecha e izquierda
    select mzai as mza, ladoi as lado,
        array_agg(distinct tipo) as tipos,
        array_agg(distinct codigo) as codigos,
        array_agg(distinct nombre) as calles,
        ST_Union(ST_Reverse(geom)) as geom_pedacito -- invierte los de mzai
        -- para respetar sentido hombro derecho
    from e0211lin
    where mzai is not Null and mzai != '' and ladoi != 0
    and substr(mzai,1,8) = '02077010'
    group by mzai, ladoi, tipo, codigo, nombre
    order by mza, lado--, tipo, codigo, calle
    ),
    lados_orientados as (
    select mza, lado,
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
limit 10
;

/*
 id |       mza       | lado |  tipos  | codigos |     calles     |                                                         lado_geom           |                    nodo_i_geom                     |                    nodo_j_geom
----+-----------------+------+---------+---------+----------------+----------------------------------------------------------------------------------------------------------------------------+----------------------------------------------------+----------------------------------------------------
  1 | 020770100101001 |    1 | {CALLE} | {1805}  | {CAMPANA}      | 0102000020A9560000020000000000008031805541000000201A8C5741000000204080554100000000068C5741           | 0101000020A95600000000008031805541000000201A8C5741 | 0101000020A9560000000000204080554100000000068C5741
  2 | 020770100101001 |    2 | {CALLE} | {5670}  | {LARSEN}       | 0102000020A956000002000000000000204080554100000000068C57410000002021805541000000A0EF8B5741           | 0101000020A9560000000000204080554100000000068C5741 | 0101000020A95600000000002021805541000000A0EF8B5741
  3 | 020770100101001 |    3 | {AV}    | {7430}  | {"AV GRL PAZ"} | 0102000020A9560000030000000000002021805541000000A0EF8B5741000000E02080554100000020F18B57410000008031805541000000201A8C5741 | 0101000020A95600000000002021805541000000A0EF8B5741 | 0101000020A95600000000008031805541000000201A8C5741
  4 | 020770100101002 |    1 | {CALLE} | {5930}  | {LLAVALLOL}    | 0102000020A9560000020000000000002021805541000000A0EF8B5741000000C02F80554100000080DB8B5741           | 0101000020A95600000000002021805541000000A0EF8B5741 | 0101000020A9560000000000C02F80554100000080DB8B5741
  5 | 020770100101002 |    2 | {CALLE} | {2375}  | {COCHRANE}     | 0102000020A956000002000000000000C02F80554100000080DB8B5741000000200F80554100000060C58B5741           | 0101000020A9560000000000C02F80554100000080DB8B5741 | 0101000020A9560000000000200F80554100000060C58B5741
  6 | 020770100101002 |    3 | {AV}    | {7430}  | {"AV GRL PAZ"} | 0102000020A956000003000000000000200F80554100000060C58B5741000000601F80554100000040ED8B57410000002021805541000000A0EF8B5741 | 0101000020A9560000000000200F80554100000060C58B5741 | 0101000020A95600000000002021805541000000A0EF8B5741
  7 | 020770100101003 |    1 | {CALLE} | {1805}  | {CAMPANA}      | 0102000020A956000003000000000000204080554100000000068C57410000008042805541000000C0028C5741000000A04E805541000000E0F18B5741 | 0101000020A9560000000000204080554100000000068C5741 | 0101000020A9560000000000A04E805541000000E0F18B5741
  8 | 020770100101003 |    2 | {CALLE} | {2375}  | {COCHRANE}     | 0102000020A956000002000000000000A04E805541000000E0F18B5741000000C02F80554100000080DB8B5741           | 0101000020A9560000000000A04E805541000000E0F18B5741 | 0101000020A9560000000000C02F80554100000080DB8B5741
  9 | 020770100101003 |    3 | {CALLE} | {5930}  | {LLAVALLOL}    | 0102000020A956000002000000000000C02F80554100000080DB8B57410000002021805541000000A0EF8B5741           | 0101000020A9560000000000C02F80554100000080DB8B5741 | 0101000020A95600000000002021805541000000A0EF8B5741
 10 | 020770100101003 |    4 | {CALLE} | {5670}  | {LARSEN}       | 0102000020A9560000020000000000002021805541000000A0EF8B5741000000204080554100000000068C5741           | 0101000020A95600000000002021805541000000A0EF8B5741 | 0101000020A9560000000000204080554100000000068C5741
(10 filas)
*/

-----------------------------------------------------------
---- Grafo de adyacencias
drop table if exists grafo_adyacencias_lados;
create table grafo_adyacencias_lados (
lado_id integer,
lado_ady integer,
tipo_ady text
);

---- doblar
drop view if exists doblar;
create view doblar as
with max_lado as (
    select mza, max(lado)
    from lados_de_manzana
    group by mza
    ),
    doblar as (
    select id as de_id, mza, lado as de_lado,
        case when lado < max then lado + 1 else 1 end as lado
        -- lado el lado que dobla de la misma mza
    from max_lado
    join lados_de_manzana
    using (mza)
    where lado != '0'
    )
select de.mza, de_lado, lado as a_lado, de_id, a.id as a_id
from doblar de
join lados_de_manzana a
using(mza, lado)
order by mza, de_lado, a_lado, de_id, a_id
;

select * from doblar limit 10;
/*
       mza       | de_lado | a_lado | de_id | a_id
-----------------+---------+--------+-------+------
 020770100101001 |       1 |      2 |     1 |    2
 020770100101001 |       2 |      3 |     2 |    3
 020770100101001 |       3 |      1 |     3 |    1
 020770100101002 |       1 |      2 |     4 |    5
 020770100101002 |       2 |      3 |     5 |    6
 020770100101002 |       3 |      1 |     6 |    4
 020770100101003 |       1 |      2 |     7 |    8
 020770100101003 |       2 |      3 |     8 |    9
 020770100101003 |       3 |      4 |     9 |   10
 020770100101003 |       4 |      1 |    10 |    7
(10 filas)
*/


delete grafo_adyacencias_lados;
insert into grafo_adyacencias_lados
select de_id as lado_id, a_id as lado_ady, 'doblar'
from doblar
;

select * from grafo_adyacencias_lados limit 10;
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
(10 filas)
*/


-------------------------------------------------------------------
-------------------------------------------------------------------
--  creando grafo de adyacencias entre manzanas
--  para calcular los lados de cruzar y volver
-------------------------------------------------------------------

----- adyacencias

drop view codigo_manzanas_adyacentes;
create view codigo_manzanas_adyacentes as
select mzad as mza_i, mzai as mza_j
from e0211lin
where substr(mzad,1,12) = substr(mzai,1,12) -- mismo PPDDDLLLFFRR
and mzad is not Null and mzad != '' and ladod != 0
and mzai is not Null and mzai != '' and ladod != 0
union -- hacer simétrica
select mzai, mzad
from e0211lin
where substr(mzad,1,12) = substr(mzai,1,12) -- mismo PPDDDLLLFFRR
and mzad is not Null and mzad != '' and ladod != 0
and mzai is not Null and mzai != '' and ladod != 0
;

select * from codigo_manzanas_adyacentes order by mza_i, mza_j limit 10;
/*
      mza_i      |      mza_j
-----------------+-----------------
 020770100101001 | 020770100101003
 020770100101002 | 020770100101003
 020770100101002 | 020770100101007
 020770100101003 | 020770100101001
 020770100101003 | 020770100101002
 020770100101003 | 020770100101004
 020770100101004 | 020770100101003
 020770100101004 | 020770100101005
 020770100101004 | 020770100101007
 020770100101005 | 020770100101004
(10 filas)
*/
-- es simétrica
                     
