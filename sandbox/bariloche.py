"""
ejemplo de Bariloche Frac:10 Radio 10
con componentes lados

          +--11--+ +--21--+ +--31--+ 
          |      | |      | |      | 
          14    12 24    22 34    32 
          |      | |      | |      | 
          +--13--+ +--23--+ +--33--+ 
 +--71--+ +--61--+ +--51--+ +--41--+
 |      | |      | |      | |      |
 74    72 64    62 54    52 44    42
 |      | |      | |      | |      |
 +--73--+ +--63--+ +--53--+ +--43--+
 +--81--+ +--91--+ +-101--+ +-111--+
 |      | |      | |      | |      |
 84    82 94    92 104  102 114  112
 |      | |      | |      | |      |
 +--83--+ +--93--+ +-103--+ +-113--+

"""
from segmentaciones import *
from random import *

c11 = Componente(11, 17)
c12 = Componente(12, 4)
c13 = Componente(13, 16)
c14 = Componente(14, 15)
c21 = Componente(21, 12)
c22 = Componente(22, 11)
c23 = Componente(23, 8)
c24 = Componente(24, 3)
c31 = Componente(31, 18)
c32 = Componente(32, 6)
c33 = Componente(33, 13)
c34 = Componente(34, 4)
c41 = Componente(41, 5)
c42 = Componente(42, 5)
c43 = Componente(43, 9)
c44 = Componente(44, 3)
c51 = Componente(51, 9)
c52 = Componente(52, 8)
c53 = Componente(53, 3)
c54 = Componente(54, 0)
c61 = Componente(61, 27)
c62 = Componente(62, 2)
c63 = Componente(63, 13)
c64 = Componente(64, 11)
c71 = Componente(71, 17)
c72 = Componente(72, 5)
c73 = Componente(73, 21)
c74 = Componente(74, 6)
c81 = Componente(81, 18)
c82 = Componente(82, 9)
c83 = Componente(83, 18)
c84 = Componente(84, 4)
c91 = Componente(91, 23)
c92 = Componente(92, 2)
c93 = Componente(93, 9)
c94 = Componente(94, 7)
c101 = Componente(101, 6)
c102 = Componente(102, 4)
c103 = Componente(103, 9)
c104 = Componente(104, 0)
c111 = Componente(111, 0)
c112 = Componente(112, 0)
c113 = Componente(113, 0)
c114 = Componente(114, 1)

# doblar
c11.agregar_adyacencia(c12)
c12.agregar_adyacencia(c13)
c13.agregar_adyacencia(c14)
c14.agregar_adyacencia(c11)

c21.agregar_adyacencia(c22)
c22.agregar_adyacencia(c23)
c23.agregar_adyacencia(c24)
c24.agregar_adyacencia(c21)

c31.agregar_adyacencia(c32)
c32.agregar_adyacencia(c33)
c33.agregar_adyacencia(c34)
c34.agregar_adyacencia(c31)

c41.agregar_adyacencia(c42)
c42.agregar_adyacencia(c43)
c43.agregar_adyacencia(c44)
c44.agregar_adyacencia(c41)

c51.agregar_adyacencia(c52)
c52.agregar_adyacencia(c53)
c53.agregar_adyacencia(c54)
c54.agregar_adyacencia(c51)

c61.agregar_adyacencia(c62)
c62.agregar_adyacencia(c63)
c63.agregar_adyacencia(c64)
c64.agregar_adyacencia(c61)

c71.agregar_adyacencia(c72)
c72.agregar_adyacencia(c73)
c73.agregar_adyacencia(c74)
c74.agregar_adyacencia(c71)

c81.agregar_adyacencia(c82)
c82.agregar_adyacencia(c83)
c83.agregar_adyacencia(c84)
c84.agregar_adyacencia(c81)

c91.agregar_adyacencia(c92)
c92.agregar_adyacencia(c93)
c93.agregar_adyacencia(c94)
c94.agregar_adyacencia(c91)

c101.agregar_adyacencia(c102)
c102.agregar_adyacencia(c103)
c103.agregar_adyacencia(c104)
c104.agregar_adyacencia(c101)

c111.agregar_adyacencia(c112)
c112.agregar_adyacencia(c113)
c113.agregar_adyacencia(c114)
c114.agregar_adyacencia(c111)

# volver
c12.agregar_adyacencia(c24)
c24.agregar_adyacencia(c12)

c13.agregar_adyacencia(c61)
c61.agregar_adyacencia(c13)

c23.agregar_adyacencia(c51)
c51.agregar_adyacencia(c23)

c22.agregar_adyacencia(c34)
c34.agregar_adyacencia(c22)

c33.agregar_adyacencia(c41)
c41.agregar_adyacencia(c33)

c72.agregar_adyacencia(c64)
c64.agregar_adyacencia(c72)

c73.agregar_adyacencia(c81)
c81.agregar_adyacencia(c73)

c62.agregar_adyacencia(c54)
c54.agregar_adyacencia(c62)

c63.agregar_adyacencia(c91)
c91.agregar_adyacencia(c63)

c52.agregar_adyacencia(c44)
c44.agregar_adyacencia(c52)

c53.agregar_adyacencia(c101)
c101.agregar_adyacencia(c53)

c82.agregar_adyacencia(c94)
c94.agregar_adyacencia(c82)

c43.agregar_adyacencia(c111)
c111.agregar_adyacencia(c43)

c92.agregar_adyacencia(c104)
c104.agregar_adyacencia(c92)

c102.agregar_adyacencia(c114)
c114.agregar_adyacencia(c102)

# cruzar
c11.agregar_adyacencia(c21)
c21.agregar_adyacencia(c31)

c71.agregar_adyacencia(c61)
c61.agregar_adyacencia(c51)
c51.agregar_adyacencia(c41)

c81.agregar_adyacencia(c91)
c91.agregar_adyacencia(c101)
c101.agregar_adyacencia(c111)

c33.agregar_adyacencia(c23)
c23.agregar_adyacencia(c13)

c43.agregar_adyacencia(c53)
c53.agregar_adyacencia(c63)
c63.agregar_adyacencia(c73)

c113.agregar_adyacencia(c103)
c103.agregar_adyacencia(c93)
c93.agregar_adyacencia(c83)

c84.agregar_adyacencia(c74)

c94.agregar_adyacencia(c64)
c64.agregar_adyacencia(c14)

c104.agregar_adyacencia(c54)
c54.agregar_adyacencia(c24)

c114.agregar_adyacencia(c44)
c44.agregar_adyacencia(c34)

c32.agregar_adyacencia(c42)
c42.agregar_adyacencia(c112)

c22.agregar_adyacencia(c52)
c52.agregar_adyacencia(c102)

c12.agregar_adyacencia(c62)
c62.agregar_adyacencia(c92)

c72.agregar_adyacencia(c92)

componentes = Componentes([
             c11,       c21,       c31,
          c14,  c12, c24,  c22, c34,  c32,
             c13,       c23,       c33,
   c71,      c61,       c51,       c41,     
c74,  c72,c64,  c62, c54,  c52, c44,  c42,
   c73,      c63,       c53,       c43,
   c81,      c91,       c101,       c111,     
c84,  c82,c94,  c92, c104,  c102, c114,  c112,
   c83,      c93,       c103,       c113,
])
print ('-----------------------componentes-------------')
print ('-----------------------adyacencias-------------')
for c in componentes:
    adys = []
    for a in c.adyacentes:
        adys.append(a.id)
    print (c.id, '(', c.vivs,')', adys)

print ('-----------------------segmenta----------------')
soluciones = Segmentaciones()
segmenta(Segmentos(), componentes, soluciones)
print ('-----------------------unicas-------------------')
sols = Soluciones()
for sol in sols:
    print (sol)



