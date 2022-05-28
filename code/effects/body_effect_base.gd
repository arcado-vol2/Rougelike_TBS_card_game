extends Sprite

export var velocity = Vector2.ZERO


func _ready():
	$AnimationTree.set("parameters/blend_position", velocity)
func _on_Timer_timeout():
	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	$Timer.start()

func _on_VisibilityNotifier2D_screen_entered():
	$Timer.stop()
