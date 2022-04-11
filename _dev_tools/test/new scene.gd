extends Node

onready var tile_map = $TileMap


const Graph = preload("res://code/structs/graph.gd")


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
	g.create_min_connected()
	for i in g.adj_2:
		draw_ray(g.peaks[i.x].x, g.peaks[i.x].y, g.peaks[i.y].x, g.peaks[i.y].y)


func _on_Button2_pressed():
	print("КАМПАНЕНТА СВЯЗНАСТИ:", g.connected_components())
	print("ADJ: ", g.adj)
	print("ADJ_2 : ", g.adj_2)



