class Componente:
    def __init__(self, id, costo):
        self.id = id
        self.costo = costo
    def __str__(self):
        return str((self.id, self.costo))

class Componentes(list):
    def __str__(self):
        s = ''
        for c in self:
            s += str(c) + '\n'
        return s

    def segmentos(self, adyacencias):
        sgms = []
        for c in self:
            sgms.append([c.id])
        cantidad = 0
        while cantidad < len(sgms):
            cantidad = len(sgms)
            for c in sgms:
                for (i, j) in adyacencias:
                    if i in c and j not in c:
                        b = list(c)
                        b.append(j)
                        b.sort()
                        if b not in sgms:
                            sgms.append(b)
        return sgms


class Adyacencias(list):
    pass

from random import *

componentes = Componentes()
adyacencias = Adyacencias()

for i in range(10):
    componentes.append(Componente(i, randrange(10)))
for c_i in componentes:
    for c_j in componentes:
        if c_i.id != c_j.id and random() < 0.2:
            adyacencias.append((c_i.id, c_j.id))

sgms = componentes.segmentos(adyacencias)

print (componentes)
print (adyacencias)

for s in sgms:
    print (s, sum(c.costo for c in componentes if c.id in s))
