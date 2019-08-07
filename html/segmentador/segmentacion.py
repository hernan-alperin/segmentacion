# -*- coding: utf-8 -*-
import random
#TODO: ver si vale la pena cambiar a set las list para mejorar eficiencia
from componentes import (Listado, Lado, ColeccionLados, 
    Manzana, ColeccionManzanas)

class Segmento():

# hereda de ColeccionManzanas que es lis
# TODO quiero agregar atrubutos como codigo (?)

    def __init__(self, manzanas=[], lados=[], listado=None):
        self.manzanas = ColeccionManzanas(manzanas)
        self.lados = ColeccionLados(lados)
        self.listado = listado

    def __str__(self):
        descripcion = str(self.carga()) + " viviendas"
        if self.manzanas:
            descripcion += (", manzanas : ("
                + ", ".join(str(mza.codigo) for mza in self.manzanas)
                + ") ")
        if self.lados:
            descripcion += (", lados : "
                + ", ".join(str(lado.codigo) for lado in self.lados)
                + ") ")
                #TODO representar como partes de manzana                
            
        return descripcion

    def __eq__(self, other):
        return (self.manzanas == other.manzanas
            and self.lados == other.lados
            and self.listado == other.listado)

    def __neq__(self, other):
        return not(self == other)

    def __contains__(self, elem):
        if isinstance(elem, Manzana):
            return elem in self.manzanas
        elif isinstance(elem, Lado):
            return (elem in self.lados
                    or elem.manzana in self.manzanas)
        else:
            raise RuntimeWarning(
                'tipo ' + elem.__class__.__name__ + ' extraño')

    def __copy__(self):
        manzanas = (mza for mza in self.manzanas)
        lados = (lado for lado in self.lados)
        return Segmento(manzanas, lados, self.listado)

    def copia(self):
        manzanas = list(self.manzanas)
        lados = list(self.lados)
        return Segmento(manzanas, lados, self.listado)


    def manzana(self, codigo):
        return self.manzanas.manzana(codigo)

    def una_manzana(self):
        return self.manzanas.una_manzana()

    def una_manzana_al_azar(self):
        return self.manzanas.una_manzana_al_azar()

    def append(self, elem):
        if isinstance(elem, Manzana):
            if elem not in self.manzanas:
                self.manzanas.append(elem)
        elif isinstance(elem, Lado):
            if elem not in self.lados:
                self.lados.append(elem)
        else:
            raise RuntimeWarning(
                'tipo ' + elem.__class__.__name__ + ' extraño')
        return self

    def extend(self, sgm): # need not to be conectec
        self.manzanas.extend(sgm.manzanas)
        self.lados.extend(sgm.lados)
        self.listado.extend(sgm.listado)

    def remove(self, elem):
        if isinstance(elem, Manzana):
            self.manzanas.remove(elem)
        elif isinstance(elem, Lado):
            self.lados.remove(elem)
        else:
            raise RuntimeWarning(
                'tipo ' + elem.__class__.__name__ + ' extraño')
        return self


    def carga(self):
        return sum(mza.conteo for mza in self.manzanas)
        # TODO lados y listados

    VIVIENDAS_DESEADAS = 150
    MAXIMO_VIVIENDAS = 250
    MINIMO_VIVIENDAS = 130

    def costo(self):
        # hacer según definición de costo en cada caso
        carga = self.carga()
        if carga > Segmento.MAXIMO_VIVIENDAS:
            # la carga es mayor el costo es el cubo
            return ((carga - Segmento.MAXIMO_VIVIENDAS)**2
                    + abs(carga - Segmento.VIVIENDAS_DESEADAS))
        elif carga < Segmento.MINIMO_VIVIENDAS:
            # la carga es menor el costo es el cuadrado
            return ((Segmento.VIVIENDAS_DESEADAS - carga)**2
                    + abs(carga - Segmento.VIVIENDAS_DESEADAS))
        else:  # está entre los valores deseados
            # el costo el la diferencia absoluta al valor esperado
            return abs(
                carga - Segmento.VIVIENDAS_DESEADAS)

    def es_adyacente(self, sgm): #TODO incorporar lados
        for mza_i in self.manzanas:
            for mza_j in sgm.manzanas:
                if mza_j in mza_i.adyacentes:
                    return True
        return False


class ColeccionSegmentos(list):
    # cannot use set of set, now all implemented as list mutable => unhashable

    def __str__(self):
        return ("Segmentos [\n "
                + ("\n ".join(str(i + 1) 
                    + ": " + str(s) for i, s in enumerate(self)))
                + "\n]")
        #TODO imprimir el número de serie como código

    def __eq__(self, other):
        return (all(sgm in other for sgm in self) 
            and all(sgm in self for sgm in other))

    def __contains__(self, sgm):
        return any(sgm == smgn for smgn in self)


class Segmentacion(ColeccionSegmentos):

    def costo(self):
        return sum(sgm.costo() for sgm in self)

    def extraer_mza(self, mza, sgm):
        # extract the mza from the sgm
        # return a collection of clausura_conexa result of removing
        # the manzana from the segmento plus the rest of untouched segmentos
        # does not modify self nor sgm
        #print "\n\n-------------------\nextraer_mza(self, mza, sgm) : "
        #print ("self " + str(self))
        #print ("mza " + str(mza))
        #print ("sgm " + str(sgm))
        #print ("costo " + str(sgm.costo()))
        if (not self
            or sgm not in self
            or mza not in sgm.manzanas
            or len(sgm.manzanas) == 1):
            return None
        #    print "None (!)"
        else:
            sgmn = sgm.copia()
            sgmns = Segmentacion(sgmn for sgmn in self if sgmn is not sgm)
        #    print " sgmn = sgm.copia() : " + str(sgmn)
            sgmn.remove(mza)
            sgmns.append(Segmento([mza]))
            if sgmn.partes_conexas():
                print " Hay partes_conexas :-)"
                print "sgmn.partes_conexas() " + str(sgmn.partes_conexas())
                sgmns.extend(sgmn.partes_conexas())
        #    else:
        #       print " OJO! no hay partes_conexas >:-("
        #   print "sgmns " + str(sgmns)
        #   print "sgmns.costo " + str(sgmns.costo())
            return sgmns   

    def transferir_mza(self, mza, sgm_from, sgm_to):
        # transfer the mza from sgm_from segmento to sgm_to segmento
        # return a collection of clausura_conexa result of the tranfer:
        if (not self or not sgm_from or not sgm_to or not mza
            or not sgm_from in self or not sgm_to in self
            or mza not in sgm_from.manzanas
            or not sgm_to.es_adyacente(sgm_from)):
            return None
        else:
            sgmns = Segmentacion(sgmn for sgmn in self 
                    if sgmn != sgm_from and sgmn != sgm_to)
            sgmn_from = sgm_from.copia()
            sgmn_to = sgm_to.copia()
            if len(sgm_from.manzanas) > 1:
                # merge with destination
                sgmn_from.remove(mza)           
                sgmns.append(sgmn_from)
            sgmn_to.append(mza)
            sgmns.append(sgmn_to)
            #print sgmn_from, sgmn_to, sgmns
            return sgmns

    def fusionar(self, sgm_i, sgm_j):
        # join segmento sgm_i with segmento sgm_j
        if not sgm_i.es_adyacente(sgm_j):
            return None
        else:
            sgmns = Segmentacion(sgmn for sgmn in self
                    if sgmn != sgm_i and sgmn != sgm_j)
            sgmn = sgm_i.copia()
            for mza in sgm_j.manzanas:
                if mza not in sgm_i:
                    sgmn.append(mza)
            for lado in sgm_j.lados:
                if lado not in sgm_i:
                    sgmn.append(lado)
            sgmns.append(sgmn)
        return sgmns

    def vecindario(self):
        # return an array with all possible Segmentacion that can
        # be reached from the current one by applying the
        # basic operations over all its Segmentos
        vecinos = ColeccionSegmentaciones()
        for sgm in self:
            for mza in sgm.manzanas:
                sgms = self.extraer_mza(mza, sgm)
                if sgms: 
                    vecinos.append(sgms)
                    print sgms
        print "--------"
        for sgm_i in self:
            for sgm_j in self:
                sgms = self.fusionar(sgm_i, sgm_j)
                if sgms:
                    vecinos.append(sgms)
                for mza in sgm_i.manzanas:
                    sgms = self.transferir_mza(mza, sgm_i, sgm_j)
                    if sgms:
                        vecinos.append(sgms)
        return vecinos


class ColeccionSegmentaciones(list):

    def __str__(self):
        s = ''
        for sgms in self:
            for sgm in sgms:
                s += ("("
                    + " ".join(str(mza.codigo) for mza in sgm.manzanas)
                    + ") ")
            s += "\n"
        return s

    def mejor(self, costo):
        pass

    def __contains__(self, sgms):
        return any(sgms == smgsn for smgsn in self)

    def unicas(self):
        res = ColeccionSegmentaciones()
        for sgms in self:
            if sgms not in res:
                res.append(sgms)
        return res




