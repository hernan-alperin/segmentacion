from segmentaciones import *
from random import *


"""
for i in range(3):
    componentes.append(Componente(i, randrange(10)))
for c_i in componentes:
    for c_j in componentes:
        if c_i.id != c_j.id and random() < 0.2:
            c_i.agregar_adyacencia(c_j)
"""

#componentes = [1, 2, 3, 4, 5]
#adyacencias = [(5,4), (1,2), (2,3), (3,4)]

c1 = Componente(1, 3*randrange(10))
c2 = Componente(2, 3*randrange(10))
c3 = Componente(3, 2*randrange(10))
c4 = Componente(4, 3*randrange(10))
c5 = Componente(5, 4*randrange(10))
c1.agregar_adyacencia(c2)
c2.agregar_adyacencia(c3)
c3.agregar_adyacencia(c4)
c5.agregar_adyacencia(c4)

comps = Componentes([c1, c2, c3, c4, c5])
print ('-----------------------comps--------------------------------')
print (comps)
print ('-----------------------componentes.componentes()------------')
print (comps.componentes())

sgms = comps.segmentos()

print ('-----------------------comps.segmentos() iterado------------')

for s in sgms:
    sgm = Segmento(s)
    print (sgm)

print ('-----------------------sgms---------------------------------')
print(sgms)

todos = Segmentos(sgms)
todos.ordenar()
print ('-----------------------todos-ordenados por costo -----------')
print (todos)

sg1 = Segmento([c1, c2])
print ('-----------------------sg1.componentes()--------------------')
print (sg1.componentes())

sg2 = Segmento([c3])
unos = Segmentos([sg1, sg2])


print ('-----------------------unos---------------------------------')
print (unos)
print ('-----------------------unos.componentes()-------------------')
print (unos.componentes())
print ('-----------------------unos.componentes()[0]----------------')
print (unos.componentes()[0])
print ('-----------------------unos[0][0]---------------------------')
print(unos[0][0])
print ('-----------------------unos[0][0] is c1---------------------')
print(unos[0][0] is c1)
print ('-----------------------unos.componentes()[0] is c1----------')
print(unos.componentes()[0] is c1)
print ('-----------------------unos.componentes().ids()-------------')
print (unos.componentes().ids())

resto = Componentes(set(comps) - set(unos.componentes()))
print ('---resto = Componentes(set(comps) - set(unos.componentes()))')
print ('-----------------------resto---------------------------------')
print (resto)

print ('-----------------------sgms , resto -----------------')
lista = []
for s in todos:
    lista.append([Segmento(s), Componentes(set(comps) - set(s))]) 
for [s, r] in lista:
    print (str(s) + ' - ' + str(r))

[s, r] = lista[0]
print ('-----------------------r.segmentos()------------------------')
print (r.segmentos())
print ('-----------------------2da vuelta con el 1ro----------------')
for n in r.segmentos():
    quedan = Componentes(set(r) - set(n))
    print (str(s) + ' + ' + str(n) + ' - ' + str(quedan)) 

print ('-----------------------segmenta----------------')
print (segmenta(Segmentos(), comps))

