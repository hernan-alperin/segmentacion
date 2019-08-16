create schema if not exists listados;

-- normalizar columnas de formato CABA
-- Nueva versión.
drop table if exists listados.caba;
create table listados.caba as
select null id_0, id, 
    comunanumero::integer depto, barrionombre idbarrio, 
    fraccionnumero::integer frac, radionumero::integer radio, 
    manzananumero::integer mza , ladonumero::integer lado, callecodigo cod_calle,
    callenombre nombre_calle, numerocatastral numero, concat_ws(',',sector, edificio, entrada) as h4, Null cuerpo, 
    piso, concat_ws(',',departamento,habitacion) apt,habitacion, null nomencla_20
from 
---------- Nombre de la tabla con los datos importados -----------
listados.com1frac13rad8actualizado------------------------------------------------------------------
where id is not Null
;
