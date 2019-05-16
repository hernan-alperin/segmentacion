-- título: doing_dvc_adyacencias.sql
-- descripción: genera los lado agregando ejes de calles
-- y pequeños pedazos
-- agraga en arrays si tipos, codigos o calles cambian en ese lado
--
-- trabaja sobre el ejemplo de la comuna11
-- todo: generalizar a otros deptos
--
-- autor: -h
-- fecha creación: 2019-03-26 Mi

/*
la tabla lineas contiene los ejes del shape e0211lin enviado por mail por Manu
mar 19/3, 10:38
*/

drop table if exists lados_de_manzana;
-- tabla con los ejes unidos, lados duplicado y dirigidos por
-- mzad, ladod en sentido y mzai, ladoi en sentido contrario
-- para respetar regla hombro derecho
--
drop table lados_de_manzana cascade;
create table lados_de_manzana
as with pedacitos_de_lado as (-- mza como PPDDDLLLFFRRMMMselect mzad as mza, ladod as lado, avg(anchomed) as anchomed,
    select mzad as mza, ladod as lado,
        array_agg(distinct tipo) as tipos,
        array_agg(distinct codigo) as codigos,
        array_agg(distinct nombre) as calles,
        ST_Union(geom) as geom_pedacito -- ST_Union por ser MultiLineString
    from e0211lin
    where mzad is not Null and mzad != '' and ladod != 0
    and substr(mzad,1,8) = '02077010' -- en la comuna
    group by mzad, ladod
    union -- duplica los pedazos de lados a derecha e izquierda
    select mzai as mza, ladoi as lado,
        array_agg(distinct tipo) as tipos,
        array_agg(distinct codigo) as codigos,
        array_agg(distinct nombre) as calles,
        ST_Union(ST_Reverse(geom)) as geom_pedacito -- invierte los de mzai
        -- para respetar sentido hombro derecho
    from e0211lin
    where mzai is not Null and mzai != '' and ladoi != 0
    and substr(mzai,1,8) = '02077010'
    group by mzai, ladoi, tipo, codigo, nombre
    order by mza, lado--, tipo, codigo, calle
    ),
    lados_orientados as (
    select mza as nomencla, 
        substr(mza,9,2)::integer as frac, substr(mza,11,2)::integer as radio, 
        substr(mza,13,3)::integer as mza, lado,
        tipos, codigos, calles,
        ST_LineMerge(ST_Union(geom_pedacito)) as lado_geom -- une por mza,lado
    from pedacitos_de_lado
    group by mza, lado, tipos, codigos, calles
    order by mza, lado
    )
select row_number() over() as id, *,
    ST_StartPoint(lado_geom) as nodo_i_geom, ST_EndPoint(lado_geom) as nodo_j_geom
from lados_orientados
order by mza, lado
;

select *
from lados_de_manzana
order by id
limit 10
;

/*
 id |    nomencla     | frac | radio | mza | lado |  tipos  | codigos |             calles             |                                                                     lado_geom                                                                      |                nodo_i_geom                 |                nodo_j_geom                 
----+-----------------+------+-------+-----+------+---------+---------+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------------+--------------------------------------------
  1 | 020770100901001 | 09   | 01    | 001 |    1 | {CALLE} | {8710}  | {"SAN NICOLAS"}                | 010200000002000000000000601681554100000080DB895741000000801A815541000000C0D5895741                                                                 | 0101000000000000601681554100000080DB895741 | 0101000000000000801A815541000000C0D5895741
  2 | 020770101801001 | 18   | 01    | 001 |    1 | {CALLE} | {2695}  | {CUENCA}                       | 010200000004000000000000E00C835541000000402F885741000000200F835541000000802B885741000000E0158355410000002021885741000000E01E8355410000002013885741 | 0101000000000000E00C835541000000402F885741 | 0101000000000000E01E8355410000002013885741
  3 | 020770100301001 | 03   | 01    | 001 |    1 | {CALLE} | {4060}  | {"FERNANDEZ DE ENCISO"}        | 010200000002000000000000606A805541000000C0738A5741000000006580554100000020518A5741                                                                 | 0101000000000000606A805541000000C0738A5741 | 0101000000000000006580554100000020518A5741
  4 | 020770100801001 | 08   | 01    | 001 |    1 | {CALLE} | {8710}  | {"SAN NICOLAS"}                | 010200000004000000000000C041815541000000209E89574100000020458155410000004099895741000000C04C815541000000208D895741000000204F8155410000004089895741 | 0101000000000000C041815541000000209E895741 | 0101000000000000204F8155410000004089895741
  5 | 020770101701001 | 17   | 01    | 001 |    1 | {CALLE} | {8710}  | {"SAN NICOLAS"}                | 0102000000020000000000008043825541000000803F885741000000E05B8255410000006027885741                                                                 | 01010000000000008043825541000000803F885741 | 0101000000000000E05B8255410000006027885741
  6 | 020770100701001 | 07   | 01    | 001 |    1 | {CALLE} | {3350}  | {DESAGUADERO}                  | 010200000002000000000000A01580554100000040CA885741000000002780554100000020B4885741                                                                 | 0101000000000000A01580554100000040CA885741 | 0101000000000000002780554100000020B4885741
  7 | 020770100605001 | 06   | 05    | 001 |    1 | {CALLE} | {1725}  | {"CNL P CALDERON DE LA BARCA"} | 010200000003000000000000A0577F554100000020B8885741000000605A7F554100000060B5885741000000E0637F554100000000AC885741                                 | 0101000000000000A0577F554100000020B8885741 | 0101000000000000E0637F554100000000AC885741
  8 | 020770100401001 | 04   | 01    | 001 |    1 | {CALLE} | {7340}  | {PAREJA}                       | 01020000000200000000000040A97F554100000080CA895741000000808C7F554100000060B4895741                                                                 | 010100000000000040A97F554100000080CA895741 | 0101000000000000808C7F554100000060B4895741
  9 | 020770100101001 | 01   | 01    | 001 |    1 | {CALLE} | {1805}  | {CAMPANA}                      | 0102000000020000000000008031805541000000201A8C5741000000204080554100000000068C5741                                                                 | 01010000000000008031805541000000201A8C5741 | 0101000000000000204080554100000000068C5741
 10 | 020770101201001 | 12   | 01    | 001 |    1 | {AV}    | {6915}  | {"AV NAZCA"}                   | 010200000002000000000000005E825541000000E0EE8957410000008062825541000000A0E6895741                                                                 | 0101000000000000005E825541000000E0EE895741 | 01010000000000008062825541000000A0E6895741
(10 rows)

*/

