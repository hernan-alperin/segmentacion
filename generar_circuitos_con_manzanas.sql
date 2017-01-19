-- ordenando listado por manzana en comunas usando variable seteada en 
-- psql --set=comuna=2
-- y los numeros del listado en secuencia de recorrido
-- sigue el orden dado por clado, decrece en pares (están a la izquierda) y crece con impares (a la derecha)
-- para que el recorrido sea en sentido de las agujas del reloj

copy (
    with lados as (
        select comunas as depto
            , frac_comun as frac
            , radio_comu as radio
            , mza_comuna as mnza
            , clado as lado
            , ccodigo as cod_calle
            , cnombre as nombre
            , case when hn::integer % 2 = 0 then -hn::integer else hn::integer end as numero_con_signo
            , cuerpo
            , hp as piso
        from segmenta.comuna:comuna
        join segmenta.ecapia
        on (comuna:comuna.codigoc = ecapia.codigoc --  igual calle
            and -- la dirección está en el jeeestá  
                (case when hn::integer % 2 = 1 -- impares 
                        then hn::integer between desded and hastad
                      when hn::integer % 2 = 0 -- pares
                        then hn::integer between desdei and hastai
                end)
            )
        )

select depto, frac, radio, mnza, lado
    , cod_calle, nombre, case when numero_con_signo % 2 = 0 then (-numero_con_signo) else numero_con_signo end as numero
    , cuerpo, piso, count(*) 
from lados
group by depto, frac, radio, mnza, lado, cod_calle, nombre, numero_con_signo, cuerpo, piso
order by depto, frac, radio, mnza, lado, cod_calle, nombre, numero_con_signo
    , cuerpo, (case when piso='PB' or piso='' then 0 else piso::integer end) desc
) to stdout With CSV header DELIMITER ','
;


