segmentación
============

## algoritmos de segmentación para el censo2020

procesar segmentación de listado de viviendas

0. crear base de datos (en localhost)  
`$ psql -c 'create database segmentacion'`

1. importar listado a PostgreSQL en el schema listados  
vía  
cargar_listado.sql  
 * excel->.csv, function sql (csv->table);  
 ó  
 * drag & drop usando QGIS  
```
in:
listado (en .dbf ó .xls(x))
out: 
+table listados.<nombre>
```

2.1 estandarizar según archivo `especificaciones`  
```
$ psql -f estadarizar.sql
```
2.2 masajear los datos para que funciones los algorimos  
```
$ psql -f masajear.sql
```

3.  
Instrucciones:  
edite  
`segmentar_equilibrado.sql`, o  
`segmentar_equilibrado.sql`  
elijiendo la cantidad deseada de viviendas por segmento  
en la parte del código donde está indicado  
3.1 Segmentar usando algoritmo greedy  
Circuitos definidos por manzanas independientes  
cortan de a _d_, cantidad deseada de viviendas por segmento sin cortar piso  
```
psql -f segmentar_greedy.sql

in:
tabla listados.<nombre>
out:
tabla segmentaciones.<nombre>_greedy con campos id, segmento
que se relaciona con listados.<nombre> via campo id
y el campo segmento contiene un identificador único
```
3.2 Segmentar usando algoritmo Equilibrado  
separando listado por segmentos en manzanas independientes  
donde la distribución de viviendas en cada segmento en la manzana es equilibrado  
y rank es el orden de visita en el segmento  
```
psql -f segmentar_equilibrado.sql

in:
tabla listados.<nombre>
out:
tabla segmentaciones.<nombre>_equilibrado con campos id, segmento
que se relaciona con listados.<nombre> via campo id
y el campo segmento contiene un identificador único
```

Hasta acá está hecho (verificar descripción y comandos)
---------------------------------------------

4. armar_lados_de_manzana.sql

genera los lado agregando ejes de calles y pequeños pedazos  
agrega en arrays si tipos, codigos o calles cambian en ese lado  
usa shape de 
in:
e0211lin
out:
+lados_de_manzana

(?). costo.sql
define los costos
out:
. function costo_segmento(
    frac integer,
    radio integer,
    segmento integer, 
    deseado integer)
. column sgm en table comuna11

5. hacer_adyacencias_lados.sql
consultas sql
out: 
table grafo_adyacencias_lados
. un Grafo G(v,e,t), donde (v son ids independientes del nomenclador)
 v representan a lados de manzana
 e = (v_i, v_j, t)
 t el tipo de acción del censista {doblar, volver, cruzar}

6. hacer_adyacencias_mzas.sql
in:
table grafo_adyacencias_lados
out:
table adyacencias_mzas (usa nomenclador frac | radio | mza | lado | mza_ady | lado_ady | lado_id | ady_id | tipo_ady)
con _id de grafo_adyacencias_lados

8. manzanas_con_pocas_viviendas.sql
con menos de un mínimo de viviendas
para agrupar usando algoritmo de agregar manzanas

9. agrupar_mzas_adys.sql
genera una tabla o vista con grupos de mzas adys
setea segmento 101 para par de manzanas seleccionado para aparear
