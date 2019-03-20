"""
deprecado
algoritmo base que fue usado en presentación del método en varias conferencias
"""
def segMaker(seq,n,m):
    if sum(seq) < n:        # too short
        return None         # base case returns not segmentable
    if n <= sum(seq) <= m:  # right size
        return [sum(seq)]   # base case returns the segment length
    else:
        i, s, heads = 0, 0, []              # init variables
        # crear una lista de ramas ya exploradas
        while i < len(seq) and s < n:       # get upto sgm len lower bound
            i, s = i+1, s+seq[i]
        while i < len(seq) and n <= s <= m: # while feasible
            # chequear que el candidato no haya sido ya explorado
            heads.append((i, [s]))          # add candidates to explore
            i, s = i+1, s+seq[i]
        # call a function to sort heads with heuristic
        while heads:
            i, candidate = heads.pop()
            tail = seq[i:]
            sgms = segMaker(tail,n,m)
            if sgms:
                candidate.extend(sgms)
                return candidate
