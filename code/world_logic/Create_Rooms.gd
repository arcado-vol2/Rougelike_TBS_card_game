extends Node2D

var Room=preload("res://scenes/world/Room.tscn")
var unit=preload("res://scenes/units/unit.tscn")

var startroom=null
var endroom=null
var tile_size=32
var room_nums=10
var min_size=4
var max_size=6
export var hspread=200
export var vspread=100
var culchance=0.5
var path
onready var Map=$TileMap
var trimtiles=2

func _ready():
	generate()

func generate():
	make_rooms()
	yield(get_tree().create_timer(5),"timeout")
	Make_Map()
	place_objectives()

func make_rooms():
	randomize()
	for i in range(room_nums):
		var pos=Vector2(rand_range(-hspread,hspread),rand_range(-vspread,vspread))
		var rm=Room.instance()
		var width = min_size + randi() % (max_size-min_size+1) + trimtiles
		var height = min_size + randi() % (max_size-min_size+1) + trimtiles
		rm.make_room(pos,Vector2(width,height)*tile_size)
		$Rooms.add_child(rm)
	yield(get_tree().create_timer(3), 'timeout')
	var room_positions=[]
	for room in $Rooms.get_children():
		if randf() < culchance:
			room.queue_free()
		else:
			room.mode=RigidBody.MODE_STATIC
			room.get_child(0).shape=null
			room_positions.append(room.position)
		yield(get_tree(),'idle_frame')
	path=find_mst(room_positions)

func find_mst(coord):
	#Prim's algorithm
	path=AStar2D.new()
	path.add_point(path.get_available_point_id(),coord.pop_front())
	while coord: #Repeat until there're no disconnected rooms
		var min_dist= INF 
		var min_p=null
		var p=null #current node position
		for p1 in path.get_points():
			p1=path.get_point_position(p1)
			for p2 in coord:
				if p1.distance_to(p2) < min_dist:
					min_dist=p1.distance_to(p2)
					min_p=p2
					p=p1
		var id = path.get_available_point_id()
		path.add_point(id, min_p)
		path.connect_points(path.get_closest_point(p),id)
		coord.erase(min_p)
	return path

func _draw():
	for room in $Rooms.get_children():
		draw_rect(Rect2(room.position-room.size,room.size*2), Color(32,228,0), false)
	if path:
		for first in path.get_points():
			for second in path.get_point_connections(first):
				var fpos= path.get_point_position(first)
				var spos= path.get_point_position(second)
				draw_line(fpos,spos,Color(32,228,0))

func Make_Map():
	for x in range(-200,201):
		for y in range(-200,201):
			Map.set_cell(x,y,1)
	var corridors=[]
	for room in $Rooms.get_children():
		var st=(room.size/tile_size).floor()
		var pos=(room.position/tile_size).floor()
		var ul=pos-st
		for x in range(1+trimtiles,st.x*2-trimtiles+1):
			for y in range(1+trimtiles,st.y*2-trimtiles+1):
				Map.set_cell(ul.x+x,ul.y+y,0)
		var p = path.get_closest_point(room.position)
		for conn in path.get_point_connections(p):
			if not conn in corridors:
				var start = Map.world_to_map(path.get_point_position(p))
				var end = Map.world_to_map(path.get_point_position(conn))
				curve_path(start,end)
			corridors.append(p)

func curve_path(start,end):
	var ch=randi()%2
	var x_diff = sign(end.x-start.x)
	var y_diff=sign(end.y-start.y)
	if x_diff==0: x_diff=pow(-1,randi()%2)
	if y_diff==0: y_diff=pow(-1,randi()%2)
	var x_y=start
	var y_x=end
	if (randi()%2)>0:
		x_y=end
		y_x=start
	for x in range(start.x,end.x,x_diff):
		Map.set_cell(x,x_y.y,0)
		if ch==0:
			Map.set_cell(x,x_y.y+y_diff,0)
		else:
			Map.set_cell(x,x_y.y-y_diff,0)
	for y in range(start.y,end.y,y_diff):
		Map.set_cell(y_x.x,y,0)
		if ch==0:
			Map.set_cell(y_x.x+x_diff,y,0)
		else:
			Map.set_cell(y_x.x-x_diff,y,0)

func _process(delta):
	update()

func place_objectives():
	var pos
	for p in path.get_points():
		startroom = path.get_point_position(p)
	var unit1 = unit.instance()
	unit1.position=startroom
	get_tree().current_scene.find_node('YSort').add_child(unit1)

#func _input(event):
#	if event.is_action_pressed("ui_select"):
#		Map.clear()
#		for room in $Rooms.get_children():
#			room.queue_free()
#		path=null
#		generate()
