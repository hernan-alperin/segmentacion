#!/usr/bin/python
# -*- coding: utf-8 -*-

# este programa segmenta un circuito (manzana, o secuencia de lados) con el recorrido ordenado
# sacado de una tabla sql

# hecho para ejemplo comuna11,
# TODO: generalizar

import sys
import psycopg2

TablaListado = 'listado'
# cotas de semgmentos
Minimo, Maximo = 17, 23
if len(sys.argv) > 3:
    Minimo, Maximo = int(sys.argv[1]), int(sys.argv[2])

SQLConnect = psycopg2.connect(
    database = comuna11,
    user = segmentador,
    password = password,
    host = localhost
)

"""
algunos select para ir probando...

select comunas, frac_comun, radio_comu, mza_comuna, count(*)
from listado
-- factible TODO: revisar para caso deferente de Minimo, Maximo = 17, 23
group by comunas, frac_comun, radio_comu, mza_comuna
having count(*) >= 17
and count(*) not between 24 and 33
order by comunas, frac_comun, radio_comu, mza_comuna
;

# TODO: son tipo char, no integer, hacer ::integer de todos los campos pertinentes
# comunas, frac_comun, radio_comu, mza_comuna, clado, hn (con CASE...), hp tabién CASE x PB -> 0

with posibles as (
    select comunas, frac_comun, radio_comu, mza_comuna
    from listado
    -- factible TODO: revisar para caso deferente de Minimo, Maximo = 17, 23
    group by comunas, frac_comun, radio_comu, mza_comuna
    having count(*) >= 17
    and count(*) not between 24 and 33
    order by comunas, frac_comun, radio_comu::integer, mza_comuna::integer
    )
select comunas, frac_comun, radio_comu, mza_comuna, clado, cnombre, hn, hp, hd, row_number() 
    over (
        partition by comunas, frac_comun, radio_comu::integer, mza_comuna::integer
        order by comunas, frac_comun, radio_comu::integer, mza_comuna::integer, 
            clado, 
            case 
                when hn::integer % 2 = 1 then hn::integer
                else -hn::integer   
            end, 
            cnombre, 
            -- cuerpo, !!!! FALTA ESTE DATO Y ES IMPRESCINDIBLE EN TORRES Y CONJUNTOS DE MONOBLOCKS
            hp
        )
from listado
where (comunas, frac_comun, radio_comu, mza_comuna) in (select * from posibles)
;

"""


