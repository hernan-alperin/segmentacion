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
select substr(d.mza,9,2)::integer as frac, substr(d.mza,11,2)::integer as radio,
    substr(d.mza,13,3)::integer as mza, d.lado, 
    substr(h.mza,13,3)::integer as mza_ady, h.lado as lado_ady, 
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
from adyacencias_mzas
limit 10
;
 frac | radio | mza | lado | mza_ady | lado_ady | lado_id | ady_id | tipo_ady
------+-------+-----+------+---------+----------+---------+--------+----------
    1 |     1 |   1 |    1 |       3 |        1 |       1 |      7 | cruzar
    1 |     1 |   1 |    2 |       3 |        4 |       2 |     10 | volver
    1 |     1 |   2 |    1 |       3 |        3 |       4 |      9 | volver
    1 |     1 |   2 |    1 |       7 |        1 |       4 |     19 | cruzar
    1 |     1 |   2 |    2 |       7 |        4 |       5 |     22 | volver
    1 |     1 |   2 |    3 |       3 |        4 |       6 |     10 | cruzar
    1 |     1 |   3 |    1 |       4 |        1 |       7 |     11 | cruzar
    1 |     1 |   3 |    2 |       2 |        2 |       8 |      5 | cruzar
    1 |     1 |   3 |    2 |       4 |        4 |       8 |     14 | volver
    1 |     1 |   3 |    3 |       1 |        3 |       9 |      3 | cruzar
(10 filas)
*/

 select frac_comun, radio_comu, mza_comuna, 
    cant_lados, vivs, segmento_en_manzana_equilibrado 
 from segmentos_equilibrados
 order by frac_comun, radio_comu, mza_comuna
 ;
 
 



