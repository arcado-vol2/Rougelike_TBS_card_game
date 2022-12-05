extends YSort
var prefabs
var BSP_script= load("res://code/world_logic/BSP_script.gd")
var Cellular_script = load("res://code/world_logic/BSP_+_cellular.gd")
var BuildingPath_script = load("res://code/world_logic/Building_Path.gd")
var CurvedLine_script = load("res://code/world_logic/curved_line.gd")
var rng = RandomNumberGenerator.new()

onready var CreateRooms = $create_rooms
onready var floor_tilemap = $floor
onready var wals_tilemap = $wals
onready var astar_navigation_tilemap = $astar_nav_mesh
onready var rooms_node = $floor/rooms

enum location {
	cave,
	bunker,
	none,
}
export var location_type = location.cave

func _BSP():
	rng.randomize()
	var curvedLine = CurvedLine_script.new()
	curvedLine.setTilemap(floor_tilemap)
	#prefabs = [Save_load_system.load_prefab(), Save_load_system.load_file(1)]
	var BSP = BSP_script.new(0,200,0,200)
	BSP.name="Area"
	add_child(BSP)
	BSP.split()
	var room=$Area
	drawBSP(room)
	yield(get_tree().create_timer(6),"timeout")
	var positions =[]
	for cave in (rooms_node.get_children()):
		positions.append(Vector2(cave.start.x+cave.width/2,cave.start.y+cave.height/2))
	var path = BuildingPath_script.find_mst(positions)
	var ref = funcref(curvedLine,"suboptimal_path")
	BuildingPath_script.drawCorridors(ref,path,rooms_node)
#	Короче, тут Влад, удаляем всё и пишём лучше, вообще нужно подумать
#	о том как ускорить алгоритм кривых путем, я грешу на сам момент постановки
#	клеток, так как ты моджешь увидеть используется ебучий фор,
#	но если не использовать его, а что-то другое так при поворотах будет нет так
#	красиво, мб просто надо смещать созданую кривую тольшиной 1 вверх, чтобы утолщить,
#	но я хз насколько это будет быстрее, энивей надо попробовать
	for y in 300:
		for x in 300:
			var t = 0
			if floor_tilemap.get_cell(x*2, y*2) == 0:
				t+=1
			if floor_tilemap.get_cell(x*2+1, y*2) == 0:
				t+=1
			if floor_tilemap.get_cell(x*2, y*2+1) == 0:
				t+=1
			if floor_tilemap.get_cell(x*2+1, y*2+1) == 0:
				t+=1
			if t>=3:
				astar_navigation_tilemap.set_cell(x,y,0)
			if (floor_tilemap.get_cell(x-50,y-50)==-1):
				wals_tilemap.set_cell(x-50,y-4-50,0)
	wals_tilemap.update_bitmask_region()
#	а вот конец
	
	_on_create_rooms_generation_complete()
#	хз зачем это хранить, но храни, если хочешь, хотя я бы удалил
#	var corridors =[]
#	for cave in $Rooms.get_children():
#		var position = Vector2(cave.start.x+cave.width/2,cave.start.y+cave.height/2)
#		var p = path.get_closest_point(position)
#		for connection in path.get_point_connections(p):
#			if not connection in corridors:
#				var start = path.get_point_position(p)
#				var end = path.get_point_position(connection)
#				curvedLine.suboptimal_path(start,end,5,5,2)
#			corridors.append(p)

func drawBSP(room):
	if room.isLeaf():
			if (rng.randi()%3==0):
				var t = Cellular_script.new(Vector2(room.left,room.top),room.getWidth(),room.getHeight(),0.5,2)
				t.setMap(floor_tilemap)
				t.createRoom()
				t.name="cave"
				rooms_node.add_child(t)
	else:
		if(room.leftRoom!=null):
			drawBSP(room.leftRoom)
		if(room.rightRoom!=null):
			drawBSP(room.rightRoom)

func _cell():
	var t = Cellular_script.new(Vector2.ZERO, 20,20,0.5,2)
	t.setMap(floor_tilemap)
	t.createRoom()

func _createRooms():
	CreateRooms.setRooms(rooms_node)
	CreateRooms.setMap(floor_tilemap, astar_navigation_tilemap)
	CreateRooms.generate()

func _ready():
	match location_type:
		location.cave:
			_BSP()
		location.bunker:
			_createRooms()
	

func get_prefabs():
	return prefabs


func _on_create_rooms_generation_complete():
	get_parent().get_parent().start()
