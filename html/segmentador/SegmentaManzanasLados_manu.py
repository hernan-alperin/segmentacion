# -*- coding: utf-8 -*-
import sys
from decimal import *
print sys.argv[1:]
_table = sys.argv[1]
_prov = int(sys.argv[2])
_depto = int(sys.argv[3])

#definición de funciones de adyacencia y operaciones sobre manzanas

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

#################################################################################
#
# definición de funcion de costo
# y relativas a la calidad del segmento y la segmentación
#
# caso 1
cantidad_de_viviendas_deseada_por_segmento = 20
cantidad_de_viviendas_maxima_deseada_por_segmento = 23
cantidad_de_viviendas_minima_deseada_por_segmento = 17
cantidad_de_viviendas_permitida_para_romper_manazna = 5
multa_fuera_rango_superior = 1
multa_fuera_rango_inferior = 1

if len(sys.argv) > 5:
    cantidad_de_viviendas_minima_deseada_por_segmento = int(sys.argv[4])
    cantidad_de_viviendas_maxima_deseada_por_segmento = int(sys.argv[5])
if len(sys.argv) > 6:
    cantidad_de_viviendas_deseada_por_segmento = int(sys.argv[6])
if len(sys.argv) > 7:
    cantidad_de_viviendas_permitida_para_romper_manzana = int(sys.argv[7])


def costo(segmento): 
    # segmento es una lista de manzanas
    carga_segmento = carga(segmento)
    if carga_segmento > cantidad_de_viviendas_maxima_deseada_por_segmento:
        # la carga es mayor el costo es el cubo
        return (abs(carga_segmento - cantidad_de_viviendas_maxima_deseada_por_segmento) 
                *abs(carga_segmento - cantidad_de_viviendas_maxima_deseada_por_segmento) 
                *abs(carga_segmento - cantidad_de_viviendas_maxima_deseada_por_segmento) 
            + (carga_segmento - cantidad_de_viviendas_deseada_por_segmento)
            + multa_fuera_rango_superior)
    elif carga_segmento < cantidad_de_viviendas_minima_deseada_por_segmento:
        # la carga es menor el costo es el cubo
        return (abs(cantidad_de_viviendas_minima_deseada_por_segmento - carga_segmento)
                *abs(cantidad_de_viviendas_minima_deseada_por_segmento - carga_segmento)
                *abs(cantidad_de_viviendas_minima_deseada_por_segmento - carga_segmento)
            + abs(carga_segmento - cantidad_de_viviendas_deseada_por_segmento)
            + multa_fuera_rango_inferior)
    else:  # está entre los valores deseados
        # el costo el la diferencia absoluta al valor esperado
        return abs(carga_segmento - cantidad_de_viviendas_deseada_por_segmento)
    """
    # otro caso, costo en rango, cuadrático por arriba y lineal por abajo
    if carga_segmento > cantidad_de_viviendas_deseada_por_segmento:
        return (carga_segmento - cantidad_de_viviendas_deseada_por_segmento)**4
    else:
        return (cantidad_de_viviendas_deseada_por_segmento - carga_segmento)**2
    """


#####################################################################################
    
def costos_segmentos(segmentacion):
    # segmentacion es una lista de segmentos
    return map(costo, segmentacion)
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
        sgms = list(segmentacion)
        sgms.remove(segmento) # el resto no considerado de la segmentación
        if len(segmento) == 2: # segmento binario se parte, no se analizan los 2 casos, ya que son el mismo
            este = segmento[0]; ese = segmento[1]
            vecino = [[este], [ese]] + sgms
            vecindario.append(vecino)
        elif len(segmento) > 2: 
            for este in segmento: 
                vecino = [[este]] + extraer(este, segmento) + sgms
                vecindario.append(vecino)
    # transferencias                
    if len(segmentacion) >= 2: # se puede hacer una transferencia
        for i, este in enumerate(segmentacion):
            esa = list(segmentacion) # copia para preservar la original
            esa.remove(este) # elimino de la copia de la segmentacion a este segmento
            for j, ese in enumerate(esa): # busco otro segmento
                aquella = list(esa) # copia de para eliminar a ese
                aquella.remove(ese) # copia de segmentacion sin este ni ese
                if len(este) == 1 and len(ese) == 1 and i < j:
                    pass # si no se repiten cuando este y ese se permuten
                else:
                    for cada in este:
                        transferencia = transferir(cada, este, ese)
                        if transferencia: # se pudo hacer 
                            vecino = transferencia + aquella
                            vecindario.append(vecino)
                # fusión de 2 segmentos evitando repeticiones 
                #(cuando alguno es una solo elemento la fusion es considerada en la transferencia)
                if len(este) > 1 and len(ese) > 1 and conectados(este + ese):
                    vecino = [este + ese] + aquella
                    vecindario.append(vecino) # analizar fusiones
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

def sql_where_pdfr(prov, depto, frac, radio):
    return ("\nwhere prov::integer = " + str(prov)
            + "\n and depto::integer = " + str(depto)
            + "\n and frac::integer = " + str(frac)
            + "\n and radio::integer = " + str(radio))

def sql_where_PPDDDLLLMMM(prov, depto, frac, radio, cpte, side):
    if type(cpte) is int:
        mza = cpte
    elif type(cpte) is tuple:
        (mza, lado) = cpte
    where_mza = ("\nwhere substr(mza" + side + ",1,2)::integer = " + str(prov)
            + "\n and substr(mza" + side + ",3,3)::integer = " + str(depto)
            + "\n and substr(mza" + side + ",9,2)::integer = " + str(frac)
            + "\n and substr(mza" + side + ",11,2)::integer = " + str(radio)
            + "\n and substr(mza" + side + ",13,3)::integer = " + str(mza)
            )
    if type(cpte) is tuple:
            where_mza = (where_mza 
                + "\n and lado" + side + "::integer = " + str(lado))
    return where_mza

for prov, depto, frac, radio in radios:
  if (radio and not(prov == 58 and depto == 49 and radio == 1)): # junín de los andes (sacar radio 1 que es un lio)
    if (radio and prov == _prov and depto == _depto): # las del _table
        print
        print "radio: "
        print prov, depto, frac, radio
        cur = conn.cursor()
        sql = ("select mza, sum(conteo)::int from segmentacion.conteos"
            + sql_where_pdfr(prov, depto, frac, radio)
            + "\ngroup by mza;")
        cur.execute(sql)
        conteos_mzas = cur.fetchall()
        manzanas = [mza for mza, conteo in conteos_mzas]

#        print >> sys.stderr, "conteos_mzas"
#        print >> sys.stderr, conteos_mzas

        sql = ("select mza, lado, sum(conteo)::int from segmentacion.conteos"
            + sql_where_pdfr(prov, depto, frac, radio)
            + "\ngroup by mza, lado;")
        cur.execute(sql)
        result = cur.fetchall()
        conteos_lados = [((mza, lado), conteo) for mza, lado, conteo in result]
        lados = [(mza, lado) for mza, lado, conteo in result]

#        print >> sys.stderr, "conteos_lados"
#        print >> sys.stderr, conteos_lados


        sql = ("select mza, max(lado) from segmentacion.conteos"
            + sql_where_pdfr(prov, depto, frac, radio)
            + "\ngroup by mza;")
        cur.execute(sql)
        mza_ultimo_lado = cur.fetchall()

        sql = ("select mza, mza_ady from segmentacion.adyacencias"
            + sql_where_pdfr(prov, depto, frac, radio)
            + "\n and mza != mza_ady"
            + "\ngroup by mza, mza_ady;")
        cur.execute(sql)
        adyacencias_mzas_mzas = cur.fetchall()

        sql = ("select mza, mza_ady, lado_ady from segmentacion.adyacencias"
            + sql_where_pdfr(prov, depto, frac, radio)
            + "\n and mza != mza_ady"
            + ";")
        cur.execute(sql)
        result = cur.fetchall()
        adyacencias_mzas_lados = [(mza, (mza_ady, lado_ady)) for mza, mza_ady, lado_ady in result]

        sql = ("select mza, lado, mza_ady from segmentacion.adyacencias"
            + sql_where_pdfr(prov, depto, frac, radio)
            + "\n and mza != mza_ady"
            + ";")
        cur.execute(sql)
        result = cur.fetchall()
        adyacencias_lados_mzas= [((mza, lado), mza_ady) for mza, lado, mza_ady in result]

        sql = ("select mza, lado, mza_ady, lado_ady from segmentacion.adyacencias"
            + sql_where_pdfr(prov, depto, frac, radio)
            + "\n and mza != mza_ady"
            + ";")
        cur.execute(sql)
        result = cur.fetchall()
        lados_enfrentados = [((mza, lado), (mza_ady, lado_ady)) for mza, lado, mza_ady, lado_ady in result]

        lados_contiguos = []
        for mza, lado in lados:
            ultimo_lado = next(ultimo for mza, ultimo in mza_ultimo_lado)
            if lado == 1:
                lados_contiguos.append(((mza, lado),(mza, ultimo_lado)))
                lados_contiguos.append(((mza, lado),(mza, lado + 1)))
            elif lado == ultimo_lado:
                lados_contiguos.append(((mza, lado),(mza, lado - 1)))
                lados_contiguos.append(((mza, lado),(mza, 1)))
            else:
                lados_contiguos.append(((mza, lado),(mza, lado - 1)))
                lados_contiguos.append(((mza, lado),(mza, lado + 1)))

        conteos = conteos_mzas
        adyacencias = adyacencias_mzas_mzas


        conteos_excedidos = [(manzana, conteo) for (manzana, conteo) in conteos_mzas
                            if conteo > cantidad_de_viviendas_permitida_para_romper_manzana]
        mzas_excedidas = [mza for mza, conteo in conteos_excedidos]

        componentes = [mza for mza in manzanas if mza not in mzas_excedidas]
        conteos = [(mza, conteo) for (mza, conteo) in conteos if mza not in mzas_excedidas]
        adyacencias = [(mza, mza_ady) for (mza, mza_ady) in adyacencias 
                        if mza not in mzas_excedidas and mza_ady not in mzas_excedidas]
        # se eliminana manzanas excedidas

        componentes.extend([(mza, lado) for (mza, lado) in lados if mza in mzas_excedidas])
        conteos.extend([((mza, lado), conteo) for ((mza, lado), conteo) in conteos_lados
                        if mza in mzas_excedidas])
        adyacencias.extend([((mza, lado), mza_ady) for (mza, lado), mza_ady in adyacencias_lados_mzas
                        if mza in mzas_excedidas and mza_ady not in mzas_excedidas])
        adyacencias.extend([(mza, (mza_ady, lado_ady)) 
                        for mza, (mza_ady, lado_ady) in adyacencias_mzas_lados
                        if mza not in mzas_excedidas and mza_ady in mzas_excedidas])
        adyacencias.extend([((mza, lado), (mza_ady, lado_ady)) 
                        for (mza, lado), (mza_ady, lado_ady) in lados_enfrentados
                        if mza in mzas_excedidas and mza_ady in mzas_excedidas])
        adyacencias.extend([((mza, lado), (mza_ady, lado_ady))
                        for (mza, lado), (mza_ady, lado_ady) in lados_contiguos])
        # se agregan los lados correspondientes a esas manzanas

        print >> sys.stderr, "componentes"
        print >> sys.stderr, componentes

#---- hasta acá

        if adyacencias:
            start = time.time()
#            print adyacencias

            # crea los dictionary
            componentes_en_adyacencias = list(set([cpte for cpte, cpte_ady in adyacencias]))
            todos_los_componentes = list(set(componentes + componentes_en_adyacencias))

            # print "no están en listado", manzanas_sin_viviendas
            # hay que ponerle 0 viviendas
            viviendas = dict()
            for cpte in componentes:
                viviendas[cpte] = 0
            for cpte, conteo in conteos:
                viviendas[cpte] = int(conteo)

            componentes_no_en_adyacencias = list(set(todos_los_componentes) - set(componentes_en_adyacencias))
            # print "no están en cobertura", manzanas_no_en_adyacencias
            # hay que ponerle nula la lista de adyacencias
            adyacentes = dict()
            for cpte in todos_los_componentes:
                adyacentes[cpte] = list([])
            for cpte, adyacente in adyacencias:
                adyacentes[cpte] = adyacentes[cpte] + [adyacente]
#            for manzana in sorted(adyacentes.iterkeys()):
#                print manzana, adyacentes[manzana]

            # optimización

            ##############################
            # soluciones iniciales
            soluciones_iniciales = []
            # iniciando de un extremo de la red de segmentaciones: segmento único igual a todo el radio
            todos_juntos = [componentes]
            soluciones_iniciales.append(todos_juntos)
            # iniciando del otro extremo de la red de segmentaciones: un segmento por manzana
            # TODO: probar un segmento x lado
            todos_separados = [[cpte] for cpte in componentes]
            soluciones_iniciales.append(todos_separados)
            ##############################

            # TODO: cargar el segmento de la segmentación anterior sgm en segmentacio.conteos para el caso de lados

            costo_minimo = float('inf')
            for solucion in soluciones_iniciales:
                # algoritmo greedy
                vecinos = list(vecindario(solucion))
                costo_actual = costo_segmentacion(solucion)
                costos_vecinos = map(costo_segmentacion, vecinos)
                if not costos_vecinos:
                    print ('Costos vecinos vacios')
                else:
                  while min(costos_vecinos) < costo_actual: # se puede mejorar 
                      min_id, mejor_costo = min(enumerate(costos_vecinos), key=operator.itemgetter(1))
                      solucion = vecinos[min_id] # greedy
  #                    print >> sys.stderr, mejor_costo
                      vecinos = list(vecindario(solucion))
                      costo_actual = mejor_costo 
                      costos_vecinos = map(costo_segmentacion, vecinos)
                if costo_actual < costo_minimo:
                    costo_minimo = costo_actual
                    mejor_solucion = solucion
                    
            #muestra warnings
            if componentes_no_en_adyacencias:
                print "Cuidado: "
                print
                print "no están en adyacencias, cobertura con errores, quizás?", componentes_no_en_adyacencias
                print "no se les asignó componentes adyacentes y quedaron aisladas"
                print

            # muestra solución
            print "---------"
            print "mínimo local"
            print "costo", costo_minimo
            for s, segmento in enumerate(mejor_solucion):
                print ["segmento", s+1, 
                   "carga", carga(segmento), 
                   "costo", costo(segmento), 
                   "componentes", segmento]

            print "deseada: %d, máxima: %d, mínima: %d" % (cantidad_de_viviendas_deseada_por_segmento,
                cantidad_de_viviendas_maxima_deseada_por_segmento, 
                cantidad_de_viviendas_minima_deseada_por_segmento)



            end = time.time()
            print str(end - start) + " segundos"

            # actualiza los valores de segmento en la tabla de polygons para representar graficamente
            segmentos = {}
            for s, segmento in enumerate(mejor_solucion):
                for cpte in segmento:
                    segmentos[cpte] = s + 1
            
            # por ahora solo junin de los andes buscar la tabla usando una relacion prov, depto - aglomerado
#------
# update _table = shapes.eAAAAa  (usando lados)
#------
            for cpte in componentes:
                sql = ("update " + _table   
                    + " set segi = " + str(segmentos[cpte])
                    + sql_where_PPDDDLLLMMM(prov, depto, frac, radio, cpte, 'i')
                    + " AND mzai is not null AND mzai != ''"
                    + "\n;")
                #print "", sql
                cur.execute(sql)
                sql = ("update " + _table   
                    + " set segd = " + str(segmentos[cpte])
                    + sql_where_PPDDDLLLMMM(prov, depto, frac, radio, cpte, 'd')
                    + " AND mzad is not null AND mzad != ''"
                    + "\n;")
                #print " ", sql
                cur.execute(sql)
            conn.commit()
#            raw_input("Press Enter to continue...")
        else:
            print "sin adyacencias"
#    else:
#        print "radio Null"

conn.close()
