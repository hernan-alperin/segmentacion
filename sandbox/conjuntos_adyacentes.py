"""
título: conjuntos_adyacentes.py
descripción: calcula todos los conjuntos que se pueden generar siguiendo la relación de adyacencias
(no reflexiva)
autor: -h
fecha: 2019-06
"""

def conjuntos_adyacentes(componentes, adyacencias):
    conjuntos = []
    for cmpt in componentes:
        conjuntos.append([cmpt])
    for (i, j) in adyacencias:
        conjuntos.append([i, j])
    cantidad = 0
    while cantidad < len(conjuntos):
        cantidad = len(conjuntos)
        for c in conjuntos:
            for (i, j) in adyacencias:
                if i in c and j not in c:
                    b = list(c)
                    b.append(j)
                    b.sort()
                    if b not in conjuntos:
                        conjuntos.append(b)
    return conjuntos



#componentes = [1, 2, 3, 4, 5]
#adyacencias = [(5,4), (1,2), (2,3), (3,4)]

#print(conjuntos_adyacentes(componentes, adyacencias))

    
