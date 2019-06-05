/*
Ejemplo de numeración para CABA, cartografía cargada en carto.ecapilin.
Para que funcione la numeración, las geometrias de los arcos de ejes de calle, deben ser LineString,
en caso de haberse importado como MultiLineString, puede convertirse a LineString con la siguiente instrucción:
  ALTER TABLE carto.ecapilin ALTER COLUMN geom TYPE geometry(LineString) USING( ST_GeometryN(geom,1))
  -- Debe tenerse en cuenta que solo se tomará la primer linea del MultiLineString. 
  -- Antes comprobamos que los MultiLineString tengan una sola linea dentro:
  	 SELECT ST_NumGeometries((st_dump(geom)).geom) From carto.ecapilin WHERE ST_NumGeometries(geom)<>1
     --Debe dar 0 registros o apareceran los que no cumplan la condicion y tengan mas de una linea.
     
Luego podemos ejecutar el siguiente script que utiliza la función de numeración de shape que debe estar creada en el esquema indec     
*/
DROP TABLE IF EXISTS carto.ecapilin_numerado;
WITH numera_sql AS (SELECT * FROM indec.numeracion_shape('carto', 'ecapilin'))
SELECT 
id, a.geom, fnode_, tnode_, lpoly_, rpoly_, length, ecapi_, ecapi_id, 
a.codigo, a.nomencla, a.codigo20, ancho, a.anchomed, tipo, nombre, 
i.lado as ladoi, d.lado as ladod,
desdei, desded, hastai, hastad, mzai, mzad, 
codloc20, nomencla10, nomenclai, nomenclad,
codigoc,conteoi,conteod,codinomb
into carto.ecapilin_numerado
FROM carto.ecapilin a 
LEFT JOIN 
numera_sql i
ON a.id=split_part(i.userid,'.',4)::numeric and a.mzai=i.mza and split_part(i.userid,'.',3)='i'
LEFT JOIN 
numera_sql d
ON a.id=split_part(d.userid,'.',4)::numeric and a.mzad=d.mza and split_part(d.userid,'.',3)='d'