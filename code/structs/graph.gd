extends Node

class_name Graph

var V
var adj = []
var adj_2 = []
var peaks = []

func _init(points , trinag = false):
	var n = []
	if trinag:
		var tmp = Geometry.triangulate_delaunay_2d(points)
		for i in len(tmp)/3:
			for j in range(3):
				n.append(points[tmp[(i*3)+j]])
		for i in n:
			if not i in peaks:
				peaks.append(i)
	else:
		peaks = points
	
	V = len(peaks)
	for i in range(V):
		adj.append([])
	
	if trinag:
		for i in len(n)/3:
			add_edge(peaks.find(n[i*3]), peaks.find(n[i*3+1]))
			add_edge(peaks.find(n[i*3]), peaks.find(n[i*3+2]))
			add_edge(peaks.find(n[i*3+2]), peaks.find(n[i*3+1]))
	
	


func _DFS_util(temp, v, visited):
	visited[v] = true 
	temp.append(v)
	for i in self.adj[v]:
		if visited[i] == false:
			temp = _DFS_util(temp, i, visited)
	return temp

func add_edge(v, w):
	if not Vector2(min(v,w),max(w,v)) in adj_2:
		adj_2.append(Vector2(min(v,w),max(w,v)))
	if not w in adj[v]:
		adj[v].append(w)
	if not v in adj[w]:
		adj[w].append(v)

func delete_edge(v, w):
	
	adj[v].erase(int(w))
	adj[w].erase(int(v))
	adj_2.erase(Vector2(min(v,w),max(w,v)))
	

func connected_components():
	var visited = []
	var cc = []
	for i in range(V):
		visited.append(false)
	for v in range(V):
		if not visited[v]:
			var temp = []
			cc.append(_DFS_util(temp, v, visited))
	return cc

func get_distance(a, b):
	return sqrt(pow(peaks[a][0] -peaks[b][0],2) + pow(peaks[a][1] -peaks[b][1],2))   

#Тут бабл макс, потому что так и так прохожу весь массив
func _get_max_edge():
	var tmp = {}
	var mx = 0 
	var ans
	for i in len(adj):
		for j in len(adj[i]):
			tmp[Vector2(i,j)] = get_distance(i,j)
			if get_distance(i,j) > mx:
				mx = get_distance(i,j)
				ans = Vector2(i,j)
	return ans

func _compare_distance(a,b):
	if get_distance(a[0],a[1]) < get_distance(b[0],b[1]):
		return false
	else:
		return true



func create_min_connected(count_of_loops = 0):
	var adj_old
	if count_of_loops != 0:
		adj_old = adj_2.duplicate()
	
	var iter = 0
	adj_2.sort_custom(self,"_compare_distance")
	while iter < len(adj_2):
		var tmp = adj_2[iter]
		delete_edge(adj_2[iter].x, adj_2[iter].y)
		if len(connected_components())!=1:
			add_edge(tmp.x, tmp.y)
			iter+=1
	adj_2 = []
	for n in len(adj):
		for j in adj[n]:
			if not Vector2(min(n,j), max(n,j)) in adj_2:
				adj_2.append(Vector2(min(n,j), max(n,j)))
	if count_of_loops !=0:
		var tmp = 0
		for i in adj_old:
			if not i in adj_2:
				adj_2.append(i)
				add_edge(i.x, i.y)
				tmp+=1
			if tmp == count_of_loops:
				break
