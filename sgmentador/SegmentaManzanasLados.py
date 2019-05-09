# -*- coding: utf-8 -*-
import sys
print sys.argv[1:]
_table = sys.argv[1]
_prov = int(sys.argv[2])
_depto = int(sys.argv[3])

#definición de funciones de adyacencia y operaciones sobre manzanas

def son_adyacentes(mza, ady):
    return ady in adyacentes[mza]

# calcula el componente conexo que contiene a m, para calcular las componentes conexas o contiguas luego de una extracción
def clausura_conexa(m, segmento):
    # se pueden ir de la manzana m a la n para toda manzana n dentro de la clausura
    if m not in segmento:
        return [] # caso seguro
    else:
        clausura = [m] # al menos contiene a la manzana m
        i = 0
        while i < len(clausura): # i es el puntero a la manzana que falta expandir
            # i se incrementa de a 1 expandiendo de a una las adyacencias
            # hasta que la variable clausura no se expande más, queda en un puntos fijo, i.e. es una clausura
            adyacentes_i = [manzana for manzana in adyacentes[clausura[i]] if manzana in segmento]
            # las adyacentes a la i-ésima manzana de la clausura que están en el segmento
            nuevas = [manzana for manzana in adyacentes_i if manzana not in clausura] # no agragadas aún
            clausura = clausura + nuevas # se agregan al final las adyacencias no agregadas
            i = i + 1
        return clausura

def conectado(segmento):
    # True si el segmento es conexo, no hay partes separadas,
    if not segmento: # es vacio
        return True
    else:
        una = segmento[0] # una es cualquiera, se elije la primera
        return len(clausura_conexa(una, segmento)) == len(segmento)

# extraer una manzana
def extraer(m, segmento):
    # devuelve la lista de partes conexas resultado de remover la manzana m del segmento
    if m not in segmento:
        return []
    else:
        copia = list(segmento) # copia para no modificar el original
        copia.remove(m)
        partes = []
        while copia: # es no vacia
            una = copia[0] # se elige una manzana cualquiera, se usa la 1ra
            componente_conexo_a_una = clausura_conexa(una, copia)
            for manzana in componente_conexo_a_una:
                copia.remove(manzana) # en copia queda el resto no conexo a una
            partes.append(componente_conexo_a_una)
        return partes

# transferir una manzana de un segmento a otro
def transferir(m, origen, destino):
    # transferir la manzana del segmento origen al segmento destino
    # devuelve una lista binaria
    if not conectado(destino + [m]): # no puedo transferir
        return False
    elif len(origen) == 1: # no queda resto, se fusiona origen con destino
        return [origen + destino]
    else:
        return extraer(m, origen) + [destino + [m]]


def carga_segmento(segmento):
    # segmento es una lista de manzanas
    viviendas_segmento = [viviendas[mza] for mza in segmento]
    # la lista de cantidad de viviendas por manzana del segmento
    return sum(viviendas_segmento)
    # la cantidad de viviendas del segmento

#################################################################################
#
# definición de funcion de costo
# y relativas a la calidad del segmento y la segmentación
#
# caso 1
cantidad_de_viviendas_deseada_por_segmento = 150
cantidad_de_viviendas_maxima_deseada_por_segmento = 250
cantidad_de_viviendas_minima_deseada_por_segmento = 130
if len(sys.argv) > 5:
    cantidad_de_viviendas_minima_deseada_por_segmento = int(sys.argv[4])
    cantidad_de_viviendas_maxima_deseada_por_segmento = int(sys.argv[5])
if len(sys.argv) > 5:
    cantidad_de_viviendas_deseada_por_segmento = int(sys.argv[6])


def costo_segmento(segmento):
    # segmento es una lista de manzanas
    carga = carga_segmento(segmento)
    if carga > cantidad_de_viviendas_maxima_deseada_por_segmento:
        # la carga es mayor el costo es el cubo
        return ((carga - cantidad_de_viviendas_maxima_deseada_por_segmento)**2
            + abs(carga - cantidad_de_viviendas_deseada_por_segmento))
    elif carga < cantidad_de_viviendas_minima_deseada_por_segmento:
        # la carga es menor el costo es el cuadrado
        return ((cantidad_de_viviendas_deseada_por_segmento - carga)**2
            + abs(carga - cantidad_de_viviendas_deseada_por_segmento))
    else:  # está entre los valores deseados
        # el costo el la diferencia absoluta al valor esperado
        return abs(carga - cantidad_de_viviendas_deseada_por_segmento)
"""
    # otro caso, costo en rango, cuadrático por arriba y lineal por abajo
    if carga > cantidad_de_viviendas_deseada_por_segmento:
        return (carga - cantidad_de_viviendas_deseada_por_segmento)**4
    else:
        return (cantidad_de_viviendas_deseada_por_segmento - carga)**2
"""


#####################################################################################

def costos_segmentos(segmentacion):
    # segmentacion es una lista de segmentos
    return map(costo_segmento, segmentacion)
    # la lista de costos de los segmentos

def costo_segmentacion(segmentacion):
    # segmentacion es una lista de segmentos
#    cantidad_de_segmentos = len(segmentacion)
#    if cantidad_de_segmentos <= 2:
        return sum(costos_segmentos(segmentacion))
#        # suma la aplicación de costo a todos los segmentos
#    else:
#        return sum(costos_segmentos(segmentacion)) + 1e6*cantidad_de_segmentos
# definicón del vecindario de una segmentacíon para definir y recorrer la red de segementaciones
# vecindario devuelve array de vecinos usando extraer y transferir
def vecindario(segmentacion):
    # devuelve array de vecinos
    vecindario = []
    # extracciones
    for segmento in segmentacion:
        sgms = list(segmentacion); sgms.remove(segmento) # el resto no considerado de la segmentación
        if len(segmento) == 2: # segmento binario se parte, no se analizan los 2 casos, ya que son el mismo
            una = segmento[0]; otra = segmento[1]
            vecino = [[una], [otra]] + sgms; vecindario.append(vecino)
        elif len(segmento) > 2:
            for manzana in segmento:
                vecino = [[manzana]] + extraer(manzana, segmento) + sgms; vecindario.append(vecino)
    # transferencias
    if len(segmentacion) >= 2: # se puede hacer una transferencia
        for o, origen in enumerate(segmentacion):
            sgms_o = list(segmentacion); sgms_o.remove(origen)
            for d, destino in enumerate(sgms_o):
                sgms_od = list(sgms_o); sgms_od.remove(destino) # copia de segmentacion sin origen ni destino
                if len(origen) == 1 and len(destino) == 1 and d < o:
                    pass # si no se repiten cuando destino y origen se permuten
                else:
                    for manzana in origen:
                        transferencia = transferir(manzana, origen, destino)
                        if transferencia: # la manzana esta conectada con el
                            vecino = transferencia + sgms_od; vecindario.append(vecino)
                # fusión de 2 segmentos evitando repeticiones
                #(cuando alguno es una sola manzana la fusion es considerada en la transferencia)
                if len(origen) > 1 and len(destino) > 1 and conectado(origen + destino):
                    vecino = [origen + destino] + sgms_od; vecindario.append(vecino) # analizar fusiones
    return vecindario
# no devuelve repeticiones

#
# optimización
#

# fin de definiciones


import psycopg2
import operator
import time

#_table = '0339'  # San Javier
#_prov = 54
#_depto = 105 # ahora vienen en arg

conn = psycopg2.connect(
            database = "censo2020",
            user = "segmentador",
            password = "rodatnemges",
            host = "172.26.67.239",
            port = "5432")

# obtener prov, depto, frac que estan en segmentacion.conteos
cur = conn.cursor()
sql = ("select distinct prov::integer, depto::integer, frac::integer, radio::integer"
       " from segmentacion.conteos"
       " order by prov::integer, depto::integer, frac::integer, radio::integer;")
cur.execute(sql)
radios = cur.fetchall()
#print _prov, _depto
#print radios
for prov, depto, frac, radio in radios:
    if (radio and prov == 58 and depto == 49 and radio == 1): # junín de los andes (sacar radio 1 que es un lio)
        continue
    if (radio and prov == _prov and depto == _depto): # las del _table
        print
        print "radio: "
        print prov, depto, frac, radio
        cur = conn.cursor()
        sql = ("select mza, sum(conteo) from segmentacion.conteos"
            + " where prov = " + str(prov)
            + " and depto = " + str(depto)
            + " and frac = " + str(frac)
            + " and radio = " + str(radio)
            + " group by mza;")
#        print sql
        cur.execute(sql)
        conteos = cur.fetchall()
#    print conteos
        sql = ("select mza, mza_ady from segmentacion.adyacencias"
            + " where prov = " + str(prov)
            + " and depto = " + str(depto)
            + " and frac = " + str(frac)
            + " and radio = " + str(radio)
            + " and mza != mza_ady"
            + " group by mza, mza_ady;")
#        print sql
        cur.execute(sql)
        adyacencias = cur.fetchall()
        if adyacencias:
            start = time.time()
#            print adyacencias

            # crea los dictionary
            manzanas_con_viviendas = [manzana for manzana, viviendas in conteos]
            manzanas_en_adyacencias = list(set([manzana for manzana, adyacente in adyacencias]))
            todas_las_manzanas = list(set(manzanas_con_viviendas + manzanas_en_adyacencias))

            manzanas_sin_viviendas = list(set(todas_las_manzanas) - set(manzanas_con_viviendas))
            # print "no están en listado", manzanas_sin_viviendas
            # hay que ponerle 0 viviendas
            viviendas = dict()
            for manzana in manzanas_sin_viviendas:
                viviendas[manzana] = 0
            for manzana, vivs in conteos:
                viviendas[manzana] = int(vivs)

            manzanas_no_en_adyacencias = list(set(todas_las_manzanas) - set(manzanas_en_adyacencias))
            # print "no están en cobertura", manzanas_no_en_adyacencias
            # hay que ponerle nula la lista de adyacencias
            adyacentes = dict()
            for manzana in todas_las_manzanas:
                adyacentes[manzana] = list([])
            for manzana, adyacente in adyacencias:
                adyacentes[manzana] = adyacentes[manzana] + [adyacente]
#            for manzana in sorted(adyacentes.iterkeys()):
#                print manzana, adyacentes[manzana]

            # optimización

            ##############################
            # soluciones iniciales
            # iniciando de un extremo de la red de segmentaciones: segmento único igual a todo el radio
            todas_juntas = [todas_las_manzanas]
            soluciones_iniciales = [todas_juntas]
            # iniciando del otro extremo de la red de segmentaciones: un segmento por manzana
            todas_juntas = [todas_las_manzanas]
            soluciones_iniciales = [todas_juntas]
            # iniciando del otro extremo de la red de segmentaciones: un segmento por manzana
            todas_separadas = [[manzana] for manzana in todas_las_manzanas]
            soluciones_iniciales.append(todas_separadas)
            ##############################

            # TODO: cargar el segmento de la segmentación anterior sgm en segmentacio.conteos para el caso de lados

            costo_minimo = float('inf')
            for solucion in soluciones_iniciales:
                # algoritmo greedy
                vecinos = list(vecindario(solucion))
                costo_actual = costo_segmentacion(solucion)
                costos_vecinos = map(costo_segmentacion, vecinos)

                while min(costos_vecinos) < costo_actual: # se puede mejorar
                    min_id, mejor_costo = min(enumerate(costos_vecinos), key=operator.itemgetter(1))
                    solucion = vecinos[min_id] # greedy
                    vecinos = list(vecindario(solucion))
                    costo_actual = mejor_costo
                    costos_vecinos = map(costo_segmentacion, vecinos)
                if costo_actual < costo_minimo:
                    costo_minimo = costo_actual
                    mejor_solucion = solucion

            #muestra warnings
            if manzanas_sin_viviendas:
                print "Cuidado: "
                print
                print "no están en listado o conteo", manzanas_sin_viviendas
                print "se les asignó 0 viviendas"
                print
            if manzanas_no_en_adyacencias:
                print "Cuidado: "
                print
                print "no están en adyacencias, cobertura con errores, quizás?", manzanas_no_en_adyacencias
                print "no se les asignó manzanas adyacentes y quedaron aisladas"
                print

            # muestra solución
            print "---------"
            print "mínimo local"
            print "costo", costo_minimo
            for s, segmento in enumerate(mejor_solucion):
                print ["segmento", s+1,
                   "carga", carga_segmento(segmento),
                   "costo", costo_segmento(segmento),
                   "manzanas", segmento]

            print "deseada: %d, máxima: %d, mínima: %d" % (cantidad_de_viviendas_deseada_por_segmento,
                cantidad_de_viviendas_maxima_deseada_por_segmento,
                cantidad_de_viviendas_minima_deseada_por_segmento)



            end = time.time()
            print str(end - start) + " segundos"

            # actualiza los valores de segmento en la tabla de polygons para representar graficamente
            segmentos = {}
            for s, segmento in enumerate(solucion):
                for manzana in segmento:
                    segmentos[manzana] = s + 1

            # por ahora solo junin de los andes buscar la tabla usando una relacion prov, depto - aglomerado
            for manzana in todas_las_manzanas:
                sql = ("update shapes." + _table + "p"
                      + " set segmento = " + str(segmentos[manzana])
                      + " where prov::integer = " + str(prov)
                      + " and depto::integer = " + str(depto)
                      + " and frac::integer = " + str(frac)
                      + " and radio::integer = " + str(radio)
                      + " and mza::integer = " + str(manzana)
                      )
                cur.execute(sql)
                conn.commit()
#            raw_input("Press Enter to continue...")
        else:
            print "sin adyacencias"
#    else:
#        print "radio Null"

conn.close()


