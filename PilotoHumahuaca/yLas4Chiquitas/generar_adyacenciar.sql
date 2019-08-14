drop table if exists lados_de_manzana;
-- tabla con los ejes unidos, lados duplicado y dirigidos por
-- mzad, ladod en sentido y mzai, ladoi en sentido contrario
-- para respetar regla hombro derecho
--

create view carto.arcos as
select * from e3019.arc
union
select * from e5757.arc
union
select * from e5759.arc
union
select * from e5760.arc
;



