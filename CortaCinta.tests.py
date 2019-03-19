from CortaCinta import CortaCinta

cintas = [
[],
[1],
[1, 1],
[4, 5],
[2, 2, 2, 2],
[3, 2, 1, 1, 2],
]


n, m = 2, 3

for cinta in cintas:
  print (cinta, CortaCinta(cinta, n, m))
  
