#!/usr/bin/python
# -*- coding: utf-8 -*-

# este programa segmenta un circuito (manzana, o secuencia de lados) con el recorrido ordenado
# sacado de una tabla sql

# hecho para ejemplo comuna11,
# TODO: generalizar

import sys
import psycopg2

TablaListado = sys.argv[1]
# cotas de semgmentos
Minimo, Maximo = 17, 23
if len(sys.argv) > 4:
    Minimo, Maximo = int(sys.argv[3]), int(sys.argv[4])

SQLConnect = psycopg2.connect(
    database = comuna11,
    user = segmentador,
    password = password,
    host = localhost
)

"""
algunos select para ir probando...

select depto, frac, radio, mnza, count(*)
from listado
-- factible TODO: revisar para caso deferente de Minimo, Maximo = 17, 23
group by depto, frac, radio, mnza
having count(*) >= 17
and count(*) not between 24 and 33
order by depto, frac, radio, mnza
;

"""


