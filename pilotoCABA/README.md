segmentación PP2 CABA
============

## algoritmos de segmentación para el censo2020

procesar segmentación de listado de viviendas

0. crear base de datos (en localhost)  
`$ psql -c 'create database segmentacion'`

1. importar listado a PostgreSQL en el schema listados  
leer instrucciones en 

esto se hace vía  
 * excel->.csv, function sql (csv->table);  ó
 * drag & drop usando QGIS  

```
in:
listado (en .dbf ó .xls(x))
out: 
+table listados.<nombre>
```

2.1 estandarizar según archivo `especificaciones`  
```
$ psql -f estadarizar.sql segmentacion
```

3.  Segmentación  
  
3.1 Segmentar usando algoritmo Equilibrado  
elijiendo la cantidad deseada de viviendas por segmento 
en la parte del código donde está indicado 
Se esatblecio a 40

separando listado por segmentos en manzanas independientes  
donde la distribución de viviendas en cada segmento en la manzana es equilibrado  
y rank es el orden de visita en el segmento  
```
psql -f segmentar_equilibrado.sql segmentacion

in:
tabla listados.<nombre>
out:
tabla segmentaciones.equilibrado con campos id, segmento
que se relaciona con listados.<nombre> via campo id
y el campo segmento contiene un identificador único
```
4. Devolución

4.1 Se hace la union de la segmentacion para con el listado para entregar
el resultado de la segmentacion mediane listado_segmentado.sql

psql -f listado_segmentado.sql segmentacion
