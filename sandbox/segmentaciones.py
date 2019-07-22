"""
título: arbol_segmentaciones.py
descripción: calcula los segmentos posibles siguiendo adyacencias
para el caso de conteos o listados con manzanas con pocas viviendas
que se pasan a conteos para evitar segmentos que contengan 
listado parcial y una o más manzanas completas 
usando classes
fecha: 2019-07-13
autor: -h
"""
from operator import *
segmentacion_deseada = 40

class Componente:
    # elemento unitario o indivisible para el caso de segmentación
    # puede ser un lado o una manzana

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

    def min_id(self):
        return min(self.ids())

    def segmentos(self):
        sgms = Segmentos()
        for c in self:
            sgms.append(Segmento([c]))
        cantidad = 0
        while cantidad < len(sgms):
        # no se incrementó la cantidad de segmentos
            cantidad = len(sgms)
            for s in sgms:
                for c in s:
                    for c_i in c.adyacentes:
                        if c_i in self and c_i not in s:
                            s_mas_c_i = Segmento(s)
                            s_mas_c_i.append(c_i)
                            s_mas_c_i.ordenar()
                            if s_mas_c_i not in sgms:
                                sgms.append(s_mas_c_i)
        return sgms

    def ordenar(self):
        self.sort(key=lambda x: x.id)
        return

    def recorridos(self):
        sgms = Segmentos()
        for c in self:
            sgms.append(Segmento([c]))
        cantidad = 0
        while cantidad < len(sgms):
            cantidad = len(sgms)
            for s in sgms:
                ultimo = s[-1] # con el último arma recorridos
                for c in ultimo.adyacentes:
                    if c in self and c not in s:
                        s_mas_c = Segmento(s)
                        s_mas_c.append(c)
                        if s_mas_c not in sgms:
                            sgms.append(s_mas_c)
        return sgms

    def componentes(self):
        return self

    def mejor_costo_teorico(self):
        return (abs(mod(sum(c.vivs for c in self) - (segmentacion_deseada/2),
                        segmentacion_deseada) 
                    - (segmentacion_deseada/2)
                    )
                ) 


class Segmento(Componentes):

    def costo(self):
        return abs(segmentacion_deseada - sum(c.vivs for c in self))

    def __str__(self):
        s = '['
        for c in self:
            s += str(c.id) + ' '
        s += '] ' + str(self.costo())
        return s

    def componentes(self):
        return Componentes(super().componentes())

    def id(self):
        return self.min_id()


class Segmentos(list):

    def __str__(self):
        s = '['
        for sgm in self:
            s += ' ' + str(sgm) + ' '
        s += ('] Costo: ' + str(self.costo()) 
            + ' (Min: ' + str(self.min_costo()) 
            + ' Max: ' + str(self.max_costo()) + ')')
        return s

    def costo(self):
        return (sum(sgm.costo() for sgm in self)
                + self.max_costo() - self.min_costo())
    def max_costo(self):
        return max(sgm.costo() for sgm in self)

    def min_costo(self):
        return min(sgm.costo() for sgm in self)

    def ordenar(self):
        self.sort(key=lambda x: x.costo())
        return

    def componentes(self):
        c = Componentes()
        for sgm in self:
            for comp in sgm:
                c.append(comp)
        return c
    
    def equivalentes(self, otros):
        if len(self) != len(otros):
            return False
        self.sort(key=lambda x: x.min_id())
        otros.sort(key=lambda x: x.min_id())
        for i in range(len(self)):
            if (self[i].min_id != otros[i].min_id):
                return False
        if [s for s in self] != [s for s in otros]:
            return False
        return True
            

def segmenta(segmentacion, componentes, soluciones):
    if componentes == []:
        if soluciones == []:
            soluciones.append(segmentacion)
            print("Primero:" + str(segmentacion.costo()))
        elif segmentacion.costo() == soluciones[-1].costo():
            print(".",end='',flush=True)
            soluciones.append(segmentacion)
        elif segmentacion.costo() < soluciones[-1].costo():
            print("\nSol ant: " 
                + str(soluciones[-1].costo())
                + " Mejor: " + str(segmentacion.costo()))
            print(segmentacion)
            soluciones[:]=[segmentacion]
        return segmentacion
    else:
        if (soluciones == [] 
            or segmentacion.costo() + componentes.mejor_costo_teorico() 
                <= soluciones[-1].costo()):
            sgms = componentes.recorridos()
            sgms.ordenar()
            for s in sgms:
                segmts = Segmentos(segmentacion)
                segmts.append(s)
                nueva = segmts
                resto = Componentes(set(componentes) - set(nueva.componentes()))
                if (soluciones == [] 
                    or nueva.costo() + resto.mejor_costo_teorico() 
                        <= soluciones[-1].costo()):
                    #or any(nueva.equivalentes(s) for s in soluciones)
                    # ya explorada 
                    print(".",end='', flush=True)
                    segmenta(nueva, resto, soluciones)
