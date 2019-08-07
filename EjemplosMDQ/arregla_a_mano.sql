select frac, radio, mza, segmento, count(*)
from listados.pp2_06
where cod_tipo_vivredef not in ('', 'CO', 'N', 'CA/', 'LO')
group by frac, radio, mza, segmento
order by frac, radio, mza, segmento
;
-- 'CA/' construccion abandonada no es vivienda

/*
   62 |     6 |   1 |       16 |    39
   62 |     6 |   2 |       17 |     1
   62 |     6 |   3 |       18 |    35

la única vivienda de    62 |     6 |   2 |
asignar a segmento de manzana adyacente de menor cantidad
*/



select m.mza, m.lado, mza_ady, segmento, count(*)
from adyacencias_mzas m
join listados.pp2_06 l
on m.frac = l.frac and m.radio = l.radio and l.mza = mza_ady
where l.frac = 62 and l.radio = 6 and m.mza = 2
and cod_tipo_vivredef not in ('', 'CO', 'N', 'CA/', 'LO')
group by m.mza, m.lado, mza_ady, segmento
;


/*

 mza | lado | mza_ady | segmento | count
-----+------+---------+----------+-------
   2 |    1 |       3 |       18 |    35
   2 |    2 |       1 |       16 |    39
   2 |    3 |       1 |       16 |    39
   2 |    4 |       3 |       18 |    35
*/

update listados.pp2_06
set segmento = segmento - 1
where segmento > 17
;

------------------------------

/*
   30 |    11 |   1 |       13 |    35
   30 |    11 |   1 |       14 |    43
   30 |    11 |   1 |       15 |    32
   62 |     6 |   1 |       16 |    39
el segmento 15 puede tener 8 vivendas mas (1 piso) 14 -> 43 - 8 = 35, 15 -> 32 + 8 = 40
*/

select id, nrocatastralredef, pisoredef, dpto_habitacion, segmento
from listados.pp2_06
where segmento in (14, 15)
and nrocatastralredef = '1912'
and pisoredef in ('4', '5')
order by id
;


/*
 id  | nrocatastralredef | pisoredef | dpto_habitacion | segmento
-----+-------------------+-----------+-----------------+----------
 549 | 1912              | 5         | H               |       14
 550 | 1912              | 5         | G               |       14
 551 | 1912              | 5         | F               |       14
 552 | 1912              | 5         | E               |       14
 553 | 1912              | 5         | D               |       14
 554 | 1912              | 5         | C               |       14
 555 | 1912              | 5         | B               |       14
 556 | 1912              | 5         | A               |       14
 557 | 1912              | 4         | H               |       15
 558 | 1912              | 4         | G               |       15
 559 | 1912              | 4         | F               |       15
 560 | 1912              | 4         | E               |       15
 561 | 1912              | 4         | D               |       15
 562 | 1912              | 4         | C               |       15
 563 | 1912              | 4         | B               |       15
 564 | 1912              | 4         | A               |       15
*/

update listados.pp2_06
set segmento = 15
where nrocatastralredef = '1912'
and segmento = 14
and pisoredef = '5'
;


-------------------------------------------

