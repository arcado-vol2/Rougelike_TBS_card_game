extends KinematicBody2D
class_name unit

#Команда игрока для юнита
export var unit_owner := 0

#Переменные анимации
var cur_dir = 2
var directions = {0: "up", 2:"down", 1:"right", 3:"left"}
onready var animation_player = $AnimationPlayer

#Переменные для движения
var selected = false
var movment_target = Vector2.ZERO
var velocity = Vector2.ZERO
var speed = 70
var target_max = 20

#Переменные для битвы
var attack_target = null
var possible_targets = []

#Общие статы
export var health = 20
var damage = 3
export var attack_range = 25

#Дети
onready var state_machine = $Unite_SM
onready var collision_shape = $CollisionShape2D
onready var nav2d = get_node("../../Navigation2D")
onready var rays = $Rays
onready var ray_front = $Rays/ray_front
onready var ray_front2 = $Rays/ray_front2
onready var contoller = get_node("../..")
onready var stop_timer = $stop_timer

#Материалы
var enemy_matirial = load("res://texture/shaders/invert.tres")

#навигация
var nav_path : PoolVector2Array
var leg_reset_treshold = 19
var movment_group = []

func _ready():
	movment_target = position
	#пока скорее для тестов
	if unit_owner == 1:
		material = enemy_matirial
	


#Движение
func move_to_target(delta, tar):
	velocity = Vector2.ZERO
	velocity = position.direction_to(tar) * speed
	move_with_avoidance()

func move_along_path(delta):
	if nav_path.size() > 0:
		var distance_to_next_point = position.distance_to(nav_path[0])
		if distance_to_next_point < leg_reset_treshold:
			nav_path.remove(0)
			if nav_path.size() != 0:
				velocity = position.direction_to(nav_path[0]) * speed
				move_with_avoidance()
		else:
			velocity = position.direction_to(nav_path[0]) * speed
			move_with_avoidance()
		colliders_reaching_targets()

func move_with_avoidance():
	rays.rotation_degrees = velocity.angle() * 180/PI
	if _obsticle_ahed():
		var viable_ray = _get_viable_ray()
		if viable_ray:
			velocity = Vector2.RIGHT.rotated((rays.rotation_degrees  +  viable_ray.rotation_degrees) * PI/180 ) * speed
	move_and_slide(velocity)
	

func colliders_reaching_targets():
	if stop_timer.is_stopped():
		for i in get_slide_count():
			var collider = get_slide_collision(i).collider
			for unit in movment_group:
				if unit.get_ref() and unit.get_ref() == collider:
					if collider.reached_target():
						stop_timer.start()

func reached_target() -> bool:
	return movment_target == position

func _compare_angle(ray_a, ray_b):
	if abs(ray_a.rotation_degrees) > abs(ray_b.rotation_degrees):
		return true
	return false

func get_owner_id():
	return unit_owner


func _obsticle_ahed() -> bool:
	if ray_front.is_colliding():
		if ray_front.get_collider().is_in_group("unit"):
			if ray_front.get_collider().get_owner_id() != unit_owner:
				return false
	return ray_front.is_colliding() or ray_front2.is_colliding()

func _get_viable_ray() -> RayCast2D:
	for ray in rays.get_children():
		if !ray.is_colliding():
			return ray
	return null

func set_target(target):
	stop_timer.stop()
	movment_group = contoller.get_movment_group()
	nav_path = nav2d.get_simple_path(self.global_position, target, true)
	movment_target = target
	
func recalculate_path():
	nav_path = nav2d.get_simple_path(self.global_position, movment_target, true)

func selected():
	selected = true
	$Selected.visible = true

func unselected():
	selected = false
	$Selected.visible = false


func _on_Vision_range_body_entered(body):
	if body.is_in_group("unit"):
		if body.unit_owner != unit_owner:
			possible_targets.append(body)


func _on_Vision_range_body_exited(body):
	if possible_targets.has(body):
		possible_targets.erase(body)


func _compare_distance(target_a, target_b):
	if position.distance_to(target_a.position) < position.distance_to(target_b.position):
		return true
	return false
	

	

func closest_target() -> unit:
	if possible_targets.size() > 0:
		possible_targets.sort_custom(self, "_compare_distance")
		return possible_targets[0]
	return null

func closest_target_within_range() -> unit:
	if closest_target() != null:
		if closest_target().position.distance_to(position) < attack_range:
			return closest_target()
	return null
	
func target_within_range() -> bool:
	if attack_target != null:
		if attack_target.get_ref().position.distance_to(position) < attack_range:
			return true
	return false
	
func take_damage(amount) -> bool:
	health -= amount
	if health <= 0:
		state_machine.died()
		collision_shape.disabled = true
		return false
	return true
	

