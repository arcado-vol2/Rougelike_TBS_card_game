extends KinematicBody2D
class_name Unit

signal movement_done
signal clicked(KinematicBody2D)

const SPEED := 80.0

export var move_points := 4
export var cell_size = 16
export var unit_name = ""

onready var ruler = $ruler
onready var stats = $stats
onready var health_bar = $health_bar

var path := PoolVector2Array([])
var selected = false

var anim_state_machine

func _ready():
	health_bar.max_value = stats.health
	health_bar.value = stats.health
	anim_state_machine = $AnimationTree.get("parameters/playback")
	anim_state_machine.travel("idle")

func _physics_process(delta: float):
	if not path.empty():
		_move_along_path(delta)
		if path.empty():
			anim_state_machine.travel("idle")
			emit_signal("movement_done")


func set_path(_path: PoolVector2Array):
	anim_state_machine.travel("run")
	path = _path


func _move_along_path(delta: float):
	print("method")
	var distance = SPEED * delta
	for i in range(path.size()):
		
		var next_point = path[0]
		print(position.direction_to(next_point).normalized()*Vector2(-1,1))
		$AnimationTree.set("parameters/idle/blend_position", position.direction_to(next_point).normalized()*Vector2(1,-1))
		$AnimationTree.set("parameters/run/blend_position", position.direction_to(next_point).normalized()*Vector2(1,-1))
		var dist_to_next_point = position.distance_to(next_point)
		if distance <= dist_to_next_point and distance >= 0.0:
			move_and_slide(position.direction_to(next_point).normalized() * SPEED)
			break
		distance -= dist_to_next_point
		move_and_slide(position.direction_to(next_point).normalized() * SPEED)
		
		path.remove(0)
		
		
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
