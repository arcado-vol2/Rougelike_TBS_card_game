extends state_machine

var comm_q_permit = false
var command_queue = []

enum commands_list {
	NONE,
	MOVE,
	ATTACK,
	HOLD
}
var command = commands_list.NONE


enum command_mod_list {
	NONE,
	ATTACK
}
var command_mod = command_mod_list.NONE

func _ready():
	add_state("idle")
	add_state("move")
	add_state("stay")
	add_state("engage")
	add_state("attack")
	add_state("die")
	call_deferred("set_state", states.idle)
	

func _input(event):
	if parent.selected and state != states.die:
		if Input.is_action_just_pressed("command_queue_key"):
			comm_q_permit = true
		if Input.is_action_just_released("command_queue_key"):
			comm_q_permit = false
			
		if Input.is_action_just_pressed("atack"):
			command_mod = command_mod_list.ATTACK
		if Input.is_action_just_pressed("hold"):
			command = commands_list.HOLD
		if Input.is_action_just_released("right_click") and event is InputEventMouseButton:
			var t_pos = event.position  + parent.contoller.camera.position - parent.contoller.get_viewport_rect().size / 2
			if comm_q_permit:
				command_queue.push_back(t_pos)
			else:
				command_queue = [t_pos]
			parent.set_target(command_queue[0])
			
			
			set_state(states.move)
			match command_mod:
				command_mod_list.NONE:
					command = commands_list.MOVE
				command_mod_list.ATTACK:
					command = commands_list.ATTACK
			
			

func change_dir():

	if parent.velocity.angle() < -0.75 and parent.velocity.angle() > -2.25:
		parent.cur_dir = 0
	elif parent.velocity.angle() > -0.75 and parent.velocity.angle() < 0.75:
		parent.cur_dir = 1
	elif parent.velocity.angle() > 0.75 and parent.velocity.angle() < 2.25:
		parent.cur_dir = 2
	else:
		parent.cur_dir = 3

func _state_logic(delta):
	match state:
		states.idle:
			pass
		states.move:
			change_dir()
			parent.animation_player.play("run_"+parent.directions[parent.cur_dir])
			parent.move_along_path(delta)
		states.engage:
			change_dir()
			parent.animation_player.play("run_"+parent.directions[parent.cur_dir])
			if parent.attack_target.get_ref():
				parent.move_to_target(delta, parent.attack_target.get_ref().position)
			else:
				set_state(states.idle)
		states.attack:
			change_dir()
		states.die:
			pass

func _enter_state(new_state, prev_state):
	match state:
		states.idle:
			if command_queue.size()>1:
				command_queue.remove(0)
				parent.set_target(command_queue[0])
				command = commands_list.MOVE
				set_state(states.move)
			else:

				command_queue = []
				parent.set_collision_layer_bit(1,true)
				parent.animation_player.play("idle_"+parent.directions[parent.cur_dir])
		states.move:
			parent.set_collision_layer_bit(1,false)
		states.engage:
			parent.set_target(parent.attack_target.get_ref().position)
			parent.set_collision_layer_bit(1,false)
		states.attack:
			parent.set_collision_layer_bit(1,true)
			parent.velocity = parent.position.direction_to(parent.attack_target.get_ref().position)
			change_dir()
			parent.animation_player.play("atack_"+parent.directions[parent.cur_dir])
		states.die:
			parent.animation_player.play("die_"+parent.directions[parent.cur_dir])
	
	
func _get_transition(delta):
	match state:
		states.idle:
			match command:
				commands_list.HOLD:
					if parent.closest_target_within_range() != null:
						parent.attack_target = weakref(parent.closest_target_within_range())
						set_state(states.attack)
				commands_list.ATTACK:
					parent.movment_target = parent.last_movment_target
					parent.recalculate_path()
					set_state(states.move)
				commands_list.NONE:
					if parent.closest_target() != null:
						parent.attack_target = weakref(parent.closest_target())
						set_state(states.engage)
		states.move:
			#if parent.position.distance_to(parent.movment_target) < parent.target_max:
				#set_state(states.idle)
			
			
			if command == commands_list.MOVE:
				if parent.position.distance_to(parent.movment_target) < parent.target_max:
					parent.movment_target = parent.position
					command = commands_list.NONE
					set_state(states.idle)
					
			if command == commands_list.ATTACK:
				if parent.closest_target() != null:
					parent.attack_target = weakref(parent.closest_target())
					set_state(states.engage)
				elif parent.position.distance_to(parent.movment_target) < parent.target_max:
					parent.movment_target = parent.position
					command = commands_list.NONE
					set_state(states.idle)
					
				
		states.engage:
			if parent.closest_target_within_range() != null:
				parent.attack_target = weakref(parent.closest_target())
				set_state(states.attack)
		states.attack:
			if !parent.attack_target.get_ref():
				set_state(states.idle)
				parent.attack_target = null
		states.die:
			pass
	

func died():
	set_state(states.die)

func _on_AnimationPlayer_animation_finished(anim_name):
	match state:
		states.attack:
			if parent.attack_target.get_ref():
				if parent.attack_target.get_ref().take_damage(parent.damage):
					if parent.target_within_range():
						pass
					else:
						set_state(states.engage)
						
				else:
					set_state(states.idle)
			else:
				set_state(states.idle)
				
			parent.animation_player.play("atack_"+parent.directions[parent.cur_dir])
		states.die:
			parent.queue_free()
		states.idle:
			parent.animation_player.play("idle_"+parent.directions[parent.cur_dir])
		states.engage:
			change_dir()
			parent.animation_player.play("run_"+parent.directions[parent.cur_dir])
			
		


func _on_stop_timer_timeout():
	if state != states.die:
		set_state(states.idle)
		parent.movment_target = parent.position
