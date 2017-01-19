# adjacentes en csv
psql -c "copy (select * from segmenta.manzanasAdjacentes) to stdout With CSV header DELIMITER ','"
#
