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
[halpe@sigdesa4 segmentador]$ awk -F',' '{ print NF-1 }' /tmp/caba-11.csv | uniq
9
o -F'\t' según cual sea el separador de campos del csv... debería ser comas... :-P
comuna11=# 

*/
select load_csv_file('listado','/tmp/caba-11.csv',10);
/*
load_csv_file
---------------

(1 fila)
*/
select * from listado where piso is not Null limit 10;
/*
 depto | frac | radio | mnza | lado |   nombre    | numero | cuerpo | piso | count
-------+------+-------+------+------+-------------+--------+--------+------+-------
 11    | 1    | 1     | 1    | 2    | LARSEN      | 3355   |        | 1    | 1
 11    | 1    | 1     | 1    | 3    | AV GRAL PAZ | 5866   |        | 1    | 1
 11    | 1    | 1     | 1    | 3    | AV GRAL PAZ | 5804   |        | 1    | 1
 11    | 1    | 1     | 2    | 2    | COCHRANE    | 3403   |        | 1    | 1
 11    | 1    | 1     | 2    | 2    | COCHRANE    | 3405   |        | 1    | 1
 11    | 1    | 1     | 2    | 2    | COCHRANE    | 3439   |        | 1    | 1
 11    | 1    | 1     | 2    | 3    | AV GRAL PAZ | 5938   |        | PB   | 1
 11    | 1    | 1     | 2    | 3    | AV GRAL PAZ | 5936   |        | PB   | 1
 11    | 1    | 1     | 2    | 3    | AV GRAL PAZ | 5932   |        | 1    | 1
 11    | 1    | 1     | 3    | 1    | CAMPANA     | 5552   |        | 3    | 1
(10 filas)

*/

alter table listado add column segmento_mza integer;
alter table listado add column id serial;
alter table listado owner to segmentador;

select * from listado where piso is not Null limit 10;
/*
 depto | frac | radio | mnza | lado |   nombre    | numero | cuerpo | piso | count | segmento_mza | id
-------+------+-------+------+------+-------------+--------+--------+------+-------+--------------+----
 11    | 1    | 1     | 1    | 2    | LARSEN      | 3355   |        | 1    | 1     |              | 14
 11    | 1    | 1     | 1    | 3    | AV GRAL PAZ | 5866   |        | 1    | 1     |              | 28
 11    | 1    | 1     | 1    | 3    | AV GRAL PAZ | 5804   |        | 1    | 1     |              | 39
 11    | 1    | 1     | 2    | 2    | COCHRANE    | 3403   |        | 1    | 1     |              | 47
 11    | 1    | 1     | 2    | 2    | COCHRANE    | 3405   |        | 1    | 1     |              | 48
 11    | 1    | 1     | 2    | 2    | COCHRANE    | 3439   |        | 1    | 1     |              | 55
 11    | 1    | 1     | 2    | 3    | AV GRAL PAZ | 5938   |        | PB   | 1     |              | 66
 11    | 1    | 1     | 2    | 3    | AV GRAL PAZ | 5936   |        | PB   | 1     |              | 67
 11    | 1    | 1     | 2    | 3    | AV GRAL PAZ | 5932   |        | 1    | 1     |              | 68
 11    | 1    | 1     | 3    | 1    | CAMPANA     | 5552   |        | 3    | 1     |              | 75
(10 rows)

*/



