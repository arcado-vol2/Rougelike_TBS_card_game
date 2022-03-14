extends AnimatedSprite

func _ready():
	play()
	frame = 0

func _on_effect_animation_finished():
	queue_free()
