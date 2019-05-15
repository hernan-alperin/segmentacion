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
