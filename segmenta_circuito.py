#!/usr/bin/python

# este programa segmenta un circuito (manzana, o secuencia de lados) con el recorrido ordenado

# cotas de semgmentos
n = 32;
m = 40;

# lee el cvs con el recorrido
import csv
import sys
from segMaker import segMaker

circuito = sys.argv[1]
cinta = []
with open( circuito, "rb" ) as theFile:
	reader = csv.DictReader( theFile )
	for line in reader:
		cinta.append(line)
	del cinta[-1] # borra la linea con el conteo de filas

print "cantidad de paquetes (pisos) indivisibles"
print len(cinta)
print "cantidad de viviendas"
print sum([int(r["count"]) for r in cinta])
print 

# devuelve una segmentacion o False si no hay ninguna
def segmenta(i, cinta, head):
	s = 0
	while i < len(cinta) and s < n:
		s += int(cinta[i]["count"])
		i += 1
	if i == len(cinta) and s < n:
		 return False # queda un segmento final muy corto, backtrack
	if i == len(cinta) and m < s:
		 return False # queda un segemento final muy largo, backtrack
	
	j = i
	t = s
	cortes = []
	while j < len(cinta) and t <= m:
		cortes.append([j, t])
                t += int(cinta[j]["count"])
                j += 1
	if m < t:
		j -= 1
		t -= int(cinta[j]["count"])
	if j == len(cinta) and n <= t and t <= m: # caso base
		head.append([j, t])
		return head
	elif j == len(cinta) and m < t:
		return False # no pudo cortar, backtrack
# DEBUG
#	print cortes
	i = j
	s = t
	while j < len(cinta) and n <= t: # empiezo con los segmento mas largos
		head.append([j, t])
#		print "estudio: ", i, s, head, sum(cinta[i:])
		segmentacion = segmenta(j, cinta, head)
		if segmentacion:
			return segmentacion
		else:
			del head[-1]
			t -= int(cinta[j]["count"])
			j -= 1
	if i < len(cinta): # m < s y no termino, backtrack
		return False
	else:
		print "caso no considerado" 

segmentacion = segmenta(0, cinta, [])

print "una segmentacion:"
print "cantidad de segmentos", len(segmentacion)
#print segmentacion
j = 1
for [i, c] in segmentacion:
	print [j, i, c]
	j = i+1

print "R3"
j = 0
s = 1
for [i, c] in segmentacion:
    print 'segmento %2s: desde %s %s %s '  % (s, cinta[j]['cnombre'], cinta[j]['hn'], cinta[j]['hp'])
    s += 1
    print '              hasta %s %s %s: %s' % (cinta[i-1]['cnombre'], cinta[i-1]['hn'], cinta[i-1]['hp'], c)
    j = i 


