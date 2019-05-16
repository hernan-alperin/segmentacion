non_segmentable_tails = []

def segMaker(seq, n, m, d=20):
    def pref(s, t):
        x, y = s[1][0], t[1][0]
        return abs(y-d) - abs(x-d) 
    if sum(seq) < n:        # too short
        non_segmentable_tails.append(seq)
        return None         # base case returns not segmentable
    if n <= sum(seq) <= m:  # right size
        return [sum(seq)]   # base case returns the segment length
    else:
        i, s, heads = 0, 0, []              # init variables
        while i < len(seq) and s < n:       # get upto sgm len lower bound
            s += seq[i]
            i += 1
        while i < len(seq) and n <= s <= m: # while feasible
            heads.append((i, [s]))          # add candidates to explore
            s += seq[i]
            i += 1
            # call a function to sort heads with heuristic
        heads.sort(pref)
        while heads:
            i, candidate = heads.pop()
            tail = seq[i:]
            if tail not in non_segmentable_tails:
                sgms = segMaker(tail,n,m)
                if sgms:
                    candidate.extend(sgms)
                    return candidate
                else:
                    non_segmentable_tails.append(tail)
import math

def NoFactibleCantidad(seq, n, m):
    v = sum(seq)
    for s in range(0, int(math.ceil((n - 1)/(m - n))) + 1):
        if s*m < v < (s + 1)*n:
            return s + 1
    return False

def NoFactiblePartirBloque(seq, n, m):
    if len(seq) > 1:
        for i, b in enumerate(seq):
            if b > m:
                return [b]        
            if b < n:
                if 0 < i < len(seq) - 1:
                    if seq[i - 1] + b > m and seq[i + 1] + b > m:
                        return seq[i - 1:i + 2]
                elif i == 0:
                    if seq[1] + b > m:
                        return seq[0:2]
                else:
                    if seq[i - 1] + b > m:
                        return seq[i - 1:i + 1]
    return False



