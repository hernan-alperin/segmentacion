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

select id, frac, radio, mza, lado
from lados_de_manzana
order by frac, radio, mza, lado
limit 10
;

-- order by id


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

select * from doblar limit 10;
/*
    nomencla     | frac | radio | mza | de_lado | a_lado | de_id | a_id 
-----------------+------+-------+-----+---------+--------+-------+------
 020770100101001 |    1 |     1 |   1 |       1 |      2 |    14 |   41
 020770100101001 |    1 |     1 |   1 |       2 |      3 |    41 |   52
 020770100101001 |    1 |     1 |   1 |       3 |      1 |    52 |   14
 020770100101002 |    1 |     1 |   2 |       1 |      2 |   102 |  117
 020770100101002 |    1 |     1 |   2 |       2 |      3 |   117 |  140
 020770100101002 |    1 |     1 |   2 |       3 |      1 |   140 |  102
 020770100101003 |    1 |     1 |   3 |       1 |      2 |   175 |  197
 020770100101003 |    1 |     1 |   3 |       2 |      3 |   197 |  230
 020770100101003 |    1 |     1 |   3 |       3 |      4 |   230 |  247
 020770100101003 |    1 |     1 |   3 |       4 |      1 |   247 |  175
(10 rows)
*/

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

select * from grafo_adyacencias_lados limit 10;
/*
 lado_id | lado_ady | tipo_ady 
---------+----------+----------
      14 |       41 | doblar
      41 |       52 | doblar
      52 |       14 | doblar
     102 |      117 | doblar
     117 |      140 | doblar
     140 |      102 | doblar
     175 |      197 | doblar
     197 |      230 | doblar
     230 |      247 | doblar
     247 |      175 | doblar
(10 rows)
*/


-------------------------------------------------------------------
-------------------------------------------------------------------
--  creando grafo de adyacencias entre manzanas
--  para calcular los lados de cruzar y volver
-------------------------------------------------------------------

----- adyacencias

drop view codigos_manzanas_adyacentes cascade;
create view codigos_manzanas_adyacentes as
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
--TODO: verificar que con solo tener un eje en común las hace adyacentes...


select * from codigos_manzanas_adyacentes order by mza_i, mza_j limit 10;
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

select * from lado_de_enfrente_para_volver limit 10;
/*
      mza_i      | lado_i |      mza_j      | lado_j
-----------------+--------+-----------------+--------
 020770100101001 |      2 | 020770100101003 |      4
 020770100101002 |      1 | 020770100101003 |      3
 020770100101002 |      2 | 020770100101007 |      4
 020770100101003 |      4 | 020770100101001 |      2
 020770100101003 |      3 | 020770100101002 |      1
 020770100101003 |      2 | 020770100101004 |      4
 020770100101004 |      4 | 020770100101003 |      2
 020770100101004 |      2 | 020770100101005 |      4
 020770100101004 |      3 | 020770100101007 |      1
 020770100101005 |      4 | 020770100101004 |      2
(10 filas)
*/

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

select * from lado_para_cruzar limit 10;
/*
      mza_i      | lado_i |      mza_j      | lado_j
-----------------+--------+-----------------+--------
 020770100101001 |      1 | 020770100101003 |      1
 020770100101002 |      3 | 020770100101003 |      4
 020770100101002 |      1 | 020770100101007 |      1
 020770100101003 |      3 | 020770100101001 |      3
 020770100101003 |      2 | 020770100101002 |      2
 020770100101003 |      1 | 020770100101004 |      1
 020770100101004 |      3 | 020770100101003 |      3
 020770100101004 |      1 | 020770100101005 |      1
 020770100101004 |      2 | 020770100101007 |      2
 020770100101005 |      3 | 020770100101004 |      3
(10 filas)
*/


-- buscar ids de lados para_volver
drop view if exists para_volver;
create view para_volver as
select de.nomencla as de_nomencla, a.nomencla as a_nomencla,
    de.frac, de.radio, de.mza as de_mza, de.lado as de_lado,
    a.mza as a_mza, a.lado as a_lado,
    de.id as de_id, a.id as a_id
from lados_de_manzana de
join lado_de_enfrente_para_volver
on de.nomencla = mza_i and de.lado = lado_i
join lados_de_manzana a
on a.nomencla = mza_j and a.lado = lado_j
order by de.frac, de.radio, de.mza, de.lado, a.mza, a.lado
;

select * from para_volver limit 10;

/*
*/


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

select * from para_cruzar limit 10;

/*
   de_nomencla   |   a_nomencla    | frac | radio | de_mza | de_lado | a_mza | a_lado | de_id | a_id 
-----------------+-----------------+------+-------+--------+---------+-------+--------+-------+------
 020770100101001 | 020770100101003 |    1 |     1 |      1 |       1 |     3 |      1 |    14 |  175
 020770100101002 | 020770100101007 |    1 |     1 |      2 |       1 |     7 |      1 |   102 |  531
 020770100101002 | 020770100101003 |    1 |     1 |      2 |       3 |     3 |      4 |   140 |  247
 020770100101003 | 020770100101004 |    1 |     1 |      3 |       1 |     4 |      1 |   175 |  259
 020770100101003 | 020770100101002 |    1 |     1 |      3 |       2 |     2 |      2 |   197 |  117
 020770100101003 | 020770100101001 |    1 |     1 |      3 |       3 |     1 |      3 |   230 |   52
 020770100101004 | 020770100101005 |    1 |     1 |      4 |       1 |     5 |      1 |   259 |  348
 020770100101004 | 020770100101007 |    1 |     1 |      4 |       2 |     7 |      2 |   292 |  542
 020770100101004 | 020770100101003 |    1 |     1 |      4 |       3 |     3 |      3 |   302 |  230
 020770100101005 | 020770100101004 |    1 |     1 |      5 |       3 |     4 |      3 |   396 |  302
(10 rows)
*/

insert into grafo_adyacencias_lados
select de_id as lado_id, a_id as lado_ady, 'cruzar'
from para_cruzar
;

--------------------------------------------------------------
--TODO: hacer tabla de acciones 1: doblar, 2: volver, 3: cruzar

