/*
titulo: generar_conteos.sql
descripcion: crea las views con los conteos de viviendass de manzanas y lados
fecha: 2019-05-22 Ma
autor: -h 
*/

create view conteos_manzanas as
select frac, radio, mza, count(*) as vivs_mza
from comuna11
group by frac, radio, mza
;

create view conteos_lados as
select frac, radio, mza, lado, count(*) as vivs_lado
from comuna11
group by frac, radio, mza, lado
;


