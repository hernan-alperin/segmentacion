<?php
// Turn on output buffering

function TryExec($command, $message, &$out) 
{
    try {
        $out = '';
        echo $command . "\n";
        exec($command, $out, $status);
        if ($status !== 0) 
            throw new Exception("$message:\n status: $status\n$out\n\n");
        echo "............. done" . "\n\n";
        var_dump($out);
    } catch (Exception $e) {
        echo $e->getMessage();
    }
}

function TrySQL($sql, $message, &$result) 
{
    try {
        echo $sql . "\n";
        $result = pg_query($sql);
        if (!$result) {
            throw new Exception("$message:\n" . pg_last_error($conn) . "\n");
        }
        echo "............. done" . "\n\n";
        var_dump($result);
    } catch (Exception $e) {
        echo $e->getMessage();
    }
}

function procesar($ficheroSubido) {
//try {
    ob_start();

    echo "<pre>\n";

    $ogr_path = '/usr/pgsql-9.5/bin';
    $path_parts = pathinfo($ficheroSubido);
    $dir = $path_parts['dirname'];
    $fileName = $path_parts['filename'];

    echo date("Y-m-d H:i:s");
    echo "---- unzipeando y cargando shapes\n";
    $commands = array(
       "unzip -o $ficheroSubido -d $dir",
       "{$ogr_path}/shp2pgsql -W latin1 -s 22183 -d $dir/{$fileName}a shapes.\"{$fileName}a\" | (export PGPASSWORD=rodatnemges; psql censo2020 -U segmentador)",
       "{$ogr_path}/shp2pgsql -W latin1 -s 22183 -d $dir/{$fileName}p shapes.\"{$fileName}p\" | (export PGPASSWORD=rodatnemges; psql censo2020 -U segmentador)",
       "export PGPASSWORD=rodatnemges; psql censo2020 -U segmentador -c '\dt shapes.'"
    ); 

    foreach ($commands as $command) {
        TryExec($command, "Error", $out);
    }

    $conn_string = "dbname=censo2020 user=segmentador password=rodatnemges";  //(?) no puede conectarse con usuario segmentador

    try {
        $conn = pg_connect($conn_string);
        if (!$conn) 
            throw new Exception("$conn_string\nconnection failed");
    } catch (Exception $e) {
       echo $e->getMessage();
    }

    $sql = "select distinct prov, depto from shapes.\"{$fileName}p\";";
    TrySQL($sql, "SQL Error", $result);

    while ($row = pg_fetch_row($result)) {
       var_dump($row);
        $prov = $row[0];
        $depto = $row[1];
    }
    // asumir que hay una sola prov, depto por aglomerado (ver excepciones CABA, Viedma-Carme de Patagones(?))

    echo date("Y-m-d H:i:s");
    echo "---- Cargando tabla de conteos (!) ver si conviene hacer tabla de segmentacion.manzanas con campo conteos y campo perímetro\n";
    $sql = <<<EOT
delete
from segmentacion.conteos
where prov::integer = $prov and depto::integer = $depto
or prov is Null
;

insert into segmentacion.conteos (shape, prov, depto, codloc, frac, radio, mza, lado, conteo)
select shape, prov, depto, codloc, frac, radio, mza, lado, conteo
from (
    select '{$fileName}a' as shape, 
        substr(mzai,1,2)::integer as prov, substr(mzai,3,3)::integer as depto, 
        substr(mzai,6,3)::integer as codloc, substr(mzai,9,2)::integer as frac,
        substr(mzai,11,2)::integer as radio, substr(mzai,13,3)::integer as mza, ladoi as lado, conteoi as conteo
    from shapes."{$fileName}a"
    union
    select '{$fileName}a' as shape, 
        substr(mzad,1,2)::integer as prov, substr(mzad,3,3)::integer as depto, 
        substr(mzad,6,3)::integer as codloc, substr(mzad,9,2)::integer as frac,
        substr(mzad,11,2)::integer as radio, substr(mzad,13,3)::integer as mza, ladod as lado, conteod as conteo
    from shapes."{$fileName}a"
    ) as conteos
;
EOT;

    TrySQL($sql, "SQL Error", $result);    

    echo date("Y-m-d H:i:s");
    echo "---- Cargando tabla de adyacencias (!) ver de hacerlo usando PostGIS ... o usar chequeos para ladoi, ladod = 0\n";
    $sql = <<<EOT
delete
from segmentacion.adyacencias
where prov::integer = $prov and depto::integer = $depto
;

insert into segmentacion.adyacencias (shape, prov, depto, frac, radio, mza, lado, mza_ady, lado_ady)
select '{$fileName}a' as shape, substr(mzai,1,2)::integer as prov, substr(mzai,3,3)::integer as depto
    , substr(mzai,9,2)::integer as frac, substr(mzai,11,2)::integer as radio
    , substr(mzai,13,3)::integer as mza, ladoi as lado, substr(mzad,13,3)::integer as mza_ady, ladod as lado_ady
from shapes."{$fileName}a"
where substr(mzai,1,12) = substr(mzad,1,12) -- mismo radio
    and mzad != '' and mzad is not Null and mzai != '' and mzai is not Null
    -- and ladod != 0 and ladod is not Null and ladoi != 0 and ladoi is not Null
union
select '{$fileName}a' as shape, substr(mzad,1,2)::integer as prov, substr(mzad,3,3)::integer as depto
    , substr(mzad,9,2)::integer as frac, substr(mzad,11,2)::integer as radio
    , substr(mzad,13,3)::integer as mza, ladod as lado, substr(mzai,13,3)::integer as mza_ady, ladoi as lado_ady
from shapes."{$fileName}a"
where substr(mzai,1,12) = substr(mzad,1,12) -- mismo radio
    and mzai != '' and mzai is not Null and mzad != '' and mzad is not Null
    -- and ladod != 0 and ladod is not Null and ladoi != 0 and ladoi is not Null
;
EOT;

    TrySQL($sql, "SQL Error", $result);

    echo date("Y-m-d H:i:s");
    echo "---- Agregando las columnas de identificación de segmento\n";
    $queries = array(
        "alter table shapes.\"{$fileName}p\" add column segmento integer;",
        "alter table shapes.\"{$fileName}a\" add column segi integer;",
        "alter table shapes.\"{$fileName}a\" add column segd integer;"
        );

    foreach ($queries as $sql) {
        echo $sql."\n";
        //    TrySQL($sql, "SQL Error", &$result);  // estos son Warnings
        if (!($result = pg_query($conn, $sql))) {
            echo pg_last_error($conn) . "\n";
        }
    }

    echo "\n\n";
    echo date("Y-m-d H:i:s");
    echo "---- Corriendo el segmentador\n";

    $command = "python SegmentaManzanasLados.py $fileName $prov $depto";
#    $command = "python SegmentaManzanas.py $fileName $prov $depto";
    TryExec($command, "Error", $out);

/* esto se hace desde python SegmentaManzanasLados.py

    echo date("Y-m-d H:i:s");
    echo "---- Cargando los segmentos en los arcos en la tabla de arcos para pasarlos al visualizador de Chubut\n";
    $sql = <<<EOT
update shapes.{$fileName}a
set segi = segmento
from shapes.{$fileName}p
where prov::integer = $prov and depto::integer = $depto
and substr(mzai,1,2)::integer = prov::integer and substr(mzai,3,3)::integer = depto::integer
and substr(mzai,9,2)::integer = frac::integer and substr(mzai,11,2)::integer = radio::integer
and substr(mzai,13,3)::integer = mza::integer
;

update shapes.{$fileName}a
set segd = segmento
from shapes.{$fileName}p
where prov::integer = $prov and depto::integer = $depto
and substr(mzad,1,2)::integer = prov::integer and substr(mzad,3,3)::integer = depto::integer
and substr(mzad,9,2)::integer = frac::integer and substr(mzad,11,2)::integer = radio::integer
and substr(mzad,13,3)::integer = mza::integer
;
EOT;

    TrySQL($sql, "SQL Error", $result);

*/
    echo date("Y-m-d H:i:s");
    echo "---- Generando el shape de arcos con segi y segd en {$fileName}a.dbf\n";
    $command = "{$ogr_path}/pgsql2shp -u segmentador -P rodatnemges -f $dir/{$fileName}a censo2020 shapes.\"{$fileName}a\"";
    TryExec($command, "Error", $out);

    echo date("Y-m-d H:i:s");
    echo "---- zipeando el shape de arcos {$fileName}a\n";
    $command = "zip -D -j $ficheroSubido $dir/{$fileName}a*";
    TryExec($command, "Error", $result);

    echo date("Y-m-d H:i:s");
    echo "---- Generando el shape de polígonos con segmento en {$fileName}p.dbf\n";
    $command = "{$ogr_path}/pgsql2shp -u segmentador -P rodatnemges -f $dir/{$fileName}p censo2020 shapes.\"{$fileName}p\"";
    TryExec($command, "Error", $out);

    echo date("Y-m-d H:i:s");
    echo "---- zipeando el shape de polígonos {$fileName}p\n";
    $command = "zip -D -j $ficheroSubido $dir/{$fileName}p*";
    TryExec($command, "Error", $result);

    echo "\n</pre>\n";

    //  Return the contents of the output buffer
    $htmlStr = ob_get_contents();
    // Clean (erase) the output buffer and turn off output buffering
    ob_end_clean(); 
    // Write final string to file
    file_put_contents("$dir/$fileName.log.html", $htmlStr);

    try {
        $command = "zip -D -j $ficheroSubido $dir/$fileName.log.html";
        exec($command, $out, $status);        
        if ($status !== 0)
            throw new Exception("Falló $command con status $status");
    } catch (Exception $e) {
        throw $e;
    }
    $resultado = 'ok';

    ob_end_flush();
//} catch (Exception $e) {
//    $resultado = $e->getMessage();
//}
return $resultado;   
}

?>

