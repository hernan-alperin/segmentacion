#!/usr/bin/python
# -*- coding: utf-8 -*-

# este programa segmenta un circuito (manzana, o secuencia de lados) con el recorrido ordenado
# sacado de una tabla sql

import sys
import psycopg2

SQLConnect = sys.argv[1]
TablaListado = sys.argv[2]
# cotas de semgmentos
Minimo, Maximo = 17, 23
if len(sys.argv) > 4:
    Minimo, Maximo = int(sys.argv[3]), int(sys.argv[4])

import urlparse # for python 3+ use: from urllib.parse import urlparse
result = urlparse.urlparse("postgresql://postgres:postgres@localhost/postgres")
username = result.username
password = result.password
database = result.path[1:]
hostname = result.hostname
 = psycopg2.connect(
    database = database,
    user = username,
    password = password,
    host = hostname
)


