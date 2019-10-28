from segmentaciones import *
from random import *
import unittest

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

class TestComponentesMethods(unittest.TestCase):

    def test_ids(self):
#        self.assertEqual(componentes.ids(), [1, 2, 3, 4, 5]) # standard unittest
        assert componentes.ids() == [1, 2, 3, 4, 5]
        assert componentes.ids() != [1, 2, 3, 4, 6]
        assert componentes.ids() != [1, 2, 3, 4]

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
        assert componentes.clausura_conexa(c0) == Componentes()
        assert componentes.clausura_conexa(c1) == Componentes([c1])
        assert componentes.clausura_conexa(c4) == Componentes([c4, c5])
        assert componentes.clausura_conexa(c2) == componentes

if __name__ == '__main__':
    unittest.main()
