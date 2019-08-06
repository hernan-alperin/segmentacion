/*
titulo: estandarizar_listado.sql
descripcion:
asegura que los campos de la base recibida estés según las especificaciones
del archivo: especificaciones
normaliza los campos a integer y los nombres depto, frac, radio, etc

autor:-h
fecha: 2019-06-03 Lu
*/

create schema if not exists listados;

-- normalizar columnas de formato CABA
-- frac_comun | radio_comu | mza_comuna --> frac | radio | mza
---------- Tabla a estandarizar --------------------------------
drop table if exists listados.mdq;
create table listados.mdq as
-----------------------------------------------------------------
select 
/*id_0, 
*/id,
    "dpto"::integer depto,
    "frac"::integer frac, "radio"::integer radio,
    "mza"::integer mza , "lado"::integer lado, "ccalle" cod_calle,
    "ncalle" nombre_calle, "nrocatastralredef" numero, 
    cod_tipo_vivredef as cod_viv, Null cuerpo,
    "pisoredef" piso, "dpto_habitacion" apt

from
---------- Nombre de la tabla con los datos importados -----------
listados.pp2_06
------------------------------------------------------------------
where id is not Null
and cod_tipo_vivredef not in ('', 'CO', 'N', 'CA/', 'LO')
;



