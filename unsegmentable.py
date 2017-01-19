def unsegmentable(c,n,m):
    if m < n: return True # safe
    i = 1
    while (i-1)*m < i*n:
        if (i-1)*m < c < i*n: return True # it's in an imposible window
        i += 1
    return False

n, m = 32, 40

c = 31; print c, ' -> ', unsegmentable(c,n,m)
c = 32; print c, ' -> ', unsegmentable(c,n,m)
c = 35; print c, ' -> ', unsegmentable(c,n,m)
c = 40; print c, ' -> ', unsegmentable(c,n,m)
c = 41; print c, ' -> ', unsegmentable(c,n,m)
c = 63; print c, ' -> ', unsegmentable(c,n,m)
c = 64; print c, ' -> ', unsegmentable(c,n,m)
c = 65; print c, ' -> ', unsegmentable(c,n,m)
c = 79; print c, ' -> ', unsegmentable(c,n,m)
c = 80; print c, ' -> ', unsegmentable(c,n,m)
c = 81; print c, ' -> ', unsegmentable(c,n,m)
c = 95; print c, ' -> ', unsegmentable(c,n,m)
c = 96; print c, ' -> ', unsegmentable(c,n,m)
c = 97; print c, ' -> ', unsegmentable(c,n,m)
c = 119; print c, ' -> ', unsegmentable(c,n,m)
c = 120; print c, ' -> ', unsegmentable(c,n,m)
c = 121; print c, ' -> ', unsegmentable(c,n,m)
c = 127; print c, ' -> ', unsegmentable(c,n,m)
c = 128; print c, ' -> ', unsegmentable(c,n,m)
c = 129; print c, ' -> ', unsegmentable(c,n,m)
c = 160; print c, ' -> ', unsegmentable(c,n,m)
c = 161; print c, ' -> ', unsegmentable(c,n,m)
c = 1000; print c, ' -> ', unsegmentable(c,n,m)




