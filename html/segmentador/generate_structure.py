# -*- coding: utf-8 -*-
import sys
from dao import *

data = DAO()
data.conectar()
data.generar_Conteos(sys.argv[1])
data.generar_Adyacencias(sys.argv[1])
