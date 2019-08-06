/*
titulo: masajear.sql
descripción:
lo que hay que hacerle a los datos para que las rutinas funcionen...
autor: -h
fecha: 2019-06-05 Mi 
*/

update listados.mdq
set piso = 0 
where piso is Null
;


