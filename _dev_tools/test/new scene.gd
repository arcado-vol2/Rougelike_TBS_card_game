extends Node

onready var tile_map = $TileMap


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
	
