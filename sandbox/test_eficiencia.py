from segmentaciones import *
from random import *
from sys import *

n = int(argv[1])
componentes = Componentes()
for i in range(n):
    componentes.append(Componente(i, randrange(10)))
for c_i in componentes:
    r = int(random()*3) + 1
    while r > 0:
        s = int(random()*len(componentes))
        if c_i != componentes[s] and componentes[s] not in c_i.adyacentes:
            c_i.agregar_adyacencia(componentes[s])
        r = r - 1


print ('-----------------------componentes-------------')
print ('-----------------------adyacencias-------------')
for c in componentes:
    print (c.id, c.vivs)
    adys = []    
    for a in c.adyacentes:
        adys.append(a.id)
    print ('  ', adys)

print ('-----------------------segmenta----------------')
soluciones = []
segmenta(Segmentos(), componentes, soluciones)
"""
print ('-----------------------soluciones----------------')
for s in soluciones:
    print(s)

"""
print ('-----------------------unicas-------------------')
ss = []
sols = []
for sol in soluciones:
    en_set = set(map(tuple, sol))
    if en_set not in ss:
        ss.append(en_set)
        sols.append(sol)
#for sol in sols:
#    print (sol)
print (sols[0])

