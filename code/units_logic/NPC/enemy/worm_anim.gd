extends "res://code/units_logic/animation.gd"


var tmp 
func set_run(in_val):
	anim_tree.set("parameters/borrow/blend_position", in_val)
	anim_tree.set("parameters/unborrow/blend_position", in_val)
	tmp = in_val
	
func set_idle(in_val):
	anim_tree.set("parameters/borrow/blend_position", in_val)
	anim_tree.set("parameters/idle/blend_position", in_val)

func idle():
	anim_tree.set("parameters/unborrow/blend_position", tmp)
	anim_state_machine.travel("idle")
	
