extends KinematicBody2D
class_name Unit

signal movement_done
signal clicked(KinematicBody2D)

const SPEED := 80.0

export var move_points := 4
export var cell_size = 16
export var unit_name = ""
export var tile_set_type: String

onready var ruler = $ruler
onready var stats = $stats
onready var wals_tilemap = get_node("/root/main/ViewportContainer/Viewport/level/objects/{}/wals".format([tile_set_type], "{}"))
onready var fow_tilemap = get_node("/root/main/ViewportContainer/Viewport/level/objects/{}/fogOfWar".format([tile_set_type], "{}"))
onready var health_bar = $health_bar

var path := PoolVector2Array([])
var selected = false

func _ready():
	health_bar.max_value = stats.health
	health_bar.value = stats.health

func _physics_process(delta: float):
	if not path.empty():
		_move_along_path(delta)
		if path.empty():
			emit_signal("movement_done")


func set_path(_path: PoolVector2Array):
	path = _path


func _move_along_path(delta: float):
	var distance = SPEED * delta
	var space_state = get_world_2d().direct_space_state
	for i in range(path.size()):
		var next_point = path[0]
		var dist_to_next_point = position.distance_to(next_point)
		if distance <= dist_to_next_point and distance >= 0.0:
			move_and_slide(position.direction_to(next_point).normalized() * SPEED)
			break
		distance -= dist_to_next_point
		move_and_slide(position.direction_to(next_point).normalized() * SPEED)
		path.remove(0)
	var unit_tile_position = position/fow_tilemap.cell_size.x
	for x in range(unit_tile_position.x-10, unit_tile_position.x+11):
		for y in range(unit_tile_position.y-10, unit_tile_position.y+11):
			if fow_tilemap.get_cell(x,y)==0:
				var tile_position = wals_tilemap.world_to_map(position)
				var x_dir = 1 if  x < tile_position.x else -1
				var y_dir = 1 if  y < tile_position.y else -1
				var test_point1 = fow_tilemap.map_to_world(Vector2(x,y))
				var occlusion1 = space_state.intersect_ray(position, test_point1)
				if !occlusion1 ||  (occlusion1.position - test_point1).length() < 25 :
					fow_tilemap.set_cell(x,y,-1) 

func select():
	$selected.visible = true
	selected = true

func unselect():
	$selected.visible = false
	selected = false

func in_danger():
	#Если найдём способ рнешить проблему с area2d, то надо убпрать
	$click_area.mouse_filter = Control.MOUSE_FILTER_STOP
	#Жопа
	$target_ico.visible = true

func no_longer_in_danger():
	#Если найдём способ рнешить проблему с area2d, то надо убпрать
	$click_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	#Жопа
	$target_ico.visible = false

func check_the_wals(target, radius):
	radius = (radius+1)*cell_size-1
	var tmp = target -  position  
	print(tmp.length())
	if tmp.length() > radius:
		return false
	ruler.cast_to.x = tmp.x
	ruler.cast_to.y = tmp.y
	return not ruler.is_colliding()

func take_damage(amount): 
	stats.health -= amount
	health_bar.value = stats.health

func _on_click_area_pressed():
	emit_signal("clicked", self)
