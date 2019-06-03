/*
titulo: estandarizar_listado.sql
descripcion:
asegura que los campos de la base recibida estés según las especificaciones
del archivo: especificaciones

autor:-h
fecha: 2019-06-03 Lu
*/

-- normalizar columnas de formato CABA
-- frac_comun | radio_comu | mza_comuna --> frac | radio | mza

alter table comuna11 add column frac integer;
update comuna11 set frac = frac_comun;
alter table comuna11 add column radio integer;
update comuna11 set radio = radio_comu;
alter table comuna11 add column mza integer;
update comuna11 set mza = mza_comuna;
alter table comuna11 add column lado integer;
update comuna11 set lado = clado;





