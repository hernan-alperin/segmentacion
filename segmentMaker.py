n, m = 5, 8

def segMaker(seq,n=n,m=m):
	if sum(seq) < n:		# too short
		return None		# base case returns not segmentable
	if n <= sum(seq) <= m:		# right size
		return [seq]	# base case returns the segment 
	else:
		i, s, heads = 0, [], []			# init variables
		while i < len(seq) and sum(s) < n:		# get upto sgm len lower bound
			s.append(seq[i])
			i = i+1
		temp=[]
		while i < len(seq) and n <= sum(s) <= m:	# while feasible
			temp= s
			heads.append((i, s[:]))		# add candidates to explore
			s.append(seq[i])
			i = i+1

# sort heads with heuristic
		temp = []
		while heads:
			i, candidate = heads.pop()
			tail = seq[i:]
			sgms = segMaker(tail)
			if sgms:
				temp.append(candidate)
				temp.extend(sgms)
				return temp 


cases = [
	[2,8,3,4,1,1,3],
	[2,2,3,4,8,1,3],
	[2,3,3,4,1,1,3],
	[2,3,4,1,1,3],
	[2,4,1,1,3],
	[2,1,3],
	[4,5,4,5,4],
	]

for case in cases:
	print '-- --'
	print case, ' => ', segMaker(case)
