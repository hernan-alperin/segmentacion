# -*- coding: utf-8 -*-
import psycopg2
from segmentacion import (
        Segmento, ColeccionSegmentos, Segmentacion)
import dao
import operator
import logging
logging.basicConfig(filename='radio.log',
                    format='%(asctime)s %(levelname)s:%(message)s',
                    # datefmt='%d/%m/%Y %I:%M:%S %p',
                    level=logging.DEBUG
                    )

class Radio:

    def __init__(self, shape, prov, depto, frac, radio):
        logging.info(" iniciando radio de shape : " + shape
                + " P D F R = " + str(prov) + " " + str(depto)
                + " " + str(frac) + " " + str(radio) + "\n")
        self.db = dao.DAO()
        self.manzanas = self.db.get_ColeccionManzanas(
            prov, depto, frac, radio)
        self.lados = self.db.get_ColeccionLados(
            prov, depto, frac, radio)
        self.segmentos = ColeccionSegmentos()

#        for mza in self.manzanas:  # init segmentos with a single manzana each
#            sgm = Segmento([mza])
#           self.segmentos.append(sgm)
        self.segmentos = Segmentacion([Segmento(self.manzanas)])
        # init one only segmento with all manzanas

    def __str__(self):
        return (
                "\n".join([str(mza) for mza in self.manzanas]) + "\n\n"
        #        + "\n".join([str(lado) for lado in self.lados]) + "\n\n"
                + str(self.segmentos).replace("\n", "\n  ") + " \n")

    def optimizar_segmentacion(self, segmentacion):
        #TODO: ver porqué no loggea
        logging.info(" segmentacion: " + str(segmentacion))
#        print (" radio.py - segmentacion: " + str(segmentacion))
        costo_minimo = float('inf')
        vecinos = segmentacion.vecindario()
        print segmentacion
#        print vecinos
        
        solucion = segmentacion
        costo_actual = segmentacion.costo()
#        print (" radio.py - costo: " + str(costo_actual))
        costos_vecinos = list(vecino.costo() for vecino in vecinos)
#        print ("vecino: " + str(vecino.manzana) 
#            + "costo_vecino: " + str(vecino.costo()) for vecino in vecinos)
        while min(costos_vecinos) < costo_actual:
            mejor_costo = min(costos_vecinos)
            min_id = costos_vecinos.index(mejor_costo)
            solucion = vecinos[min_id]
            costo_actual = solucion.costo()
            vecinos = list(solucion.vecindario())
            costos_vecinos = list(vecino.costo() for vecino in vecinos)
#            print costo_actual
#            print solucion
        return solucion

        # hasta acá llegamos...
 
