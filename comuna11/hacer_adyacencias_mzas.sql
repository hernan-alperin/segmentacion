-- título: hacer_adyacencias_mzas.sql
-- descripción:
--
-- Se hace ahora con consultas sql
-- 
--  
-- se constuyen las adyacencias de manzanas 
-- usando table grafo_adyacencias_lados
--
-- trabaja sobre el ejemplo de la comuna11
-- todo: generalizar a otros deptos
--
-- autor: -h
-- fecha creación: 2019-05-06 Lu

/*
la tabla lineas contiene los ejes del shape e0211lin enviado por mail por Manu
mar 19/3, 10:38
*/

drop table adyacencias_mzas;
create table adyacencias_mzas as
select i.frac, i.radio, i.mza, i.lado, 
    j.mza as mza_ady, j.lado as lado_ady, 
    i.id as lado_id, j.id as ady_id, tipo_ady
from grafo_adyacencias_lados g
join lados_de_manzana i
on lado_id = i.id
join lados_de_manzana j
on lado_ady = j.id
where tipo_ady != 'doblar'
order by frac, radio, mza, i.lado, j.mza, j.lado
;

select * from adyacencias_mzas limit 10;

/*
 frac | radio | mza | lado | mza_ady | lado_ady | lado_id | ady_id | tipo_ady 
------+-------+-----+------+---------+----------+---------+--------+----------
    1 |     1 |   1 |    1 |       3 |        1 |      14 |    175 | cruzar
    1 |     1 |   1 |    2 |       3 |        4 |      41 |    247 | volver
    1 |     1 |   2 |    1 |       3 |        3 |     102 |    230 | volver
    1 |     1 |   2 |    1 |       7 |        1 |     102 |    531 | cruzar
    1 |     1 |   2 |    2 |       7 |        4 |     117 |    585 | volver
    1 |     1 |   2 |    3 |       3 |        4 |     140 |    247 | cruzar
    1 |     1 |   3 |    1 |       4 |        1 |     175 |    259 | cruzar
    1 |     1 |   3 |    2 |       2 |        2 |     197 |    117 | cruzar
    1 |     1 |   3 |    2 |       4 |        4 |     197 |    325 | volver
    1 |     1 |   3 |    3 |       1 |        3 |     230 |     52 | cruzar
(10 rows)
*/




