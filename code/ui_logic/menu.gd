extends Node



func _on_play_button_pressed():
	get_tree().change_scene("res://science/main.tscn")

func _on_exit_button_pressed():
	get_tree().quit()
