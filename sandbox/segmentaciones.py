# -*- coding: utf-8 -*-
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
import logging

segmentacion_deseada = 40

class Procesando:
        
    def __init__(self):
        self.reloj = '-'

    def proximo(self):
        if self.reloj == '-':
            self.reloj = '\\'
        elif self.reloj == '\\':
            self.reloj = '|'
        elif self.reloj == '|':
            self.reloj = '/'
        elif self.reloj == '/':
            self.reloj = '-'
        return self.reloj

def set_segmentacion_deseada(valor):
    global segmentacion_deseada
    segmentacion_deseada = int(valor)

class Componente:
    # elemento unitario o indivisible para el caso de segmentación
    # puede ser un lado o una manzana

    def __init__(self, c_id, vivs=0, longitud=0):
        self.adyacentes = []
        self.c_id = c_id
        self.vivs = vivs
        self.longitud = longitud

    def __str__(self):
        return str((self.c_id, self.vivs))

    def agregar_adyacencia(self, ady):
        self.adyacentes.append(ady)

    def adyacencias(self):
        return self.adyacentes

    def get_type(self):
        pass

class Lado(Componente):

    def get_manzana(self):
        pass

class Manzana(Componente):

    def get_lados(self):
        pass

class Componentes(list):

    """
    TODO:
    definir 
    lo_mismo
    igual
    identico
    """

    def __str__(self):
        s = '['
        for c in self:
            s += str(c) + ', '
        return s[:-2] + ']'

    def ids(self):
        return set(c.c_id for c in self)

    def min_id(self):
        return min(self.ids())

    def clausura_conexa(self, este):
        # devuelve todos los Componentes alcanzables desde este usando adyacencias
        if este not in self:
            return Componentes() # vacio, caso seguro
        else:
            clausura = Componentes([este]) # contiene al menos a este
            i = 0
            while i < len(clausura): # i es el puntero lo que que falta expandir
                # i se incrementa de a 1 expandiendo de a 1 las adyacencias
                # hasta que la variable clausura no se expande más,
                # queda en un puntos fijo, i.e. es una clausura
                adyacentes_i = [ese for ese in clausura[i].adyacencias() if ese in self]
                # los adyacentes a la i-ésimo elemento de la clausura que están en la coleccion
                nuevos = Componentes([ese for ese in adyacentes_i if ese not in clausura]) # no agragados aún
                clausura.extend(nuevos) # se agregan al final las adyacencias no agregadas
                i = i + 1
            return Componentes(clausura).ordenado()
            
    def conectados(self):
        # True si desde el primero se puede llagar a todos los otros
        # a través de adyacencias
        return any([len(self.clausura_conexa(uno)) == len(self) for uno in self])
    
    def extraer_componente(self, este):
        # devuelve las partes de Componentes conexas originales resultado de remover la manzana m del segmento
        if este not in self:
            return []
        else:
            esos = Componentes(self) # copia para no modificar el original
            esos.remove(este)
            partes = Componentes()
            while esos: # es no vacia
                ese = esos[0] # se elige uno cualquiera, se usa el 1ro
                clausura_de_ese_en_esos = esos.clausura_conexa(ese)
                for aquel in clausura_de_ese_en_esos:
                    if aquel not in esos: # (?) cómo puede ser?????
                #        pass
                        raise Exception("elemento " + str(aquel) + " no está en " + str(esos)
                            + "\nclausura_de_ese_en_esos " + str(clausura_de_ese_en_esos))
                    else:  # para que no se rompa acá....
                        esos.remove(aquel) # en esos queda el resto no conexo a aquel
                partes.append(clausura_de_ese_en_esos)
            return Segmentos(partes).ordenados()

    def transferir_componente(self, este, esos):
        # transferir este del segmento origen al los Componentes esos
        # devuelve una lista con a lo sumo 2 elementos ... los nuevos estos y esos
        if este not in self: # no se puede transferir un elemento que no esté
            return False
        elif not Componentes([este] + esos).conectados(): # no se puede transferir si no es adyacente
            return False
        elif len(self) == 1: # no queda resto, se fusiona origen con destino
            return Segmentos([Componentes(esos + [este]).ordenado()])
        else:
            estos = self.extraer_componente(este)
            print(estos)
            aquellos = Componentes(esos + [este]).ordenado()
            return Segmentos(estos + [aquellos]).ordenados()
    
    def unir_componentes(self, esos):
    # fusión Componentes con esos si algun elemento es adyacente con otro de esos, o viceversa
        if Componentes(self + esos).conectados():
            return Componentes(self + esos)
        else:
            return False
    
    def segmentos(self):
        # todos los segmento posibles respetando adyacencias
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
        self.sort(key=lambda x: x.c_id)
        return

    def ordenado(self):
        # devuelve una copia del segmento con sus componentes ordenados por id
        copia = Segmento(self)
        copia.sort(key=lambda x: x.c_id)
        return copia

    def recorridos(self, 
        hasta=max(1.5*segmentacion_deseada, segmentacion_deseada + 4),
        desde=min(0.5*segmentacion_deseada, segmentacion_deseada - 4)):
        sgms = Segmentos()
        for c in self:
            sgms.append(Segmento([c]))
        cantidad = 0
        while cantidad < len(sgms):
            cantidad = len(sgms)
            for s in sgms:
                ultimo = s[-1] # con el último arma recorridos
                for c in ultimo.adyacentes:
                    if (c in self and c not in s
                        and c.vivs + s.costo() < hasta):
                        s_mas_c = Segmento(s)
                        s_mas_c.append(c)
                        if s_mas_c not in sgms:
                            sgms.append(s_mas_c)
        for s in sgms:
            if s.costo()<desde:
                sgms.remove(s)
            return Segmentos(sgms)

    def componentes(self):
        # devuelve los componentes ordenados
        return self

    def manzanas(self):
        return len(list(set([c.c_id/10 for c in self.componentes()])))

    def mejor_costo_teorico(self):
        return (1.1*abs(mod(sum(c.vivs for c in self) - (segmentacion_deseada/2),
                        segmentacion_deseada) 
                    - (segmentacion_deseada/2)
                    )
                + 0.01*self.manzanas()) 


class Segmento(Componentes):
    # de alguna forma Componentes deben estar conexos

    def carga(self):
        return sum(c.vivs for c in self)

    def longitud(self):
        return sum(c.longitud for c in self)    

    def costo(self):
        return abs(self.carga()) - segmentacion_deseada

    def __str__(self):
        s = '['
        for c in self:
            s += str(c.c_id) + ' '
        s += '] ' + str(self.carga())
        return s

    def componentes(self):
        # devuelve su lista de componentes
        return Componentes(super().componentes())

    def s_id(self):
        return self.min_id()

    def equivalente(self, otro):
        # devuelve verdadero si tiene los mismos componentes
        return set(self.componentes()) == set(otro.componentes())

    def extraer_componente(self, este):
        return super().extraer_componente(este) 

    def tranferir_componente(self, este, esos):
        return super().tranferir_componente(este, esos)

    def unir_segmentos(self, otro):
        return super().unir_segmentos(otro)

class Segmentos(list):

    def __str__(self):
        s = '['
        for sgm in self:
            s += ' ' + str(sgm) + ' '
        s += ('] Costo: ' + str(self.costo()) 
            + ' (Min: ' + str(self.min_carga()) 
            + ' Max: ' + str(self.max_carga()) + ')')
        return s

    def suma_de_costos_de_segmentos(self):
        return sum(sgm.costo() for sgm in self)

    def maxima_diferencia_de_costos_entre_segmentos(self):
        return self.max_carga() - self.min_carga()

    def suma_cantidad_de_mzas_x_sgm(self):
        return sum(s.manzanas() for s in self)

    def costo(self):
        return (self.suma_de_costos_de_segmentos()
                + 0.1*(self.maxima_diferencia_de_costos_entre_segmentos())
                + 0.01*self.suma_cantidad_de_mzas_x_sgm())

    def max_carga(self):
        return max(sgm.carga() for sgm in self)

    def min_carga(self):
        return min(sgm.carga() for sgm in self)

    def ordenar(self):
        # ordena el conjunto de segmentos segun sus costos y lo devuelve
        self.sort(key=lambda x: x.costo())
        return self

    def componentes(self):
        # devuelve la lista de componentes del conjunto de segmentos
        return [c for s in self for c in s.componentes()]

    def equivalentes(self, otros):
        # para unificar circuitos
        # define equivalencia entre conjunto de segmentos
        # 1. tienen la misma cantidad de elementos
        # 2. las secuencias ordenadas de segmentos 
        # de self y otros son equivalentes uno a uno
        if len(self) != len(otros):
            return False
        self.sort(key=lambda x: x.min_id())
        otros.sort(key=lambda x: x.min_id())
        for i, s in enumerate(self):
            if (not s.equivalente(otros[i])):
                return False
        return True

    def ordenados(self):
        # devuelve una copia con los segmentos ordenada por min_id
        ordenados = Segmentos(self)
        ordenados.sort(key=lambda s: s.min_id())
        return ordenados


class Segmentacion(Segmentos):

    def __str__(self):
        ss = '['
        for sgms in self:
            ss += ' ' + str(sgms) + ' '
        ss += (']')
        return ss

    def ordenada(self):
        # devuelve una copia con la segmentacion ordenada por min_id
        return self.ordenados()

    def canonica(self):
        # devuelve una forma unica de representar segmentacion
        # con los segmentos ordenados por min_id
        # y los componentes ordenados por id dentro de cada segmento
        una = Segmentacion()
        for sgm in self:
            s = sgm.ordenado()
            una.append(s)
        return una.ordenada()

    def equivalente(self, otra):
        return super().equivalentes(otra)

    # definicón del vecindario de una segmentacíon para definir y recorrer la red de segementaciones
    # vecindario devuelve array de vecinos usando extraer y transferir
    def vecindario(self):
        # devuelve list de vecinos
        vecindario = Segmentaciones()
        for segmento in self:
            # extraer_componente
            otros = list(self) # hace una copia
            otros.remove(segmento) # el resto no considerado de la segmentación
            if len(segmento) == 2: # segmento binario se parte, no se analizan los 2 casos, ya que son el mismo
                este = segmento[0]; ese = segmento[1]
                vecino = Segmentacion([[este], [ese]] + otros)
                vecindario.append(vecino)
            elif len(segmento) > 2:
                for este in segmento:
                    vecino = Segmentacion([[este]] + segmento.extraer_componente(este) + otros)
                    vecindario.append(vecino)
            logging.info('segmento: ' + str(segmento) + ' -> vecino :' + str(vecino))
            # transferir_componente
            if len(self) >= 2: # se puede hacer una transferencia o fusion
                for i, este in enumerate(self):
                    sin_este = list(self) # copia para preservar la original
                    sin_este.remove(este) # elimino de la copia de la segmentacion a este segmento
                    for j, ese in enumerate(sin_este): # busco otro segmento
                        otros = list(sin_este) # copia de para eliminar a ese
                        otros.remove(ese) # copia de segmentacion sin este ni ese
                        if len(este) == 1 and len(ese) == 1 and i < j:
                            pass # si no se repiten cuando este y ese se permuten
                        else:
                            for cada in este:
                                transferencia = este.transferir_componente(cada, ese)
                                if transferencia: # se pudo hacer
                                    vecino = Segmentacion(transferencia + otros)
                                    vecindario.append(vecino)
                        # unir_componentes de 2 segmentos evitando repeticiones
                        #(cuando alguno es un solo elemento la fusion es considerada en la transferencia)
                        vecino = Segmentacion([este.unir_componentes(ese)] + otros)
                        vecindario.append(vecino) # analizar fusiones
        return vecindario


class Segmentaciones(list):

    def diferentes(self):
        # devuelve las segmentaciones que tienen una única
        # representación canónica
        lista = Segmentaciones()
        for i, s_i in enumerate(self):
            esta = False
            for s_j in lista:
                if s_i.equivalentes(s_j):
                    esta = True
            if not esta:
                lista.append(s_i)    
        return lista

    def ultima(self):
        if self:
            return self[-1]
        return None

    def __str__(self):
        ss = '['
        for sgms in self:
            ss += ' ' + str(sgms) + ' '
        ss += ('] Costo: ' + str(self.costo()))
        return ss

          
reloj = Procesando()

def segmenta(segmentacion, componentes, soluciones):
    if componentes == Componentes():
        if (soluciones == Segmentaciones()
            # no encontró soluciones aún, segmentación es la primera
            or segmentacion.costo() == soluciones.ultima().costo()
            # el costo de la segmentacion es igual al de la ultima
                and segmentacion.canonica() not in soluciones.diferentes()):
                # y no está entre las soluciones diferentes (en el grupo de equivalentes)
            #print(len(soluciones),end='',flush=True)
            print('\b'*(len(str(len(soluciones) - 2)) + 2) + str(len(soluciones)) + ' ',end='',flush=True)
            soluciones.append(segmentacion.canonica())
        elif segmentacion.costo() < soluciones.ultima().costo():
            # mejora el costo
            print("\nSol ant: " 
                + str(soluciones.ultima().costo())
                + " Mejor: " + str(segmentacion.costo()))
            print(segmentacion.canonica())
            soluciones[:]=Segmentaciones([segmentacion.canonica()])
        return

    else:
        if (soluciones == Segmentaciones() 
            or segmentacion.costo() + componentes.mejor_costo_teorico() 
                <= soluciones.ultima().costo()):
            sgms = componentes.recorridos(44,36)
            sgms.ordenar()
            for s in sgms:
                segmts = Segmentacion(segmentacion)
                segmts.append(s)
                nueva = segmts
                resto = Componentes(set(componentes) - set(nueva.componentes()))
                if (soluciones == [] 
                    or nueva.costo() + resto.mejor_costo_teorico() 
                        <= soluciones.ultima().costo()):
                    print("\b\b" + ' ' + reloj.proximo(),end='', flush=True)
                    segmenta(nueva, resto, soluciones)
