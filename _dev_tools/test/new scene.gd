extends Node

onready var tile_map = $TileMap

<<<<<<< HEAD

const Graph = preload("res://code/structs/graph.gd")

=======
>>>>>>> d273f0d99a7d6fd0bebe6a4e9a5b029a083be7f9

func draw_ray(x1,y1,x2,y2):
	var dx = x2 - x1
	var dy = y2 - y1
	var sign_x = 1 if dx>0 else -1 if dx<0 else 0
	var sign_y = 1 if dy>0 else -1 if dy<0 else 0
	   
	if dx < 0: dx = -dx
	if dy < 0: dy = -dy
	
	var el
	var pdx
	var pdy
	var es
	if dx > dy:
		pdx = sign_x
		pdy = 0
		es = dy
		el = dx
	else:
		pdx = 0
		pdy = sign_y
		es = dx
		el = dy
		
	var x = x1
	var y = y1
	var error = el/2
	var t = 0    
	tile_map.set_cell(x,y,-1)

	while t < el:
		error -= es
		if error < 0:
			error += el
			x += sign_x
			y += sign_y
		else:
			x += pdx
			y += pdy
		t += 1
		tile_map.set_cell(x,y,1)

<<<<<<< HEAD

var g

func _ready():
	
	
	g = Graph.new([Vector2(30,30), Vector2(1,1), Vector2(16,10), Vector2(50,25), Vector2(30,20), Vector2(40,4)], true)
	for i in g.adj_2:
		draw_ray(g.peaks[i.x].x, g.peaks[i.x].y, g.peaks[i.y].x, g.peaks[i.y].y)
	print("--",g.adj,"--", g.connected_components())
	var j=0
	for i in g.peaks:
		#tile_map.set_cell(i.x, i.y, 0)
		var n = Label.new()
		n.text = str(j)
		n.margin_left = i.x*8
		n.margin_top = i.y *8
		add_child(n)
		j+=1



func _on_Button_pressed():

	for i in tile_map.get_used_cells():
		tile_map.set_cell(i.x, i.y, -1)
	#g.delete_edge(1,2)
	g.create_min_connected(2)
	for i in g.adj_2:
		draw_ray(g.peaks[i.x].x, g.peaks[i.x].y, g.peaks[i.y].x, g.peaks[i.y].y)


func _on_Button2_pressed():
	print("КАМПАНЕНТА СВЯЗНАСТИ:", g.connected_components())
	print("ADJ: ", g.adj)
	print("ADJ_2 : ", g.adj_2)



=======
func _ready():
	var points = [Vector2(1,1), Vector2(1,41), Vector2(41,41), Vector2(61,1), Vector2(21,21)]
	var tmp = Geometry.triangulate_delaunay_2d(points)
	var tmp2 = []
	for i in len(tmp)/3:
		for n in range(3):
			tmp2.append(points[tmp[(i*3)+n]])
			
	var graf = {}
	for i in len(tmp2)/3:
	
		if not tmp2[i*3] in graf:
			graf[tmp2[i*3]] = []
		if not tmp2[i*3+1] in graf[tmp2[i*3]]:
			graf[tmp2[i*3]].append(tmp2[i*3+1])
		if not tmp2[i*3+2] in graf[tmp2[i*3]]:
			graf[tmp2[i*3]].append(tmp2[i*3+2])
		
		if not tmp2[i*3+1] in graf:
			graf[tmp2[i*3+1]] = []
		if not tmp2[i*3] in graf[tmp2[i*3+1]]:
			graf[tmp2[i*3+1]].append(tmp2[i*3])
		if not tmp2[i*3+2] in graf[tmp2[i*3+1]]:
			graf[tmp2[i*3+1]].append(tmp2[i*3+2])
		
		if not tmp2[i*3+2] in graf:
			graf[tmp2[i*3+2]] = []
		if not tmp2[i*3] in graf[tmp2[i*3+2]]:
			graf[tmp2[i*3+2]].append(tmp2[i*3])
		if not tmp2[i*3+1] in graf[tmp2[i*3+2]]:
			graf[tmp2[i*3+2]].append(tmp2[i*3+1])
	
	for i in graf:
		for j in graf[i]:
			draw_ray(i.x,i.y,j.x,j.y)
		
	for i in graf:
		print(i," --> ",graf[i])
		tile_map.set_cell(i.x,i.y,0)
	
>>>>>>> d273f0d99a7d6fd0bebe6a4e9a5b029a083be7f9
