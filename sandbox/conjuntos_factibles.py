import particiones
import conjuntos_adyacentes


componentes = [1, 2, 3, 4, 5]
adyacencias = [(5,4), (1,2), (2,3), (3,4)]
factibles = []

c_adys = conjuntos_adyacentes.conjuntos_adyacentes(componentes, adyacencias)
for c in c_adys:
    c.sort()
for p in particiones.partition(componentes):
    incluida = True
    for c_p in p:
        if c_p not in c_adys:
            incluida = False
            break
    if incluida:
        factibles.append(p)

for c in c_adys:
    print(c)

print('---------------------')

for p in factibles:
    print(p)

