/*
titulo: estandarizar_listado.sql
descripcion:
asegura que los campos de la base recibida estés según las especificaciones
del archivo: especificaciones

autor:-h
fecha: 2019-06-03 Lu
*/

create schema if not exists listados;

-- normalizar columnas de formato CABA
-- frac_comun | radio_comu | mza_comuna --> frac | radio | mza
drop table if exists listados.caba;
create table listados.caba as
select id_0, id, 
    "COMUNAS"::integer depto, "IdBarrio" idbarrio, 
    "FRAC_COMUN"::integer frac, "RADIO_COMU"::integer radio, 
    "MZA_COMUNA"::integer mza , "CLADO"::integer lado, "CCODIGO" cod_calle,
    "CNOMBRE" nombre_calle, "HN" numero, "H4" as h4, Null cuerpo, 
    "HP" piso, "HD" apt, "Nomencla-20" nomencla_20
from 
---------- Nombre de la tabla con los datos importados -----------
recorte_comunas_8_11_14_15
------------------------------------------------------------------
where id is not Null
;






