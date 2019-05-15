/*
titulo: costos_de_manzanas_y_lados.py
descripción: los costos de cada segemntación dados lados y manzanas en segmentos
autor: -h
fecha: 2019-05-09 Ju

*/
#################################################################################
#
# definición de funcion de costo
# y relativas a la calidad del segmento y la segmentación
#
# caso 1
cantidad_de_viviendas_deseada_por_segmento = 40
if len(sys.argv) > 4:
    cantidad_de_viviendas_deseada_por_segmento = int(sys.argv[4])


def costo(segmento):
    # segmento es una lista de manzanas
    carga_segmento = carga(segmento)
    return abs(carga_segmento - cantidad_de_viviendas_deseada_por_segmento)

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


