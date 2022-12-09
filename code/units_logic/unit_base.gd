extends KinematicBody2D
class_name Unit

signal movement_done

const SPEED := 80.0

export var move_points := 4

var path := PoolVector2Array([])
var selected = false

func _physics_process(delta: float):
	if not path.empty():
		_move_along_path(delta)
		if path.empty():
			emit_signal("movement_done")


func set_path(_path: PoolVector2Array):
	path = _path


func _move_along_path(delta: float):
	var distance = SPEED * delta
	for i in range(path.size()):
		var next_point = path[0]
		var dist_to_next_point = position.distance_to(next_point)
		if distance <= dist_to_next_point and distance >= 0.0:
			move_and_slide(position.direction_to(next_point).normalized() * SPEED)
			break
		distance -= dist_to_next_point
		move_and_slide(position.direction_to(next_point).normalized() * SPEED)
		path.remove(0)
		
func select():
	selected = true

func unselect():
	selected = false
