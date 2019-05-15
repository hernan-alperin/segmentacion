#
# optimización
#

# fin de definiciones


import psycopg2
import operator
import time

conn = psycopg2.connect(
            database = "comuna11",
            user = "segmentador",
            password = "rodatnemges",
            host = "localhost",
            port = "5432")

# obtener prov, depto, frac que estan en segmentacion.conteos
with open('radios.sql') as file:
    sql = file.read()
cur = conn.cursor()
cur.execute(sql)
radios = cur.fetchall()

def sql_where_fr(frac, radio):
    return ("\nwhere frac::integer = " + str(frac)
            + "\n and radio::integer = " + str(radio))

def sql_where_PPDDDLLLMMM(frac, radio, cpte, side):
    if type(cpte) is int:
        mza = cpte
    elif type(cpte) is tuple:
        (mza, lado) = cpte
    where_mza = ("\nwhere (mza" + side + ",9,2)::integer = " + str(frac)
            + "\n and substr(mza" + side + ",11,2)::integer = " + str(radio)
            + "\n and substr(mza" + side + ",13,3)::integer = " + str(mza)
            )
    if type(cpte) is tuple:
            where_mza = (where_mza
                + "\n and lado" + side + "::integer = " + str(lado))
    return where_mza

for frac, radio in radios:
        print
        print "radio: "
        print frac, radio
        cur = conn.cursor()
        
        sql = ("select mza_comuna as mza, count(*) as conteo from comuna11"
            + sql_where_fr(frac, radio)
            + "\ngroup by mza_comuna;")
        cur.execute(sql)
        conteos_mzas = cur.fetchall()
        manzanas = [mza for mza, conteo in conteos_mzas]

#        print >> sys.stderr, "conteos_mzas"
#        print >> sys.stderr, conteos_mzas

        sql = ("select mza_comuna as mza, lado, count(*) as conteo from comuna11"
            + sql_where_fr(frac, radio)
            + "\ngroup by mza_comuna, lado;")
        cur.execute(sql)
        result = cur.fetchall()
        conteos_lados = [((mza, lado), conteo) for mza, lado, conteo in result]
        lados = [(mza, lado) for mza, lado, conteo in result]

#        print >> sys.stderr, "conteos_lados"
#        print >> sys.stderr, conteos_lados


        sql = ("select mza_comuna as mza, max(lado) from comuna11"
            + sql_where_fr(frac, radio)
            + "\ngroup by mza_comuna;")
        cur.execute(sql)
        mza_ultimo_lado = cur.fetchall()

        sql = ("select mza, mza_ady from adyacencias_mzas"
            + sql_where_fr(frac, radio)
            + "\ngroup by mza, mza_ady;")
        cur.execute(sql)
        adyacencias_mzas_mzas = cur.fetchall()

        sql = ("select mza, mza_ady, lado_ady from adyacencias_mzas"
            + sql_where_fr(frac, radio)
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
                            if conteo > cantidad_de_viviendas_maxima_deseada_por_segmento]
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

#        print >> sys.stderr, "componentes"
#        print >> sys.stderr, componentes

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
            for s, segmento in enumerate(solucion):
                for cpte in segmento:
                    segmentos[cpte] = s + 1

            # por ahora solo junin de los andes buscar la tabla usando una relacion prov, depto - aglomerado

#------
# update shapes.eAAAAa  (usando lados)
#------
            for cpte in componentes:
                sql = ("update shapes." + _table + "a"
                    + " set segi = " + str(segmentos[cpte])
                    + sql_where_PPDDDLLLMMM(prov, depto, frac, radio, cpte, 'i')
                    + "\n;")
                cur.execute(sql)
                sql = ("update shapes." + _table + "a"
                    + " set segd = " + str(segmentos[cpte])
                    + sql_where_PPDDDLLLMMM(prov, depto, frac, radio, cpte, 'd')
                    + "\n;")
                cur.execute(sql)
            conn.commit()
#            raw_input("Press Enter to continue...")
        else:
            print "sin adyacencias"
#    else:
#        print "radio Null"

conn.close()

