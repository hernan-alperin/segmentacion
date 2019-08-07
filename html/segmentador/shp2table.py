# -*- coding: utf-8 -*-
import sys
from dao import *

data = DAO()
data.conectar()

psql_script = "" 
for line in sys.stdin:
# stdin get a pipe sql script from shp2pgsql
    line = line.replace('DROP TABLE','DROP TABLE IF EXISTS')
    line = line.replace()
    psql_script += line

#print psql_script


data.sql_script(psql_script)

