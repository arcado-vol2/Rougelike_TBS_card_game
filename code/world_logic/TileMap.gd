extends TileMap
var prefabs
var BSP_script= load("res://code/world_logic/BSP_script.gd")
var Cellular_script = load("res://code/world_logic/BSP_+_cellular.gd")
var CreateRooms_script = load("res://code/world_logic/Create_Rooms.gd")
var BuildingPath_script = load("res://code/world_logic/Building_Path.gd")
var CurvedLine_script = load("res://code/world_logic/curved_line.gd")
var rng = RandomNumberGenerator.new()

func _BSP():
	rng.randomize()
	var curvedLine = CurvedLine_script.new()
	curvedLine.setTilemap(self)
	#prefabs = [Save_load_system.load_prefab(), Save_load_system.load_file(1)]
	var BSP = BSP_script.new(0,200,0,200)
	BSP.name="Area"
	add_child(BSP)
	BSP.split()
	var room=$Area
	drawBSP(room)
	yield(get_tree().create_timer(6),"timeout")
	var positions =[]
	for cave in ($Rooms.get_children()):
		positions.append(Vector2(cave.start.x+cave.width/2,cave.start.y+cave.height/2))
	var path = BuildingPath_script.find_mst(positions)
	var ref = funcref(curvedLine,"suboptimal_path")
	BuildingPath_script.drawCorridors(ref,path,$Rooms)
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
				t.setMap(self)
				t.createRoom()
				t.name="cave"
				$Rooms.add_child(t)
	else:
		if(room.leftRoom!=null):
			drawBSP(room.leftRoom)
		if(room.rightRoom!=null):
			drawBSP(room.rightRoom)

func _cell():
	var t = Cellular_script.new(Vector2.ZERO, 20,20,0.5,2)
	t.setMap(self)
	t.createRoom()

func _createRooms():
	var CreateRooms = CreateRooms_script.new()
	CreateRooms.setRooms($Rooms)
	CreateRooms.setMap(self)
	CreateRooms.generate()

func _ready():
	_BSP()

func get_prefabs():
	return prefabs
