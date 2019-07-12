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
                            if b not in sgms:
                                sgms.append(b)
        return sgms

class Segmento(Componentes):
    def costo(self):
        return abs(20 - sum(c.vivs for c in self))
    def __str__(self):
        s = '['
        for c in self:
            s += str(c.id) + ' '
        s += '\b] ' + str(self.costo())
        return s

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

c1 = Componente(1, randrange(10))
c2 = Componente(2, randrange(10))
c3 = Componente(3, randrange(10))
c4 = Componente(4, randrange(10))
c5 = Componente(5, randrange(10))

c1.agregar_adyacencia(c2)
c2.agregar_adyacencia(c3)
c3.agregar_adyacencia(c4)
c5.agregar_adyacencia(c4)

componentes = Componentes([c1, c2, c3, c4, c5])

print (componentes)

sgms = componentes.segmentos()

print ('----------------------------------')

for s in sgms:
    sgm = Segmento(s)
    print (sgm)
