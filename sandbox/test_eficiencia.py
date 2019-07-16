from segmentaciones import *
from random import *
from sys import *

n = int(argv[1])
componentes = Componentes()
for i in range(n):
    componentes.append(Componente(i, randrange(10)))
for c_i in componentes:
    for c_j in componentes:
        if c_i.id != c_j.id and random() < 3.0/n:
            c_i.agregar_adyacencia(c_j)


print ('-----------------------segmenta----------------')
soluciones = []
print (segmenta(Segmentos(), componentes, soluciones))
print ('-----------------------soluciones----------------')
for s in soluciones:
    print(s)

print ('-----------------------unicas-------------------')
ss = []
sols = []
for sol in soluciones:
    en_set = set(map(tuple, sol))
    if en_set not in ss:
        ss.append(en_set)
        sols.append(sol)
for sol in sols:
    print (sol)


