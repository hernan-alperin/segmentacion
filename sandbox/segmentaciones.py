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
            s += str(c) + ' '
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
                        if i in self and i not in s:
                            b = Segmento(s)
                            b.append(i)
                            b.sort(key=lambda x: x.id)
                            if b not in sgms:
                                sgms.append(b)
        return Segmentos(sgms)
    def componentes(self):
        return self


class Segmento(Componentes):
    def costo(self):
        return abs(20 - sum(c.vivs for c in self))
    def __str__(self):
        s = '['
        for c in self:
            s += str(c.id) + ' '
        s += '] ' + str(self.costo())
        return s
    def componentes(self):
        return Componentes(super().componentes())

class Segmentos(list):
    def __str__(self):
        s = '['
        for sgm in self:
            s += ' ' + str(sgm) + ' '
        s += '] ' + str(self.costo())
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

def segmenta(segmentacion, componentes, soluciones):
    if componentes == []:
        if soluciones == []:
            soluciones.append(segmentacion)
        if segmentacion.costo() < soluciones[0].costo():
            soluciones = [segmentacion]
        if segmentacion.costo() == soluciones[0].costo():
            soluciones.append(segmentacion)
        return segmentacion
    else:
        sgms = componentes.segmentos()
        sgms.ordenar()
        for s in sgms:
            segmts = Segmentos(segmentacion)
            segmts.append(s)
            nueva = segmts
            resto = Componentes(set(componentes) - set(nueva.componentes()))
            segmenta(nueva, resto, soluciones)

    
