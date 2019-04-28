/*
titulo: finciones.sql
descripción: funciones pra operar sobre manzanas y circuitos
autor: -h
fecha: 2019-04-28 Do
*/

create or replace function manzana(frac, radio, mza) 
-- obtiene subllistado con solo la manzana del listado
-- solo el lado, hn, hp y id
returns table (
  id integer, 
  lado integer, 
  hn integer, 
  hp integer) 
as $$
select * 
from comuna11
where frac_comun = #1
and radio_comu = #2
and mza_comuna = #3
$$
languaje sql
;


