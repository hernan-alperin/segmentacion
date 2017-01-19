def segmentMaker(seq,n,m):
    if sum(seq) < n:
        return None
    if n <= sum(seq) <= m: 
        return [sum(seq)]
    else:
        i = 0
        s = 0
        ixs = []
        cs = []
        while i < len(seq) and s < n: 
            s += seq[i]
            i += 1
        while i < len(seq) and s <= m: # armoo la lista de cabezas a cortar
            ixs.append(i)
            cs.append(s)
            s += seq[i]
            i += 1
        # sort cs
        while cs != []:
            i = ixs.pop()
            sg = [cs.pop()]
            tail = seq[i:]
            sgs = segmentMaker(tail,n,m)
            if sgs:
                sg.extend(sgs)
                return sg

n = 5; m = 8 
lists = [
    [1,1,1,1,1],
    [5,5,1,1,1],
    [5,1,1,1,5],
    [5,7,1,1,5],
    [5,7,5,1,5],
    [5,7,5,6,5],
    [5,7,6,7,5],
    [5,7,6,7,5],
    [4,5,4,5,4],
    ]
    
for list in lists:
    print list, segmentMaker(list,n,m)
