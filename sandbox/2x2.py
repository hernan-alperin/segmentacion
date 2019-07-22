"""
ejemplo de 2 x 2 manzanas
con componentes lados

 +--11--+ +--21--+
 |      | |      |
 14    12 24    22
 |      | |      |
 +--13--+ +--23--+

 +--31--+ +--41--+
 |      | |      |
 34    32 44    42
 |      | |      |
 +--33--+ +--43--+

"""
from segmentaciones import *
from random import *

c11 = Componente(11, randrange(20))
c12 = Componente(12, randrange(20))
c13 = Componente(13, randrange(20))
c14 = Componente(14, randrange(20))
c21 = Componente(21, randrange(20))
c22 = Componente(22, randrange(20))
c23 = Componente(23, randrange(20))
c24 = Componente(24, randrange(20))
c31 = Componente(31, randrange(20))
c32 = Componente(32, randrange(20))
c33 = Componente(33, randrange(20))
c34 = Componente(34, randrange(20))
c41 = Componente(41, randrange(20))
c42 = Componente(42, randrange(20))
c43 = Componente(43, randrange(20))
c44 = Componente(44, randrange(20))

# doblar
c11.agregar_adyacencia(c12)
c12.agregar_adyacencia(c13)
c13.agregar_adyacencia(c14)
c14.agregar_adyacencia(c11)

c21.agregar_adyacencia(c22)
c22.agregar_adyacencia(c23)
c23.agregar_adyacencia(c24)
c24.agregar_adyacencia(c21)

c31.agregar_adyacencia(c32)
c32.agregar_adyacencia(c33)
c33.agregar_adyacencia(c34)
c34.agregar_adyacencia(c31)

c41.agregar_adyacencia(c42)
c42.agregar_adyacencia(c43)
c43.agregar_adyacencia(c44)
c44.agregar_adyacencia(c41)

# volver
c12.agregar_adyacencia(c24)
c24.agregar_adyacencia(c12)

c13.agregar_adyacencia(c31)
c31.agregar_adyacencia(c13)

c23.agregar_adyacencia(c41)
c41.agregar_adyacencia(c23)

c32.agregar_adyacencia(c44)
c44.agregar_adyacencia(c32)

# cruzar
c11.agregar_adyacencia(c21)
c23.agregar_adyacencia(c13)
c31.agregar_adyacencia(c41)
c43.agregar_adyacencia(c33)

c34.agregar_adyacencia(c14)
c12.agregar_adyacencia(c32)
c44.agregar_adyacencia(c24)
c22.agregar_adyacencia(c42)

componentes = Componentes([
  c11,       c21,
c14, c12, c24,  c22,
  c13,       c23,

  c31,       c41,
c34, c32, c44,  c42,
  c33,       c43,
])
print ('---------------componentes-con-adyacencias---')
for c in componentes:
    adys = []
    for a in c.adyacentes:
        adys.append(a.id)
    print (c.id, '(', c.vivs,')', adys)

print ('-----------------------segmenta----------------')
soluciones = []
segmenta(Segmentos(), componentes, soluciones)
print ('\n-----------------------unicas-------------------')
sol = []
sols = []
"""
for s in soluciones:
    en_set = set(map(tuple, s))
    if en_set not in sol:
        sol.append(en_set)
        sols.append(s)
for sol in sols:
    print (sol)
"""
unicas = [soluciones[0]]
for s in soluciones:
    vista = False
    for una in unicas:
        if s.equivalentes(una):
            vista = True
            break
    if not vista:
        unicas.append(s)
for u in unicas:
    print(u)



