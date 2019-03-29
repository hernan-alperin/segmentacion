#!/usr/bin/python
# -*- coding: utf8 -*-
#
# corta una lista en segmentos dada una longitud deseada d
#

# in: lista con numeros, no se puede corta dentro de repeticion de numeros
# ejemplo [ 1, 2, 3, 3, 3, 4, 4, 5, 5, 5, ]
# no se puede cortar [1, 2, 3,] y [3, 3, 4, 4, 5, 5, 5,]
# y si [1, 2, 3, 3, 3] [4, 4, 5, 5, 5]
# out: devuelve una lista (no exhaustiva) con posibles segmentos
# ejemplo
# [
#  [
#   [1, 2, 3, 3, 3, 4, 4],
#   [5, 5, 5,]
#  ],
#  [
#   [1, 2, 3, 3, 3]
#   [4, 4, 5, 5, 5,]
#  ]
# ]
# lista de soluciones, donde
# cada solucion es una lista de
# segmentos

def CortarEn(k, lista):
    if k == 0:
        return 0
    # safe
    if lista[k] != lista[k - 1]:
    # se puede cortar
        return [ k ]
    else:
    # busca cortar antes y después
        i = 1
        while 0 < k - i and lista[ k - i ] == lista[ k ]:
            i += 1
        a = k - i + 1
        j = 1
        while k + j < len(lista) and lista[ k ] == lista[ k + j ]:
            j += 1
        b = k + j
        if a == 0:
            return [ b ]
        if b >= len(lista) - 1:
            return [ a ]
        else:
            return [ a, b ]

lista = [ 1, 2, 3, 3, 3, 4, 4, 5, 5, 5, ]
print 'lista: ', lista
print 'cortes: incrementales de a 1'
for k in range(len(lista) - 1):
    print k + 1, CortarEn(k + 1, lista)

print '---------------------------------------'

d = 4
i = 1
PuntosDeCorte = []
while i*d < len(lista):
    PuntosDeCorte.append(i*d)
    i += 1
print 'PuntosDeCorte: ', PuntosDeCorte
cortes = []
for k in PuntosDeCorte:
    corte = CortarEn(k, lista)
    cortes.append(corte)
print 'cortes posibles: ', cortes
print '---------------------------------------'

solucion = []
soluciones = [[]]
for corte in cortes:
    solucion1.append(corte[0])
    soluciones.
    if len(corte) == 2

print solucion


#### HAY QUE MASTICAR ESTO UN POCO MAS
# Armar arbol de búsqueda en foram de Grafo y explorar según heurística
# f(head) + h(tail)
