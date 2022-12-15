extends Node

var anim_state_machine
var anim_tree 


func start():
	anim_tree = get_child(0)
	anim_state_machine = anim_tree.get("parameters/playback")
	
func set_run(in_val):
	anim_tree.set("parameters/run/blend_position", in_val)
func run():
	anim_state_machine.travel("run")

func set_idle(in_val):
	anim_tree.set("parameters/idle/blend_position", in_val)
func idle():
	anim_state_machine.travel("idle")
