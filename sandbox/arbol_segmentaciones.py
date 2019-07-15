"""
título: arbol_segmentaciones.py
descripción: calcula los segmentos posibles siguiendo adyacencias
usando classes
fecha: 2019-07-13
autor: -h
"""

class Componente:
    def __init__(self, id, vivs):
        self.adyacentes = []
        self.id = id
        self.vivs = vivs
    def __str__(self):
        return str((self.id, self.vivs))
    def agregar_adyacencia(self, ady):
        self.adyacentes.append(ady)

class Componentes(list):
    def __str__(self):
        s = ''
        for c in self:
            s += str(c) + '\n'
        return s
    def ids(self):
        return [c.id for c in self]

    def segmentos(self):
        sgms = []
        for c in self:
            sgms.append(Segmento([c]))
        cantidad = 0
        while cantidad < len(sgms):
            cantidad = len(sgms)
            for s in sgms:
                for c in s:
                    for i in c.adyacentes:
                        if i not in s:
                            b = Segmento(s)
                            b.append(i)
                            b.sort(key=lambda x: x.id)
                            if b not in sgms:
                                sgms.append(b)
        return sgms
    def componentes(self):
        return self

class Segmento(Componentes):
    def costo(self):
        return abs(20 - sum(c.vivs for c in self))
    def __str__(self):
        s = '['
        for c in self:
            s += str(c.id) + ' '
        s += '\b] ' + str(self.costo())
        return s
    def componentes(self):
        return Componentes(super().componentes())

class Segmentos(list):
    def __str__(self):
        s = '[\n'
        for sgm in self:
            s += ' ' + str(sgm) + '\n'
        s += '\b] ' + str(self.costo())
        return s
    def costo(self):
        return sum(sgm.costo() for sgm in self)
    def ordenar(self):
        self.sort(key=lambda x: x.costo())
        return
    def componentes(self):
        c = []
        for sgm in self:
            for comp in sgm:
                c.append(comp)
        return Componentes(c)

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
print ('---------------------------comps--------------------------------')
print (comps)
print ('---------------------------componentes.componentes()---------------------------------')
print (comps.componentes())

sgms = comps.segmentos()

print ('----------------------------------')

for s in sgms:
    sgm = Segmento(s)
    print (sgm)
print ('----------------------------------')

todos = Segmentos(sgms)
todos.ordenar()
print (todos)

sg1 = Segmento([c1, c2])
print ('-----------------------sg1.componentes()-----------------')
print (sg1.componentes())

sg2 = Segmento([c3])
unos = Segmentos([sg1, sg2])


print ('-----------------------unos---------------------------------')
print (unos)
print ('-----------------------unos.componentes()-------------------')
print (unos.componentes())
print ('-----------------------unos.componentes()[0]-------------------')
print (unos.componentes()[0])
print ('----------------------------------')
print ('-----------------------unos[0][0]-------------------------------')
print(unos[0][0])
print ('-----------------------unos[0][0] is c1-------------------------------')
print(unos[0][0] is c1)

print ('-----------------------unos.componentes()[0] is c1-------------------------------')
print(unos.componentes()[0] is c1)

#print ('-----------------------unos.componentes().ids()---------------------------------')

#print (unos.componentes().ids())

resto = Componentes(set(comps) - set(unos.componentes()))
print ('-----------------------resto---------------------------------')
print (resto)
print ('----------------------------------')

