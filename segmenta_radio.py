'''
Segmentador de manzanas y lados
'''

class manzana
    """ clase de manzanas de un radio
    """
    cant = 0

    def __init__(self, lados):
        self.lados = []
        self.viviendas = sum(lados.viviendas)



class bloque:
    'clase de unidades compuestas por manzanas y lados que van a ser finalmente los segmentos'
    def adyacentes():
        'explicación del método, van a ser muchísimos :-P' 
        pass
    def partir():
        'cómo voy a partirlo?'
        pass
    def adyacente(bloque):
        """ para verificar adyacencias
        por ahora devuelve falso
        This is a longer explanation, which may include math with latex syntax
        :math:`\\alpha`.
        Then, you need to provide optional subsection in this order (just to be
        consistent and have a uniform documentation. Nothing prevent you to
        switch the order):

          - parameters using ``:param <name>: <description>``
          - type of the parameters ``:type <name>: <description>``
          - returns using ``:returns: <description>``
          - examples (doctest)
          - seealso using ``.. seealso:: text``
          - notes using ``.. note:: text``
          - warning using ``.. warning:: text``
          - todo ``.. todo:: text``

        **Advantages**:
         - Uses sphinx markups, which will certainly be improved in future
           version
         - Nice HTML output with the See Also, Note, Warnings directives


        **Drawbacks**:
         - Just looking at the docstring, the parameter, type and  return
           sections do not appear nicely

        :param arg1: the first value
        :param arg2: the first value
        :param arg3: the first value
        :type arg1: int, float,...
        :type arg2: int, float,...
        :type arg3: int, float,...
        :returns: arg1/arg2 +arg3
        :rtype: int, float

        :Example:

        >>> import template
        >>> a = template.MainClass1()
        >>> a.function1(1,1,1)
        2

        .. note:: can be useful to emphasize
            important feature
        .. seealso:: :class:`MainClass2`
        .. warning:: arg2 must be non-zero.
        .. todo:: check that arg2 is non zero.
        """
        return False





