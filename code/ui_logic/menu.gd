extends Node

func _ready():
	$AnimationPlayer.play("main")


func _on_exit_pressed():
	get_tree().quit()


func _on_cave_pressed():
	get_tree().change_scene("res://scenes/UI/lvls/main_cave.tscn")


func _on_bunker_pressed():
	get_tree().change_scene("res://scenes/UI/lvls/main_bunker.tscn")
