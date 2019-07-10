"""
titulo: particiones.py
descripción: calcula todas las particiones posibles de los componentes
author: -h
fecha: 2019-06
"""
# ver https://stackoverflow.com/questions/19368375/set-partitions-in-python

def partition(collection):
    if len(collection) == 1:
        yield [ collection ]
        return

    first = collection[0]
    for smaller in partition(collection[1:]):
        # insert `first` in each of the subpartition's subsets
        for n, subset in enumerate(smaller):
            yield smaller[:n] + [[ first ] + subset]  + smaller[n+1:]
        # put `first` in its own subset 
        yield [ [ first ] ] + smaller


#something = list(range(1,5))

#for n, p in enumerate(partition(something), 1):
#    print(n, sorted(p))
