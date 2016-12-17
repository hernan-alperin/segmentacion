n, m = 5, 8

def segMaker(seq,n=n,m=m):
	if sum(seq) < n:		# too short
		return None		# base case returns not segmentable
	if n <= sum(seq) <= m:		# right size
		return [sum(seq)]	# base case returns the segment length
	else:
		i, s, heads = 0, 0, []			# init variables
		while i < len(seq) and s < n:		# get upto sgm len lower bound
			i, s = i+1, s+seq[i]
		while i < len(seq) and n <= s <= m:	# while feasible
			heads.append((i, [s]))		# add candidates to explore
			i, s = i+1, s+seq[i]
		# sort heads with heuristic
		while heads:
			i, candidate = heads.pop()
			tail = seq[i:]
			sgms = segMaker(tail)
			if sgms:
				candidate.extend(sgms)
				return candidate


cases = [
	[2,3,3,4,1,1,3],
	[2,3,4,1,1,3],
	[2,4,1,1,3],
	[2,1,3],
	[4,5,4,5,4],
	]

for case in cases:
	print case, segMaker(case)



