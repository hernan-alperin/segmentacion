/*
titulo: finciones.sql
descripción: funciones pra operar sobre manzanas y circuitos
autor: -h
fecha: 2019-04-28 Do
*/

create or replace function manzana(
    frac integer, 
    radio integer, 
    mza integer) 
-- obtiene subllistado con solo la manzana del listado
-- solo el lado, hn, hp y id
returns table (
  id integer, 
  lado integer, 
  hn integer, 
  hp integer) 
as $$
select id, clado, hn, hp
from comuna11
where frac_comun = $1
and radio_comu = $2
and mza_comuna = $3
$$
language sql
;

create or replace function max_lado(
    frac integer, 
    radio integer, 
    mza integer)
-- obtiene el numero del lado masgrnd (sume secuencial)
returns integer
as $$
select max(clado)  
from comuna11
where frac_comun = $1
and radio_comu = $2
and mza_comuna = $3
$$
language sql
;

create or replace function iniciar_manzana_en_lado(
    frac integer,
    radio integer,
    mza integer,
    lado integer)
-- obtiene subllistado con solo la manzana del listado
-- solo el lado, hn, hp y id
returns table (
  id integer,
  lado integer,
  hn integer,
  hp integer)
as $$
select id, clado, hn, hp
from comuna11
where frac_comun = $1
and radio_comu = $2
and mza_comuna = $3
order by 
    case 
        when clado < $4 then max_lado($1, $2, $3) + clado
        -- menor del pedido van despues del maximo
        else clado
    end
$$
language sql
;


