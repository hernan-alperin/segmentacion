import sys

c = int(sys.argv[1])
n = int(sys.argv[2])
m = int(sys.argv[3])

def segmentCountRange(c,n,m):   # returns the range (min, max) of possible number of segments bettween n and m housholds, given a total of c households
    if m < n: return None 
    i = 1
    while (i-1)*m < i*n:
        if (i-1)*m < c < i*n: return None # it's in an imposible window, no segmentation is possible for this value of c
        if i*n <= c <= i*m: return (i, i)
        i += 1
    return (c/m, c/n)

print c, n, m, segmentCountRange(c,n,m)


