extends Node2D

const EXPLOSION = preload("res://science/effects/explosion_effect.tscn")
var possible_targets = []
export var damage = 10
func _ready():
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play()

func _on_Area2D_body_entered(body):
	if body.is_in_group("unit"):
		possible_targets.append(body)
		

func _on_Area2D_body_exited(body):
	if possible_targets.has(body):
		possible_targets.erase(body)

func _on_AnimatedSprite_animation_finished():
	var explosion = EXPLOSION.instance()
	explosion.position = position
	get_tree().current_scene.add_child(explosion)
	for body in possible_targets:
		print(body)
		body.take_damage(damage)
	queue_free()
	
