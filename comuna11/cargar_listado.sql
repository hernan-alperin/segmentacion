-- título: cargar listado.sql
-- descripción:
-- 
-- trabaja sobre el ejemplo de la comuna11
-- todo: generalizar a otros deptos
--
-- autor: -h
-- fecha creación: 2019-04-04 Ju

/*
la tabla contiene el listado enviado por mail por Manu
comuna11.dbf mar 19/3, 10:38
*/
/* proceso manual:

Opcion 1)

pasar el .dbf a .csv usando una planilla de cálculo
poner en /tmp para que sea visible para postgresl
import un .csv con header de columnas
definir la function a continuacion
*/
CREATE OR REPLACE FUNCTION load_csv_file(
    target_table text,
    csv_path text,
    col_count integer)
  RETURNS void AS
$BODY$

declare

iter integer; -- dummy integer to iterate columns with
col text; -- variable to keep the column name at each iteration
col_first text; -- first column name, e.g., top left corner on a csv file or spreadsheet

begin
    set schema 'public';

    create table temp_table ();

    -- add just enough number of columns
    for iter in 1..col_count
    loop
        execute format('alter table temp_table add column col_%s text;', iter);
    end loop;

    -- copy the data from csv file
    execute format('copy temp_table from %L with delimiter '','' quote ''"'' csv ', csv_path);

    iter := 1;
    col_first := (select col_1 from temp_table limit 1);

    -- update the column names based on the first row which has the column names
    for col in execute format('select unnest(string_to_array(trim(temp_table::text, ''()''), '','')) from temp_table where col_1 = %L', col_first)
    loop
        execute format('alter table temp_table rename column col_%s to %s', iter, col);
        iter := iter + 1;
    end loop;

    -- delete the columns row
    execute format('delete from temp_table where %s = %L', col_first, col_first);

    -- change the temp table name to the name given as parameter, if not blank
    if length(target_table) > 0 then
        execute format('alter table temp_table rename to %I', target_table);
    end if;

end;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION load_csv_file(text, text, integer)
  OWNER TO postgres;
/*
se invoca
select load_csv_file('myTable','C:/MyPath/MyFile.csv',n)
-- siendo n el número de columnas

para averiguarlo usar awk, ejemplo
[halpe@sigdesa4 segmentador]$ awk -F',' '{ print NF-1 }' /tmp/comuna11.csv | uniq
13
o -F'\t' según cual sea el separador de campos del csv... debería ser comas... :-P
comuna11=# 

*/
select load_csv_file('listado','/tmp/comuna11.csv',14);
/*
load_csv_file
---------------

(1 fila)
*/
\d listado

/*
         Tabla «public.listado»
   Columna    |  Tipo   | Modificadores
--------------+---------+---------------
 id           | text    |
 comunas      | text    |
 idbarrio     | text    |
 frac_comun   | text    |
 radio_comu   | text    |
 mza_comuna   | text    |
 clado        | text    |
 ccodigo      | text    |
 cnombre      | text    |
 hn           | text    |
 h4           | text    |
 hp           | text    |
 hd           | text    |
 nomencla_2   | text    |
 segmento_mza | integer |
*/

alter table listado add column segmento_mza integer;
alter table listado add column id serial;
alter table listado owner to segmentador;

select * from listado where hp is not Null limit 10;

/*
  id   | comunas | idbarrio | frac_comun | radio_comu | mza_comuna | clado | ccodigo |   cnombre   |  hn  | h4 | hp | hd |  nomencla_2   | segmento_mza
-------+---------+----------+------------+------------+------------+-------+---------+-------------+------+----+----+----+---------------+--------------
 58883 | 11      | 35       | 8          | 1          | 1          | 1     | 8710    | SAN NICOLAS | 3076 | 4  | 8  |    | 2011350801001 |
 58884 | 11      | 35       | 8          | 1          | 1          | 1     | 8710    | SAN NICOLAS | 3076 | 4  | 7  |    | 2011350801001 |
 58885 | 11      | 35       | 8          | 1          | 1          | 1     | 8710    | SAN NICOLAS | 3076 | 4  | 7  |    | 2011350801001 |
 58886 | 11      | 35       | 8          | 1          | 1          | 1     | 8710    | SAN NICOLAS | 3076 | 4  | 7  |    | 2011350801001 |
 58887 | 11      | 35       | 8          | 1          | 1          | 1     | 8710    | SAN NICOLAS | 3076 | 4  | 6  |    | 2011350801001 |
 58888 | 11      | 35       | 8          | 1          | 1          | 1     | 8710    | SAN NICOLAS | 3076 | 4  | 6  |    | 2011350801001 |
 58889 | 11      | 35       | 8          | 1          | 1          | 1     | 8710    | SAN NICOLAS | 3076 | 4  | 6  |    | 2011350801001 |
 58890 | 11      | 35       | 8          | 1          | 1          | 1     | 8710    | SAN NICOLAS | 3076 | 4  | 5  |    | 2011350801001 |
 58891 | 11      | 35       | 8          | 1          | 1          | 1     | 8710    | SAN NICOLAS | 3076 | 4  | 5  |    | 2011350801001 |
 58892 | 11      | 35       | 8          | 1          | 1          | 1     | 8710    | SAN NICOLAS | 3076 | 4  | 5  |    | 2011350801001 |
(10 filas)
*/

/*

Opción 2)

a) draguear el Comuna11.dbf a el area capas de QGIS,
b) abrir una conexión a la DB comuna11
c) draguear la capa del área capas a tabla de la conexi´on.
en este caso la tabla conserva el nombre del .dbf

*/


-- normalizar columnas de formato CABA
-- frac_comun | radio_comu | mza_comuna --> frac | radio | mza

alter table comuna11 add column frac integer;
update comuna11 set frac = frac_comun;
alter table comuna11 add column radio integer;
update comuna11 set radio = radio_comu;
alter table comuna11 add column mza integer;
update comuna11 set frac = mza_comuna;
alter table comuna11 add column lado integer;
update comuna11 set lado = clado;




