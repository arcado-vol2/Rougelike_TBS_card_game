extends Node

var Room=preload("res://scenes/world/Room.tscn")
var BuildingPath_script=load("res://code/world_logic/Building_Path.gd")

var startroom=null
var endroom=null
var tile_size=32
var room_nums=20
var min_size=4
var max_size=6
var Rooms
export var hspread=400
export var vspread=400
var culchance=0
var path
var Map
var astar_map
var trimtiles=3
var rooms_dict = {}

signal generation_complete

#func _ready():
#	generate()

func setMap(_Map, _astar_map):
	Map=_Map
	astar_map = _astar_map

func setRooms(_Rooms):
	Rooms=_Rooms

func generate():
	yield(make_rooms(), 'completed')
	Make_Map()
	emit_signal("generation_complete")


func _set_cell(x,y, cell = 0):
	Map.set_cell(x,y, cell)
	astar_map.set_cell(x,y, cell)
	
func make_rooms():
	randomize()
	for i in range(room_nums):
		var pos=Vector2(rand_range(-hspread,hspread),rand_range(-vspread,vspread))
		var rm=Room.instance()
		var width = min_size + randi() % (max_size-min_size+1) + trimtiles
		var height = min_size + randi() % (max_size-min_size+1) + trimtiles
		rm.make_room(pos,Vector2(width,height)*tile_size)
		Rooms.add_child(rm)
	yield(Rooms.get_tree().create_timer(0.2), 'timeout')
	var room_positions=[]
	for room in Rooms.get_children():
		if randf() < culchance:
			room.queue_free()
		else:
			room.setMapPosition((room.position/tile_size).floor())
			room.mode=RigidBody.MODE_STATIC
			room.get_child(0).shape=null
			room_positions.append(room.mapPosition)
		rooms_dict[room.mapPosition]=room
		yield(Rooms.get_tree(),'idle_frame')
	path=BuildingPath_script.find_mst(room_positions)


func Make_Map():
	var corridors=[]
	var ref = funcref(self, "curve_path")
	BuildingPath_script.drawCorridors(ref,path,Rooms)
	for room in Rooms.get_children():
		var st=(room.size/tile_size).floor()
		var pos=(room.position/tile_size).floor()
		var ul=pos-st
		for x in range(1+trimtiles,st.x*2-trimtiles+1):
			for y in range(1+trimtiles,st.y*2-trimtiles+1):
				_set_cell(ul.x+x,ul.y+y)

func curve_path(start,end):
	var startRoom=rooms_dict.get(start)
	var endRoom=rooms_dict.get(end)
	_set_cell(start.x,start.y,1)
	astar_map.set_cell(start.x,start.y, 0)
	var x_diff=sign(end.x-start.x)
	var y_diff=sign(end.y-start.y)
	if x_diff==0: x_diff=pow(-1,randi()%2)
	if y_diff==0: y_diff=pow(-1,randi()%2)
	var maxRoomX=max(startRoom.size.x, endRoom.size.x)/tile_size-trimtiles
	var maxRoomY=max(startRoom.size.y, endRoom.size.y)/tile_size-trimtiles
	if(abs(start.x-end.x)>=maxRoomX-2
	  and abs(start.x-end.x)<=maxRoomX+1):
		if(x_diff==1):
			end.x-=endRoom.size.x/tile_size-trimtiles-2
		elif(x_diff==-1):
			end.x+=endRoom.size.x/tile_size-trimtiles-1
	if(abs(start.y-end.y)>=maxRoomY-1
	  and abs(start.y-end.y)<=maxRoomY+1):
		if(y_diff==1):
			start.y+=startRoom.size.y/tile_size-trimtiles-2
		elif(y_diff==-1):
			start.y-=startRoom.size.y/tile_size-trimtiles-3
	var x_y=start
	var y_x=end
	if(true):
		for x in range(start.x,end.x,x_diff):
			_set_cell(x,x_y.y)
			_set_cell(x,x_y.y+y_diff)
		for y in range(start.y,end.y,y_diff):
			_set_cell(y_x.x,y)
			_set_cell(y_x.x+x_diff,y)
