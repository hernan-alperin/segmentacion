# -*- coding: utf-8 -*-
import random
import copy
# todo: ver si vale la pena cambiar a set las list para mejorar eficiencia


class Direccion(dict):

    def __init__(self, calle, codigo_calle, numero, cuerpo, piso,
                 departamento):
        pass
        #self = {calle, codigo_calle, numero, cuerpo, piso, departamento}


class Listado(list):

    def __init__(self):
        pass

    def __eq__(self, other):
        return True #TODO implementar

# no esta en uso por ahora, la agarramos después
class Lado:

    def __init__(self, codigo, manzana, conteo):
        self.codigo = codigo
        self.manzana = manzana  # mza objeto
        self.conteo = conteo
        self.adyacentes = ColeccionLados()

    def __str__(self):
        # notación codigo_manzana.codigo_lado
        return ("lado " + str(self.manzana.codigo) 
                + "." + str(self.codigo)
                + " : (" 
                + ", ".join(
                    str(lado.manzana.codigo) 
                    + "." + str(lado.codigo) 
                    for lado in self.adyacentes)
                + ") "
                + str(self.conteo))

    def es_adyacente(self, lado):
        return lado in self.adyacentes


# esta tampoco
class ColeccionLados(list):

    def __str__(self):
        # return  mza.(lados) ...
        # ejemplo 1.(1 2 3) 2.(2)
        lados = dict()
        for mza in self.manzanas():
            lados[str(mza.codigo)] = set()
            for lado in self:
                if mza.codigo == lado.manzana.codigo:
                    lados[str(mza.codigo)].add(lado.codigo)

        s = 'lados: '
        for key in lados:
            s += (key + '.('
                + " ".join(str(cod_lado) for cod_lado in lados[key]) 
                + ') ')
        return s   
         
    def __eq__(self, other):
        return (set(self.codigos_de_lados()) ==
                set(other.codigos_de_lados()))

    def codigos_de_lados(self):
        return list([(lado.manzana.codigo, lado.codigo) for lado in self])
        # get a list of pairs (cod_mza, cod_lado)

    def manzanas(self):
        # get a set of CollecionManzanas spanned by all lados
        return set(lado.manzana for lado in self)

    def lado(self, codigo_lado, codigo_mza):
        # devuelve el lado correspondiente a codigo
        if (codigo_mza, codigo_lado) in self.codigos_de_lados():
            return next(lado for lado in self
                        if lado.manzana.codigo == codigo_mza
                        # mza objeto
                        and lado.codigo == codigo_lado)
        else:
            return None

# empiezo con esta


class Manzana:

    def __init__(self, codigo, conteo):
        self.codigo = codigo
        self.conteo = conteo
        self.lados = ColeccionLados()
        self.adyacentes = ColeccionManzanas()  # manzanas adyacentes
# todo: ver si implementar usando Factory (?) (singleton)

    def __str__(self):
        return ("manzana " + str(self.codigo)
                + " : ("
                + ", ".join(
                str(mza.codigo) for mza in self.adyacentes)
                + ") "
                + str(self.conteo))

    def es_adyacente(self, mza):
        return mza in self.adyacentes


class ColeccionManzanas(list):

    def __str__(self):
        return ("Manzanas "
            "[ " + ", ".join([str(mza.codigo) for mza in self]) + " ]")

    def __eq__(self, other):
        return (set(mza.codigo for mza in self) ==
                set(mza.codigo for mza in other))

    def codigos_de_manzanas(self):
        return list([mza.codigo for mza in self])

    def manzana(self, codigo):
        # devuelve la manzana correspondiente a codigo
        if codigo in self.codigos_de_manzanas():
            return next(mza for mza in self if mza.codigo == codigo)
        else:
            return None

    def una_manzana(self):
        # devuelve una manzana cualquiera, la primera
        if self:
            return next(iter(self))
        else:
            return None

    def una_manzana_al_azar(self):
        if self:
            return random.choice(tuple(self))
        else:
            return None

    def es_adyacente(self, mzas): 
        for mza_i in self:
            for mza_j in mzas:
                if mza_j in mza_i.adyacentes:
                    return True
        return False

    def clausura_conexa(self, mza):
        # return the ColeccionManzana that can be reached from mza
        # using adyacencias
        if (not self or not mza or mza not in self):
            #print " clausura_conexa Vacio!"
            return None  # caso seguro
        else:
            clausura = ColeccionManzanas([mza])  # at least contains mza,
            # build as list to go thru expanding adyacencias
            for mza_i in clausura:
                ady_i = set(mza_i.adyacentes)
                ady_i_sgm = ady_i.intersection(set(self))
                nuevas = list(ady_i_sgm.difference(set(clausura)))
                clausura.extend(nuevas)
            #    print " clausura_conexa " + str(mza_i)
            return clausura

    def conectadas(self):
        # return the ColeccionManzanas is connected, 
        # no unreachable parts thru adyacencies,
        una = self.una_manzana()
        if una:
            return len(self.clausura_conexa(una)) == len(self)
        else:
        # una is any manzana, True if oleccionManzanas is empty
            return True

    def partes_conexas(self):
        # get all the connected CollecionManzanas within it
        if self.conectado():
            return list(self)
        else:
            partes = list()
            mza = self.una_manzana()
            while mza:
                clausura = self.clausura_conexa(mza)
                partes.append(clausura)
                for mza in clausura:
                    self.remove(mza) # efectos colaterales (?)
                mza = self.una_manzana()
            return partes



