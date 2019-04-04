#!/usr/bin/python

# este programa segmenta un circuito (manzana, o secuencia de lados) con el recorrido ordenado

# lee el cvs con el recorrido
import csv
import sys

listados = sys.argv[1]
listado = []
with open( listados, "rb" ) as csvFile:
    reader = csv.DictReader( csvFile )
    for line in reader:
        listado.append(line)

circuitList, circuits = [], []
depto, frac, radio = listado[0]['depto'], listado[0]['frac'], listado[0]['radio']
manzana = listado[0]['mnza']
for line in listado:
    if (line['depto'] == depto and line['frac'] == frac and line['radio'] == radio
        and line["mnza"] == manzana):
        circuitList.append(int(line["count"]))
    else:
        circuits.append({'blocks':[manzana], 'circuitList':circuitList,
            'depto':depto, 'frac':frac, 'radio':radio})
        circuitList = [int(line["count"])]
        depto, frac, radio = line['depto'], line['frac'], line['radio']
        manzana = line["mnza"]
circuits.append({'blocks':[manzana], 'circuitList':circuitList,
    'depto':depto, 'frac':frac, 'radio':radio})

depto, frac, radio = circuits[0]['depto'], circuits[0]['frac'], circuits[0]['radio']
CircuitosDelRadio = []
CircuitosPorRadio = []
for circuit in circuits:
    if (depto, frac, radio) == (circuit['depto'], circuit['frac'], circuit['radio']):
        DatosRadio = {'depto':depto, 'frac':frac, 'radio':radio}
        CircuitosDelRadio.append(circuit['circuitList'])
    else:
        depto, frac, radio = circuit['depto'], circuit['frac'], circuit['radio']
        DatosRadio['circuitos'] = CircuitosDelRadio
        CircuitosPorRadio.append(CircuitosDelRadio)
        CircuitosDelRadio = []
#        print DatosRadio
if ((circuits[-1]['depto'], circuits[-1]['frac'], circuits[-1]['radio']) == (depto, frac, radio)):
    # la ultima linea es igual, no fue apendeada la ultima porque no cambia
    DatosRadio['circuitos'] = CircuitosDelRadio
    CircuitosPorRadio.append(CircuitosDelRadio)
    


#print "cantidad de manzanas: ", len(circuits)
#print
#print "cantidad de paquetes (pisos) indivisibles por manzana"
circuitLists = []
for circuit in circuits:
    circuitLists.append(circuit['circuitList'])
#print map(len, circuitLists), sum(map(len, circuitLists))
#print "cantidad de paquetes (pisos) indivisibles: ", len(listado)
#print
#print "cantidad de viviendas por manzana"
#print map(sum, circuitLists), sum(map(sum, circuitLists))
#print "cantidad de viviendas: ", sum([int(line["count"]) for line in listado])
#print
print [circuit['blocks'] for circuit in circuits]

from segMakerDynamic import segMaker, NoFactiblePartirBloque
# cotas de semgmentos
n, m = 17, 23
if len(sys.argv) > 3:
    n, m = int(sys.argv[2]), int(sys.argv[3])

SegmentacionPorRadio = {}
SegmentacionDDDFFRR = {}
for circuit in circuits:
    if circuit['depto'] not in SegmentacionDDDFFRR:
        SegmentacionDDDFFRR[circuit['depto']] = {}
    if circuit['frac'] not in SegmentacionDDDFFRR[circuit['depto']]:
        SegmentacionDDDFFRR[circuit['depto']][circuit['frac']] = {}
    if circuit['radio'] not in SegmentacionDDDFFRR[circuit['depto']][circuit['frac']]:
        SegmentacionDDDFFRR[circuit['depto']][circuit['frac']][circuit['radio']] = True
        
    if NoFactiblePartirBloque(circuit['circuitList'],n,m):
        print NoFactiblePartirBloque(circuit['circuitList'],n,m)
        SegmentacionPorRadio[circuit['depto']+'.'+circuit['frac']+'.'+circuit['radio']] = 'no se puede segmentar'
        SegmentacionDDDFFRR[circuit['depto']][circuit['frac']][circuit['radio']] = None    

    segmtsCircuit = segMaker(circuit['circuitList'],n,m)
    if circuit['depto']+'.'+circuit['frac']+'.'+circuit['radio'] not in SegmentacionPorRadio:
        SegmentacionPorRadio[circuit['depto']+'.'+circuit['frac']+'.'+circuit['radio']] = 'pudo segmentar'
    if segmtsCircuit:
        circuit['segmtsCircuit'] = segmtsCircuit
    else: 
        circuit['segmtsCircuit'] = '* ' + str(sum(circuit['circuitList'])) + '*'
        if SegmentacionPorRadio[circuit['depto']+'.'+circuit['frac']+'.'+circuit['radio']] != 'no se puede segmentar':
            SegmentacionPorRadio[circuit['depto']+'.'+circuit['frac']+'.'+circuit['radio']] = 'no pudo segmentar'
            SegmentacionDDDFFRR[circuit['depto']][circuit['frac']][circuit['radio']] = False

segmntsList = [circuit['segmtsCircuit'] for circuit in circuits]
#print segmntsList 
#print [caso for caso in SegmentacionPorRadio]
Pudo = [caso for caso in SegmentacionPorRadio if SegmentacionPorRadio[caso] == 'pudo segmentar']
NoPudo = [caso for caso in SegmentacionPorRadio if SegmentacionPorRadio[caso] == 'no pudo segmentar']
NoSePuede = [caso for caso in SegmentacionPorRadio if SegmentacionPorRadio[caso] == 'no se puede segmentar']
print '-----------------------------------------------------------------'
print 'No es posible segmentar ' + str(len(NoSePuede)) + ' radios'
print 'No pudo segmentar ' + str(len(NoPudo)) + ' radios'
print 'Se segmentaron ' + str(len(Pudo)) + ' radios'
print '-----------------------------------------------------------------'
print

RadiosSegmentados = {}
RadiosNoSegmentados = {}
RadiosNoSegmentables = {}
for Comuna in SegmentacionDDDFFRR:
    RadiosSegmentados[Comuna] = 0
    RadiosNoSegmentados[Comuna] = 0
    RadiosNoSegmentables[Comuna] = 0
    for Frac in SegmentacionDDDFFRR[Comuna]:
        for Radio in SegmentacionDDDFFRR[Comuna][Frac]:
            if SegmentacionDDDFFRR[Comuna][Frac][Radio]:
                RadiosSegmentados[Comuna] += 1
            elif SegmentacionDDDFFRR[Comuna][Frac][Radio] is None:
                RadiosNoSegmentables[Comuna] += 1
            else:
                RadiosNoSegmentados[Comuna] += 1

print 'Discriminados por Comuna'
print 'Segmentados'
print RadiosSegmentados
print 'No segmentados'
print RadiosNoSegmentados
print 'No segmentables'
print RadiosNoSegmentables

print '-----------------------------------------------------------------'



print 'Cantidad de manzanas: ' + str(len(segmntsList))
print '  segmentadas:   ' + str(len([sgmnts for sgmnts in segmntsList if type(sgmnts) is list]))
print '  con problemas: ' + str(len([sgmnts for sgmnts in segmntsList if type(sgmnts) is not list]))

print '-----------------------------------------------------------------'
print


radiosCircuits = []
for circuit in circuits:
    depto, frac, radio = circuit['depto'], circuit['frac'], circuit['radio']


#for i, load in enumerate(circuit['segmtsCircuit']):
#    print i, load

print '-----------------------------------------------------------------'
print 

j = 0
line = listado[j]
for circuit in circuits:
    print
    print 'R3 ->', ' depto: ', circuit['depto'], ' fraccion: ', circuit['frac'], ' radio: ', circuit['radio']
    print
    manzana = line['mnza']
    if circuit['segmtsCircuit']:
#        print circuit['blocks'], circuit['segmtsCircuit']
        for i, load in enumerate(circuit['segmtsCircuit']):
            print 'segmento: ', i+1, 'manzana: ', manzana, ' cantidad de viviendas: ', load
            direccion = listado[j]
            print 'desde: ', direccion['nombre'], ' ', direccion['numero'], ' ', direccion['cuerpo'], ' ', direccion['piso']
            s = 0
            while j < len(listado)-1 and s < load:
                s += int(listado[j]['count'])
                j += 1
            direccion = listado[j-1]
            print 'hasta: ', direccion['nombre'], ' ', direccion['numero'], ' ', direccion['cuerpo'], ' ', direccion['piso']
    else:
        while j < len(listado) and listado[j] == manzana:
            j += 1
    if circuit['segmtsCircuit'] is tuple:
        print "No se puede segmentar con metodo segMaker entre " + str(n) + " y " + str(m)
    manzana = listado[j-1]['mnza']

    if j < len(listado):
        line = listado[j]

