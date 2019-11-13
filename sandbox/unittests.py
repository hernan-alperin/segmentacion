# -*- coding: utf-8 -*-
from segmentaciones import *
from random import *
import unittest
import logging
logging.basicConfig(filename='unittest.log',
                    format='%(asctime)s %(levelname)s:%(message)s',
                    datefmt='%d/%m/%Y %I:%M:%S %p',
                    level=logging.DEBUG
                    )


"""

    1 <- 2 -> 4 -> 5 
         |
         v
         3

componentes = [1, 2, 3, 4, 5]
adyacencias = [(2,1), (2,3), (2,4), (4,5)]

"""

c1 = Componente(1, 8)
c2 = Componente(2, 5)
c3 = Componente(3, 7)
c4 = Componente(4, 10)
c5 = Componente(5, 10)

c2.agregar_adyacencia(c1)
c2.agregar_adyacencia(c3)
c2.agregar_adyacencia(c4)
c4.agregar_adyacencia(c5)

componentes = Componentes([c1, c2, c3, c4, c5])

seg_123 = Segmento([c1, c2, c3])
seg_45 = Segmento([c4, c5])
sgmt = Segmentacion([seg_123, seg_45])

logging.info(sgmt)
logging.info(sgmt.vecindario())

class TestComponentesMethods(unittest.TestCase):

    def test_ids(self):
        assert componentes.ids() == set([1, 2, 3, 4, 5])
        assert componentes.ids() != set([1, 2, 3, 4, 6])
        assert componentes.ids() != set([1, 2, 3, 4])

    def test_min_id(self):
        assert componentes.min_id() == 1

        assert Componentes([Componente(3, 8)]).min_id() == 3
        assert Componentes([Componente(3, 8), Componente(4, 3)]).min_id() == 3
        assert Componentes([Componente(4, 8), Componente(2, 3)]).min_id() == 2 
        c1 = Componente(1, 8)
        c2 = Componente(2, 5)
        c3 = Componente(4, 5)
        assert Componentes([c3, c2]).min_id() == 2

    def test_clausura_conexa(self):
        c0 = Componente(0, 0)
        assert componentes.clausura_conexa(c0).ids() == Componentes().ids()
        assert componentes.clausura_conexa(c1).ids() == Componentes([c1]).ids()
        assert componentes.clausura_conexa(c4).ids() == Componentes([c4, c5]).ids()
        assert componentes.clausura_conexa(c2).ids() == componentes.ids()
        assert componentes.clausura_conexa(c1) == Componentes([c1])
        assert componentes.clausura_conexa(c4) == Componentes([c4, c5])
        assert componentes.clausura_conexa(c2) == componentes

    def test_conectados(self):
        assert Componentes([c4, c5]).conectados()
        assert ~Componentes([c1, c5]).conectados()
        assert Componentes([c4]).conectados()

    def test_extraer_componente(self):
        assert Componentes([c4, c5]).extraer_componente(c1) == []
        assert Componentes([c4, c5]).extraer_componente(c4) == [Componentes([c5])]
        assert (Componentes([c2, c4, c5]).extraer_componente(c4)
                == [Componentes([c2]), Componentes([c5])])
        assert (Componentes([c2, c4, c1, c3]).extraer_componente(c2)
                == [Componentes([c1]), Componentes([c3]), Componentes([c4])])
        assert (Componentes([c2, c4, c1, c3]).extraer_componente(c2)
                == sorted([Componentes([c4]), Componentes([c1]), Componentes([c3])], key=lambda cs: cs.min_id())
                )

    def test_transferir_componente(self):
        assert ~Componentes([c1]).transferir_componente(c3, Componentes([c2]))
        assert ~Componentes([c1, c2]).transferir_componente(c1, Componentes([c5])) 
        assert (Componentes([c2]).transferir_componente(c2, Componentes([c1]))
                == [sorted(Componentes([c1, c2]), key=lambda c: c.c_id)]
                )
        assert (Componentes([c2, c4]).transferir_componente(c4, Componentes([c5]))
                == [
                    Componentes([c2]),
                    Componentes([c4, c5])
                    ]
                )
        assert (Componentes([c1, c2]).transferir_componente(c2, Componentes([c3]))
                == [
                    Componentes([c1]),
                    Componentes([c2, c3])
                    ]
                )
        assert (Componentes([c4, c5]).transferir_componente(c4, Componentes([c2]))
                != [
                    Componentes([c5]),
                    Componentes([c2, c4])
                    ]
                ) # se respeta la adyacencia asimétrica: c4 -!-> c2 (no es adyacente)

        assert (Componentes([c2, c4]).transferir_componente(c4, Componentes([c5]))
                == sorted(
                    Componentes([c2, c4]).extraer_componente(c4)
                    + [Componentes(sorted(Componentes([c5] + [c4]), key=lambda c: c.c_id))]
                    , key=lambda cs: cs.min_id())
                )
    
    def test_unir_componente(self):
        assert ~Componentes([c1]).unir_componentes(Componentes([c3]))
        assert (Componentes([c2]).unir_componentes(Componentes([c1]))
                == Componentes([c2, c1])
                )
        assert (Componentes([c1]).unir_componentes(Componentes([c2]))
                == Componentes([c1, c2])
                ) ## para Componentes no es necesaria la adyacencia asimétrica: c1 -!-> c2 (no es adyacente)



if __name__ == '__main__':
    unittest.main()

