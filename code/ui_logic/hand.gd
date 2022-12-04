extends Control


var focused_i: int = -1
export var dead_zone = -200
func focus(i):
	focused_i = i
	get_parent().rerange_hand()

func unfocus():
	focused_i = -1
	get_parent().rerange_hand()

