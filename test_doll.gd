extends KinematicBody2D

var velocity: Vector2 = Vector2.ZERO
export var speed: int = 10000
func _input(event):
	if event.get_action_strength("ui_left"):
		velocity.x = -1
	elif event.get_action_strength("ui_right"):
		velocity.x = 1
	elif event.get_action_strength("ui_up"):
		velocity.y = -1
	elif event.get_action_strength("ui_down"):
		velocity.y = 1
	else:
		velocity = Vector2.ZERO

func _physics_process(delta):
	move_and_slide(velocity * speed * delta)
