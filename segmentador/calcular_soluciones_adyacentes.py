/*
titulo: calcular_soluciones_adyacentes.py
descripción: define las funciones de operacion entre soluciones
para calcular las segmentaciones/soluciones adyacentes
autor: -h
fecha: 2019-05-09 Ju

#definición de funciones de adyacencia y operaciones sobre manzanas

*/


def son_adyacentes(este, aquel):
    return aquel in adyacentes[este]

# calcula el componente conexo que contiene a este,
# para calcular las componentes conexas o contiguas luego de una extracción
def clausura_conexa(este, esos):
    # se puede ir de este a ese para todo ese en esos
    if este not in esos:
        return [] # caso seguro
    else:
        clausura = [este] # al menos contiene a este
        i = 0
        while i < len(clausura): # i es el puntero lo que que falta expandir
            # i se incrementa de a 1 expandiendo de a 1 las adyacencias
            # hasta que la variable clausura no se expande más,
            # queda en un puntos fijo, i.e. es una clausura
            adyacentes_i = [ese for ese in adyacentes[clausura[i]] if ese in esos]
            # los adyacentes a la i-ésimo elemento de la clausura que están en la coleccion
            nuevos = [ese for ese in adyacentes_i if ese not in clausura] # no agragados aún
            clausura.extend(nuevos) # se agregan al final las adyacencias no agregadas
            i = i + 1
        return clausura

def conectados(estos):
    # True si coleccion es conexo, no hay partes separadas,
    if not estos: # es vacio
        return True
    else:
        este = estos[0] # este es cualquiera, se elije el primero
        return len(clausura_conexa(este, estos)) == len(estos)

# extraer un componente
def extraer(este, estos):
    # devuelve la lista de partes conexas resultado de remover la manzana m del segmento
    if este not in estos:
        return []
    else:
        esos = list(estos) # copia para no modificar el original
        esos.remove(este)
        partes = []
        while esos: # es no vacia
            ese = esos[0] # se elige uno cualquiera, se usa el 1ro
            clausura_de_ese_en_esos = clausura_conexa(ese, esos)
            for aquel in clausura_de_ese_en_esos:
                if aquel not in esos: # (?) cómo puede ser?????
            #        pass
                    raise Exception("elemento " + str(aquel) + " no está en " + str(esos)
                        + "\nclausura_de_ese_en_esos " + str(clausura_de_ese_en_esos))
                else:  # para que no se rompa acá....
                    esos.remove(aquel) # en esos queda el resto no conexo a aquel
            partes.append(clausura_de_ese_en_esos)
        return partes

# transferir un componente de un conjunto a otro
def transferir(este, estos, esos):
    # transferir este del segmento origen al segmento destino
    # devuelve una lista con 2 elementoe ... los nuevos estos y esos
    if not conectados(esos + [este]): # no puedo transferir
        return False
    elif len(estos) == 1: # no queda resto, se fusiona origen con destino
        return [estos + esos]
    else:
        return extraer(este, estos) + [esos + [este]]

def carga(estos):
    conteos = [viviendas[este] for este in estos]
    return sum(conteos)
