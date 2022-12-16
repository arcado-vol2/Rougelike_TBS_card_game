extends YSort
var prefabs
var path
var BSP_script= load("res://code/world_logic/BSP_script.gd")
var Cellular_script = load("res://code/world_logic/BSP_+_cellular.gd")
var BuildingPath_script = load("res://code/world_logic/Building_Path.gd")
var CurvedLine_script = load("res://code/world_logic/curved_line.gd")
var rng = RandomNumberGenerator.new()
var startRoom
var rooms_array

onready var CreateRooms = $create_rooms
onready var floor_tilemap = $floor
onready var wals_tilemap = $wals
onready var fow_tilemap = $fogOfWar
onready var astar_navigation_tilemap = $astar_nav_mesh
onready var rooms_node = $floor/rooms
signal loading_complete
func _createRooms():
	CreateRooms.setRooms(rooms_node)
	CreateRooms.setMap(floor_tilemap, astar_navigation_tilemap)
	CreateRooms.generate()
	yield(CreateRooms, "generation_complete")
	for y in 300:
		for x in 300:
			fow_tilemap.set_cell(x-150,y-150,1)
			if floor_tilemap.get_cell(x-150, y-150) == 0:
				astar_navigation_tilemap.set_cell(x-150,y-150,0)
				fow_tilemap.set_cell(x-150,y-150,0)
			if (floor_tilemap.get_cell(x-150,y-150)==-1):
				wals_tilemap.set_cell(x-150,y-2-150,0)
	wals_tilemap.update_bitmask_region()
	floor_tilemap.update_bitmask_region()

func placeStart():
	rooms_array = rooms_node.get_children()
	startRoom = rooms_array[rng.randi_range(0,rooms_array.size())]
	yield(get_tree().create_timer(2), "timeout")
	var player= get_parent().get_parent().get_current_unit()
	var calculated_position= floor_tilemap.map_to_world(startRoom.mapPosition)
	calculated_position.x+=8
	calculated_position.y+=8
	player.position = calculated_position
	for x in range (-4,5):
		for y in range (-4,5):
			fow_tilemap.set_cell(startRoom.mapPosition.x+x,startRoom.mapPosition.y+y, -1)

func _ready():
	_createRooms()
func get_prefabs():
	return prefabs


func _on_create_rooms_generation_complete():
	placeStart()
	get_parent().get_parent().start()
	emit_signal("loading_complete")
