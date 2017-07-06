copy (
    select dvc.*, viviendas
    from segmenta.comuna11_vivs_x_lado vivs
    join segmenta.lados_adjacentes_dvc dvc
    on depto::integer = substr(dvc.mza,3,3)::integer
    and frac::integer = substr(dvc.mza,6,2)::integer
    and radio::integer = substr(dvc.mza,8,2)::integer
    and manzana::integer = substr(dvc.mza,10,3)::integer
    and vivs.lado::integer = dvc.lado::integer
) to stdout With CSV header DELIMITER ','
;


