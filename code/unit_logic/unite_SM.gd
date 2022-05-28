#Перед прочтеннием этого фрагмента, Рома, нужно прочитать state_machine.gd
extends state_machine

#Переменные для очереди пути
var comm_q_permit = false
var command_queue = []

#Логика комманд
enum commands_list {
	NONE,
	MOVE,
	ATTACK,
	HOLD,
	ABILITY
}
var command = commands_list.NONE

#Логика модификаторов комманд (нужно для реализации инпута)
enum command_mod_list {
	NONE,
	ATTACK,
	ABILITY
}
var command_mod = command_mod_list.NONE

#Добавляем стейты
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
		#Использование 1 абилки
		if Input.is_action_just_pressed("1_ability"):
			if command_mod != command_mod_list.ABILITY:
				command_mod = command_mod_list.ABILITY
				parent.ability_index = 0
			else:
				command_mod = command_mod_list.NONE
		#Использование 2 абилки
		#Тут кода меньше, потому что абилка юзается сразу
		
		#В целом всю логику надо перенести в отдельные файлы, но это уже позже
		if Input.is_action_just_pressed("2_ability"):
			parent.use_ability(1)
		#command queue, move attack и hold
		if Input.is_action_just_pressed("command_queue_key"):
			comm_q_permit = true
		if Input.is_action_just_released("command_queue_key"):
			comm_q_permit = false
		if Input.is_action_just_pressed("atack"):
			command_mod = command_mod_list.ATTACK
		if Input.is_action_just_pressed("hold"):
			command = commands_list.HOLD
		#тут пкм
		if Input.is_action_just_released("right_click") and event is InputEventMouseButton:
			#Получаем позицию мыши с учётом камеры
			var t_pos = event.position  + parent.contoller.camera.position - parent.contoller.get_viewport_rect().size / 2
			#Разная логика для shiftа и его остутвия
			if comm_q_permit:
				command_queue.push_back(t_pos)
			else:
				command_queue = [t_pos]
			parent.set_target(command_queue[0])
			#Определяем комманду от модификатора
			set_state(states.move)
			match command_mod:
				command_mod_list.NONE:
					command = commands_list.MOVE
				command_mod_list.ATTACK:
					command = commands_list.ATTACK
				command_mod_list.ABILITY:
					command = commands_list.ABILITY
			
			

#Функция для анимации поворота 
func change_dir():
	parent.animation_tree.set("parameters/idle/blend_position", parent.velocity.normalized())
	parent.animation_tree.set("parameters/run/blend_position", parent.velocity.normalized())
	parent.animation_tree.set("parameters/atack/blend_position", parent.velocity.normalized())

func _state_logic(delta):
	match state:
		states.move:
			#БЕГИМ
			parent.move_along_path(delta)
		states.engage:
			#Стоим в ингаге, пока цель существует
			if parent.attack_target.get_ref():
				parent.move_to_target(delta, parent.attack_target.get_ref().position)
			else:
				set_state(states.idle)
		states.attack:
			pass
		states.die:
			pass

func _enter_state(new_state, prev_state):
	match state:
		states.idle:
			print(1)
			parent.animation_tree_state.travel("idle")
			#Проверяем используется ли абилка прямо сейчас
			if command == commands_list.ABILITY:
				#И тогда её используем
				parent.use_ability(parent.ability_index)
				command_mod = command_mod_list.NONE
				command = commands_list.NONE
			#продолжаем движение, если есть цели для него
			if command_queue.size()>1:
				command_queue.remove(0)
				parent.set_target(command_queue[0])
				command = commands_list.MOVE
				set_state(states.move)
			else:
				command_queue = []
				parent.set_collision_layer_bit(1,true)
				parent.animation_tree_state.travel("idle")
		states.move:
			parent.animation_tree_state.travel("run")
			#Объясню один раз, а ты запомни
			#Во время движения челы хотят обходит стоящих юнитов
			#Поэтому мы ставим их на слой, который воспринимают наши лучи
			#Которые используются в мув виз обстикалс
			#Рома ты понял?
			parent.set_collision_layer_bit(1,false)
		states.engage:
			parent.animation_tree_state.travel("run")
			parent.set_target(parent.attack_target.get_ref().position)
			parent.set_collision_layer_bit(1,false)
		states.attack:
			parent.set_collision_layer_bit(1,true)
			parent.velocity = parent.position.direction_to(parent.attack_target.get_ref().position)
			change_dir()
			parent.animation_tree_state.travel("atack")
		states.die:
			parent.animation_tree_state.travel("die")

#Тут лень всё рассписывать
#кратко: меняем стейты, от условий достижения целей для определённых состояний
func _get_transition(delta):
	change_dir()
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
			match command:
				
				commands_list.MOVE:
					if parent.position.distance_to(parent.movment_target) < parent.target_max:
						parent.set_target(parent.position)
						command = commands_list.NONE
						set_state(states.idle)
						
				commands_list.ABILITY:
					if parent.position.distance_to(parent.movment_target) < parent.ability_range[parent.ability_index]:
						parent.set_target(parent.position)
						#command = commands_list.NONE
						set_state(states.idle)
				
				commands_list.ATTACK:
					if parent.closest_target() != null:
						parent.attack_target = weakref(parent.closest_target())
						set_state(states.engage)
					elif parent.position.distance_to(parent.movment_target) < parent.target_max:
						parent.set_target(parent.position)
						command = commands_list.NONE
						set_state(states.idle)
				commands_list.HOLD:
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
	
#Сдох
func died():
	set_state(states.die)

#Казалось бы логика атаки запихнута в анимацию, говнокод
#Однако нет - это самое элигантное, что можно сделать
#вед урон оружие должно нансоить после цикла атаки, что тут и происходит
func atack_logic():
	match state:
		states.attack:
			if parent.attack_target.get_ref():
				parent.velocity = ( parent.attack_target.get_ref().position - parent.position).normalized()
				change_dir()
				if parent.attack_target.get_ref().take_damage(parent.stats.damage):
					if not parent.target_within_range():
						set_state(states.engage)
						
				else:
					set_state(states.idle)
			else:
				set_state(states.idle)
				
		#Плюс фигня чтобы анимации красивши были
		states.die:
			parent.animation_tree_state.travel("die")
		states.engage:
			change_dir()

#Если не сдохли, то по истечению таймера останавливаемся
func _on_stop_timer_timeout():
	if state != states.die:
		set_state(states.idle)
		parent.set_target(parent.position)
		
func create_body():
	print(46)
	var body = parent.body.instance()
	body.position = parent.position
	parent.get_parent().add_child(body)
	parent.queue_free()
