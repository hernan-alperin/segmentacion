"""
tiyulo: CortaCinta.py
descripcion: algoritmo recursivo para cortar 
una cinta (listado de un solo lado) 
en segmentos de entre menos y mas viviendas
menos y mas son los límites inferior y superior
del tamaño de un segmento respectivamente
in: lista de números que representan la cantidad de viviendas de una secuencia de componentes
out: lista con una secuencia de números que representan la cantidad de viviendas de los segmentos de la cinta
escencialmente es una funcion de agregación de componentes, la secuencia de entrada puede no representar
direcciones de un solo lado, sino componentes en un recorrido
autor: -h
fecha: 2019-03-17 Do
"""
def CortaCinta(cinta, menos, mas):
    if sum(cinta) < menos:  
    # la cinta es muy corta
    # la cantidad de viviendas es menos que el límite inferior de un segmento
        # no es posible segmentar
        return None         
        # caso base devuelve no factible
    if menos <= sum(cinta) <= mas:  
        # la cinta puede ser 1 segmento
        # devuelve una lista unitaria con el numero de viviendas del componente
        return [sum(cinta)]   
        # devuelve la longitud del segmento (componente)
    else:
        # se va a buscar dividir la cinta en los posibles head-tail
        
        i, s, heads = 0, 0, []              # init variables
        # qué representan estas variables?
        # i, s variables de iteracion
        # heads lista de heads cuyos tails son factibles
        # heads es un listado de posibles poenciales componentes 
        # crear una lista de ramas ya exploradas
        while i < len(cinta) and s < menos:       
            # get upto sgm len lower bound
            # aumentar i hasta el menor valor de tamaño del segmento
            # aumentar s en cantidad de viviendas o componentes de la cinta
            i, s = i + 1, s + cinta[i]
        while i < len(cinta) and menos <= s <= mas:
            # mientras factible
            # chequear que el candidato no haya sido ya explorado
            heads.append((i, [s]))          
            # agrega candidatos a explorar
            i, s = i + 1, s + cinta[i]
            # llama a 1 función heurística para ordenar candidatos
            # call a function to sort heads with heuristic
        while heads:
            i, candidate = heads.pop()
            # extrae el indice y cantidad de tails a explorar
            tail = cinta[i:]
            sgms = CortaCinta(tail, menos, mas)
            # la lista de segmentos de una segmentacion exitosa de tail
            if sgms:
                # no es vacía, no es None, hay al menos un corte factible de la cinta
                candidate.extend(sgms)
                
return candidate
