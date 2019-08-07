<?php
echo "<pre>\n";

$resultado = 'ok';

#$AAAA = 'b638'; #Pilar
#$AAAA = '0303'; #Junín
$AAAA = '0339'; #San Javier
$path = '/tmp/segmentacion';
$ogr_path = '/usr/pgsql-9.5/bin';

echo "---- unzipeando y cargando shapes\n";
$commands = array(
    "unzip -o {$path}/e{$AAAA}.zip -d $path",
//    "ls -lat {$path}",
    "{$ogr_path}/shp2pgsql -W latin1 -s 22183 -d {$path}/e{$AAAA}a shapes.e{$AAAA}a | (export PGPASSWORD=halpe; psql halpe -U daemon)",
    "{$ogr_path}/shp2pgsql -W latin1 -s 22183 -d {$path}/e{$AAAA}p shapes.e{$AAAA}p | (export PGPASSWORD=halpe; psql halpe -U daemon)",
    "export PGPASSWORD=halpe; psql halpe -U daemon -c '\dt shapes.'"
); 

foreach ($commands as $command) {
    if ($resultado == 'ok') {
        $out = '';
        exec($command, $out, $status);
        echo "$command\n";
        if (0 !== $status) {
            echo "Command failed with status: $status";
            $resultado = "falló $command";
        }
        var_dump($out);
    }
}

$conn_string = "dbname=halpe user=daemon password=halpe";  //(?) no puede conectarse con usuario halpe
$conn = pg_connect($conn_string) or die('connection failed');
$sql = "select distinct prov, depto from shapes.e{$AAAA}p;";
$result = pg_query($conn, $sql);

echo "\n";
while ($row = pg_fetch_row($result)) {
    var_dump($row);
    $prov = $row[0];
    $depto = $row[1];
}
// asumir que hay una sola prov, depto por aglomerado (ver excepciones CABA, Viedma-Carme de Patagones(?))

echo "---- Cargando tabla de conteos (!) ver si conviene hacer tabla de segmentacion.manzanas con campo conteos y campo perímetro\n";
$sql = <<<EOT
delete
from segmentacion.conteos
where prov::integer = $prov and depto::integer = $depto
or prov is Null
;

insert into segmentacion.conteos (prov, depto, codloc, frac, radio, mza, lado, conteo)
select prov, depto, codloc, frac, radio, mza, lado, conteo
from (
    select substr(mzai,1,2)::integer as prov, substr(mzai,3,3)::integer as depto, substr(mzai,6,3)::integer as codloc, substr(mzai,9,2)::integer as frac,
        substr(mzai,11,2)::integer as radio, substr(mzai,13,3)::integer as mza, ladoi as lado, conteoi as conteo
    from shapes.e{$AAAA}a
    union
    select substr(mzad,1,2)::integer as prov, substr(mzad,3,3)::integer as depto, substr(mzad,6,3)::integer as codloc, substr(mzad,9,2)::integer as frac,
        substr(mzad,11,2)::integer as radio, substr(mzad,13,3)::integer as mza, ladod as lado, conteod as conteo
    from shapes.e{$AAAA}a
    ) as conteos
;
EOT;

echo $sql."\n";
if (!($result = pg_query($conn, $sql))) {
    echo pg_last_error($conn);
}

echo "---- Carando tabla de adyacencias (!) ver de hacerlo usando PostGIS ... o usar chequeos para ladoi, ladod = 0\n";
$sql = <<<EOT
delete
from segmentacion.adyacencias
where prov::integer = $prov and depto::integer = $depto
;

insert into segmentacion.adyacencias (prov, depto, frac, radio, mza, lado, mza_ady, lado_ady)
select substr(mzai,1,2)::integer as prov, substr(mzai,3,3)::integer as depto
    , substr(mzai,9,2)::integer as frac, substr(mzai,11,2)::integer as radio
    , substr(mzai,13,3)::integer as mza, ladoi as lado, substr(mzad,13,3)::integer as mza_ady, ladod as lado_ady
from shapes.e{$AAAA}a
where substr(mzai,1,12) = substr(mzad,1,12) -- mismo radio
    and mzad != '' and mzad is not Null and mzai != '' and mzai is not Null
    -- and ladod != 0 and ladod is not Null and ladoi != 0 and ladoi is not Null
union
select substr(mzad,1,2)::integer as prov, substr(mzad,3,3)::integer as depto
    , substr(mzad,9,2)::integer as frac, substr(mzad,11,2)::integer as radio
    , substr(mzad,13,3)::integer as mza, ladod as lado, substr(mzai,13,3)::integer as mza_ady, ladoi as lado_ady
from shapes.e{$AAAA}a
where substr(mzai,1,12) = substr(mzad,1,12) -- mismo radio
    and mzai != '' and mzai is not Null and mzad != '' and mzad is not Null
    -- and ladod != 0 and ladod is not Null and ladoi != 0 and ladoi is not Null
;
EOT;

echo $sql."\n";
if (!($result = pg_query($conn, $sql))) {
    echo pg_last_error($conn);
}

echo "---- Agregando las columnas de identificación de segmento\n";
$queries = array(
    "alter table shapes.e{$AAAA}p add column segmento integer;",
    "alter table shapes.e{$AAAA}a add column segi integer;",
    "alter table shapes.e{$AAAA}a add column segd integer;"
    );

foreach ($queries as $sql) {
    echo $sql."\n";
    if (!($result = pg_query($conn, $sql))) {
        echo pg_last_error($conn);
    }
}

echo "---- Corriendo el segmentador\n";
$command = "python SegmentaManzanas.py $AAAA $prov $depto";
$out = '';
exec($command, $out, $status);
echo "$command\n";
if (0 !== $status) {
    echo "Command failed with status: $status";
}
var_dump($out);

echo "---- Cargando los segmentos en los arcos en la tabla de arcos para pasarlos al visualizador de Chubut\n";
$sql = <<<EOT
update shapes.e{$AAAA}a
set segi = segmento
from shapes.e{$AAAA}p
where prov::integer = $prov and depto::integer = $depto
and substr(mzai,1,2)::integer = prov::integer and substr(mzai,3,3)::integer = depto::integer
and substr(mzai,9,2)::integer = frac::integer and substr(mzai,11,2)::integer = radio::integer
and substr(mzai,13,3)::integer = mza::integer
;

update shapes.e{$AAAA}a
set segd = segmento
from shapes.e{$AAAA}p
where prov::integer = $prov and depto::integer = $depto
and substr(mzad,1,2)::integer = prov::integer and substr(mzad,3,3)::integer = depto::integer
and substr(mzad,9,2)::integer = frac::integer and substr(mzad,11,2)::integer = radio::integer
and substr(mzad,13,3)::integer = mza::integer
;
EOT;

echo $sql."\n";
if (!($result = pg_query($conn, $sql))) {
    echo pg_last_error($conn);
}

echo "---- Generando el shape de arcos con segi y segd en e{$AAAA}a.dbf\n";
$command = "{$ogr_path}/pgsql2shp -f /tmp/segmentacion/e{$AAAA}a halpe shapes.e{$AAAA}a";
$out = '';
exec($command, $out, $status);
echo "$command\n";
if (0 !== $status) {
    echo "Command failed with status: $status";
}
var_dump($out);

echo "---- zipeando el shape de arcos e{$AAAA}a\n";
$command = "zip -D -j $path/e{$AAAA} $path/e{$AAAA}*";
$out = '';
exec($command, $out, $status);
echo "$command\n";
if (0 !== $status) {
    echo "Command failed with status: $status";
}
var_dump($out);




echo "\n</pre>\n";
?>

