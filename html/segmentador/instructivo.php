<p>Subir un archivo eAAAA.zip, ebDDD.zip, epDDD.zip, o ecapi.zip; que tiene que ser .zip y NO .arj
(Se puede usar el arj para crearlo, pero hay que prender la opción que compacte a formato zip).
Los 4 casos son:
<ul>
    <li>bDDD para los partidos del GBA con código DDD, 
    <li>pDDD para los partidos del Gran La Plata, 
    <li>capi en el caso de CABA, o
    <li>AAAA es el código de aglomerado para el resto de los casos;
</ul></p>
<p>
por ej. salvo para GBA, Gran La Plata ó CABA; 
ese archivo debe llamarse eAAAA.zip (dónde AAAA lo identifica por cobertura de aglomerado) 
y contener al menos los siguientes archivos
<ul>
    <li>eAAAAa.shp, y  eAAAAa.dbf,
    <li>eAAAAp.shp, y  eAAAAp.dbf, y
    <ul>
        <li>eAAAAd.shp, y eAAAAd.dbf, o
        <li>eAAAAd.csv 
    </ul>
</ul></p>
<p>siendo
<ul>
    <li>eAAAAa.* los archivos del shape de arcos o ejes, y
    <li>eAAAAp.* los de polígonos o manzanas,
    <li>eAAAAd.* los de los puntos geocodificados correspondientes a las direcciones del listado si lo hubiese, o
    <li>eAAAAd.csv el listado de direcciones en formato separado por comas con el siguiente encabezado (bla,bla,bla...); 
</ul></p>

<p>Requisitos:
El archivo *.dbf de arcos o ejes debe contener, al menos, los campos o las columnas de:
    conteoi, conteod, mzai, mzad, ladoi, y ladod
</p>
<p>donde
 los campos o columnas de conteo por lado, que son:
<ul>
    <li>conteoi, y conteod; 
</ul>
 deben ser de tipo integer y referir a la cantidad de viviendas por lado de manzana;
</p>
<p>
 y los campos o columnas identificadores de código de manzana, que son:
<ul>
    <li>mzai, mzad; 
</ul>
 (por manzana a izquierda y derecha de cada eje/arco respectivamente), 
 deben estar en formato char(15) PPDDDLLLFFRRMMM, 
 dónde las mayúsculas corresponden respectivamente, a los códigos
<ul>
    <li>PP (2) provincia
    <li>DDD (3) departamento/partido/comuna
    <li>LLL (3) localidad
    <li>FF (2) fracción
    <li>RR (2) radio
    <li>MMM (3) manzana
</ul></p>
<p>y los campos identificadores de lado, que son: 
<ul>
    <li>ladoi, ladod;
</ul>
 deben ser de tipo integer y referir a los códigos de lados a izquierda y derecha respectivamente de cada eje/arco.
</p>


