"""
tiyulo: corta cinta.py
descripcion: algoritmo recursivo para cortar 
una cinta (listado de un solo lado) 
en segmentos de entre menos y más viviendas
autor: -h
fecha: 2019-03-17 Do
"""
def CortaCinta(cinta, menos, mas):
    if sum(cinta) < menos:  
    # la cinta es muy corta
        return None         
        # caso base devuelve no factible
    if menos <= sum(cinta) <= mas:  
        # la cinta puede ser 1 segmento
        return [sum(cinta)]   
        # devuelve la longitud del segmento (comopnente)
    else:
        i, s, heads = 0, 0, []              # init variables
        # crear una lista de ramas ya exploradas
        while i < len(seq) and s < n:       # get upto sgm len lower bound
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
            tail = cinta[i:]
            sgms = CortaCinta(tail, menos, mas)
            if sgms:
                candidate.extend(sgms)
return candidate
