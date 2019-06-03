segmentación
============

## algoritmos de segmentación para el censo2020

procesar segmentación de listado de comuna11

0. crear base de datos (en localhost)  
`$ psql -c 'create database segmentacion'`

1. importar listado a PostgreSQL en el schema listados  

cargar_listado.sql  
carga el listado comuna11.dbf via
 * excel->.csv, function sql (csv->table);
 
 ó
 
 * drag & drop en QGIS
 
```
in:
listado (en .dbf)
out: 
+table comuna11

(!) TODO: out: generalizar para otras comunas/departamebnto/lo que sea
```

2. armar_lados_de_manzana.sql
genera los lado agregando ejes de calles y pequeños pedazos
agrega en arrays si tipos, codigos o calles cambian en ese lado
usa shape de comuna11
in:
e0211lin
out:
+lados_de_manzana

3. costo.sql
define los costos
out:
. function costo_segmento(
    frac integer,
    radio integer,
    segmento integer, 
    deseado integer)
. column sgm en table comuna11

4.1 cortar_greedy_por_mza.sql
con circuitos definidos por manzanas independientes
va cortando de a $d$, cantidad deseada de viviendas por segmento sin cortar piso
in:
listado table comuna11
out:
column sgm_mza_grd en comuna11

4.2 cortar_equilibrado_mza_independiente.sql
separando listado por segmentos en manzanas independientes
donde la distribución de viviendas en cada segmento en la manzana es equilibrado
y rank es el orden de visita en el segmento
in:
listado table comuna11
out:
view segmentando_equilibrado

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

7.1. cortar_greedy_por_mza.sql
con circuitos definidos por manzanas indeendientes
va cortando de a $d$, cantidad deseada de viviendas por segmento sin cortar piso
al final queda una cola de viviendas <= d

7.2. cortar_equilibrado_mza_independiente.sql
-- separando listado por segmentos en manzanas independientes
-- donde la distribución de viviendas en cada segmento en la manzana es equilibrado
-- y rank es el orden de visita en el segmento

8. manzanas_con_pocas_viviendas.sql
con menos de un mínimo de viviendas
para agrupar usando algoritmo de agregar manzanas

9. agrupar_mzas_adys.sql
genera una tabla o vista con grupos de mzas adys
setea segmento 101 para par de manzanas seleccionado para aparear


-----
. sanbox.sql
para jugar y hacer castillitos de arena para veer hacia donde ir...

. consultas.py
draft de programa python que cargue consultas de archivos

. estadisticas.sql
calculando el estado de la comuna11 y los resultados de las diferentes métodos de segmentación

. funciones.sql
funciones pra operar sobre manzanas y circuitos
