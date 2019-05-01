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

drop function opciones_para_lado;
create or replace function opciones_para_lado(
    mza text,
    lado integer)
-- obtiene subllistado con el circuito de 2 manzanas
-- resultado de cruzar a la manzana 2 luego de recorrer la manzana 1 
-- en manzanas de 4 ejemplo dddvddd si esto es posible <= existe v
-- TODO: ver si es exhaustivo de todos los circuitos posibles de 2 mzas
returns table (
    lado_id integer,
    mza text,
    lado integer,
    ady_id integer,
    mza_ady text,
    lado_ady integer,
    tipo_ady text
    )
as $$
select lado_id, l.mza, l.lado::integer, 
    g.lado_ady as ady_id, a.mza as mza_ady, a.lado::integer as lado_ady, tipo_ady 
from lados_de_manzana l
join grafo_adyacencias_lados g
on l.id::integer = g.lado_id
and l.mza = $1
and l.lado = $2
join lados_de_manzana a
on a.id = g.lado_ady
$$
language sql
;

/*
select * from opciones_para_lado('020770100101001',1);


*/

