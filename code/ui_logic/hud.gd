extends Control

onready var label = $Container/Label
onready var button_container = $Container/Button_container

func update_label(text):
	label.text = str(text)

func update_button(index, val, max_val):
	button_container.get_child(index).value = val * (100 / max_val)
