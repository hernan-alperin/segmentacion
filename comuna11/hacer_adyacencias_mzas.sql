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

drop table aydacencias_mzas;
create table aydacencias_mza as
select d.mza as mza, d.lado, 
    h.mza as mza_ady, h.lado as lado_ady, 
    d.id as lado_id, h.id as ady_id, tipo_ady
from grafo_adyacencias_lados g
join lados_de_manzana d
on lado_id = d.id
join lados_de_manzana h
on lado_ady = h.id
where tipo_ady != 'doblar'
order by d.mza, d.lado, h.mza, h.lado
;

/*
select *
from aydacencias_mza
limit 10

       mza       | lado |     mza_ady     | lado_ady | lado_id | ady_id | tipo_ady
-----------------+------+-----------------+----------+---------+--------+----------
 020770100101001 |    1 | 020770100101003 |        1 |       1 |      7 | cruzar
 020770100101001 |    2 | 020770100101003 |        4 |       2 |     10 | volver
 020770100101002 |    1 | 020770100101003 |        3 |       4 |      9 | volver
 020770100101002 |    1 | 020770100101007 |        1 |       4 |     19 | cruzar
 020770100101002 |    2 | 020770100101007 |        4 |       5 |     22 | volver
 020770100101002 |    3 | 020770100101003 |        4 |       6 |     10 | cruzar
 020770100101003 |    1 | 020770100101004 |        1 |       7 |     11 | cruzar
 020770100101003 |    2 | 020770100101002 |        2 |       8 |      5 | cruzar
 020770100101003 |    2 | 020770100101004 |        4 |       8 |     14 | volver
 020770100101003 |    3 | 020770100101001 |        3 |       9 |      3 | cruzar
(10 filas)

*/



