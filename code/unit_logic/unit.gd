extends KinematicBody2D
class_name unit

#Константы
const BOMB = preload("res://scenes/units/bomb.tscn")

#Команда игрока для юнита
export var unit_owner := 0

#Переменные анимации
var cur_dir = 2
var directions = {0: "up", 2:"down", 1:"right", 3:"left"}
onready var animation_player = $AnimationPlayer

#Переменные для движения
var selected = false
var movment_target = Vector2.ZERO
var last_movment_target = Vector2.ZERO
var velocity = Vector2.ZERO
var target_max = 20

#Переменные для битвы
var attack_target = null
var possible_targets = []
var possible_targets_ignore_walls = []
#Общие статы
onready var stats = $stats
var ability_range = [50, 1]
var ability_index = 0

#Дети
onready var abilities_timer = $Abilities.get_children()
onready var state_machine = $Unite_SM
onready var collision_shape = $CollisionShape2D
onready var nav2d = get_node("../../Navigation2D")
onready var rays = $Rays
onready var rays_front = [$Rays/ray_front, $Rays/ray_front2, $Rays/ray_front3]
onready var attack_range_ray = $attack_range_ray
onready var contoller = get_node("../..")
onready var hud = get_node("../../Camera2D/hud")
onready var stop_timer = $stop_timer

#Материалы
var enemy_matirial = load("res://texture/shaders/invert.tres")

#навигация
var nav_path : PoolVector2Array
var leg_reset_treshold = 19
var movment_group = []







	
#Какой-то прикол годота
var coll = 0
#Почему-то при первом касте луча колижен не срабатывае, поэтому нужен данный костыль
func _process(delta):
	
	
	#Вызывваем апдейт анимаций кнопок скилов в худе, РОМА, ТЫ ПОНЯЛ?
	for i in abilities_timer.size():
		if abilities_timer[i].time_left != 0:
			hud.update_button(i, abilities_timer[i].time_left, abilities_timer[i].wait_time)
	#Проверяем столкновения со стенами относительно всех возможных противноиков
	#И добавляем их в доступных противников, если стен нету. РОМА, ТЫ ПОНЯЛ? 
	for tar in possible_targets_ignore_walls:
		if coll>=5:
			possible_targets.append(tar)
			possible_targets_ignore_walls.erase(tar)
			coll = 0
		if !no_wall_between_target(tar):
			coll += 1
			
			
			
func _ready():
	
	
	
	
	#attack_range_ray.cast_to = Vector2(attack_range,0)
	movment_target = position
	#пока скорее для тестов
	if unit_owner == 1:
		material = enemy_matirial
	


#---------Движение----------

#Основная функция движения
func move_to_target(delta, tar):
	velocity = Vector2.ZERO
	velocity = position.direction_to(tar) * stats.speed
	move_with_avoidance()

#Движение по пути построенному в виде точкек в массиве.
func move_along_path(delta):
	if nav_path.size() > 0:
		var distance_to_next_point = position.distance_to(nav_path[0])
		if distance_to_next_point < leg_reset_treshold:
			nav_path.remove(0)
			if nav_path.size() != 0:
				velocity = position.direction_to(nav_path[0]) * stats.speed
				move_with_avoidance()
		else:
			velocity = position.direction_to(nav_path[0]) * stats.speed
			move_with_avoidance()
		colliders_reaching_targets()
#Корректирование траектории, если встречаем стены
func move_with_avoidance():
	rays.rotation_degrees = velocity.angle() * 180/PI
	if _obsticle_ahed():
		var viable_ray = _get_viable_ray()
		if viable_ray:
			velocity = Vector2.RIGHT.rotated((rays.rotation_degrees  +  viable_ray.rotation_degrees) * PI/180 ) * stats.speed
	move_and_slide(velocity)
	
#Функция, похволяющая юнитам собиратся максимально возможно в одной точке
func colliders_reaching_targets():
	if stop_timer.is_stopped():
		for i in get_slide_count():
			var collider = get_slide_collision(i).collider
			for unit in movment_group:
				if unit.get_ref() and unit.get_ref() == collider:
					if collider.reached_target():
						stop_timer.start()
#Шиз, тебе здесь нужны комментарии?
func reached_target() -> bool:
	return movment_target == position
#Тут тоже всё очевидно, просто функция для сравнивания углов векторов
func _compare_angle(ray_a, ray_b):
	if abs(ray_a.rotation_degrees) > abs(ray_b.rotation_degrees):
		return true
	return false
#А чтоже делает эта функция???????
func get_owner_id():
	return unit_owner

#Проверяем если препятствия впереди 
func _obsticle_ahed() -> bool:
	for ray in rays_front:
		if ray.is_colliding():
			return true
	return false
#Ищем луч, который не сталкивается со стенами, чтобы пойти туда
func _get_viable_ray() -> RayCast2D:
	var possible_rays = []
	for ray in rays.get_children():
		if !ray.is_colliding():
			return ray
	return null
#Банально чекаем есть ли между нами и целью стена
func no_wall_between_target(tar) -> bool:
	attack_range_ray.cast_to = position.direction_to(tar.position) * position.distance_to(tar.position)
	return attack_range_ray.is_colliding()

#Функция обновления цели
func set_target(target):
	stop_timer.stop()
	movment_group = contoller.get_movment_group()
	nav_path = nav2d.get_simple_path(self.global_position, target, true)
	nav_path.remove(0)
	last_movment_target = movment_target
	movment_target = target
#А это, что делает? Без понятия...
func recalculate_path():
	nav_path = nav2d.get_simple_path(self.global_position, movment_target, true)

#Меняем статус "выбраности" юнита
func selected():
	#Обнуляем текстурки таймеров абилок
	update_stats()
	for i in abilities_timer.size():
		hud.update_button(i, abilities_timer[i].time_left, abilities_timer[i].wait_time)
	selected = true
	$Selected.visible = true
#Меняем статус "выбраности" юнита
func unselected():
	Unit_global.remove_unit(stats.unit_name)
	selected = false
	$Selected.visible = false

#Добавляем тело, если оно в поле зрения, в доступные цели, игнорируя стены
func _on_Vision_range_body_entered(body):
	if body.is_in_group("unit"):
		if body.unit_owner != unit_owner:
			possible_targets_ignore_walls.append(body)

#Убираем тело, если оно вышло из поля зрения, из доступных целей, в принципе
func _on_Vision_range_body_exited(body):
	if possible_targets.has(body):
		possible_targets.erase(body)
		coll = 0
	if possible_targets_ignore_walls.has(body):
		possible_targets_ignore_walls.erase(body)

#Функция сравнения расстояний между точками (нужна для сортировки)
func _compare_distance(target_a, target_b):
	if position.distance_to(target_a.position) < position.distance_to(target_b.position):
		return true
	return false
	
#Получаем ближайщую цель
func closest_target() -> unit:
	if possible_targets.size() > 0:
		possible_targets.sort_custom(self, "_compare_distance")
		return possible_targets[0]
	return null
#Проверяем есть ли она в дистанции атаки
func closest_target_within_range() -> unit:
	if closest_target() != null:
		if closest_target().position.distance_to(position) < stats.attack_range:
			return closest_target()
	return null
#Получем эту цель
func target_within_range() -> bool:
	if attack_target != null:
		if attack_target.get_ref().position.distance_to(position) < stats.attack_range:
			return true
	return false
#Рома, ты понял, что прошлые 3 коммента связаны???

#Функция получения урона и проверки дохлости юнита
func take_damage(amount) -> bool:
	update_stats()
	stats.health -= amount
	if stats.health <= 0:
		state_machine.died()
		collision_shape.disabled = true
		return false
	return true
	
func update_stats():
	Unit_global.add_unit(stats.unit_name, {
		"health": stats.health,
		"damage": stats.damage,
		"mana": stats.mana
	})


																									
 #РОМА, СМОТРИ ЭТО ЖЕ ФУНКЦИЯ АБИЛОК!!!!!!!!                                                                                                   
																									
																									
#                                            (@@@@*   ((@@@@(,                                       
#                                       (@@&.                  (@@%                                  
#                                  %@@@                             @@                               
#                                @@                                  @@                              
#                              @*                  *@@@@/     *@%    (@                             
#                             *@&        .@@@&&     *@@@&              @(                            
#                            %@   *@@@%%.,&@@@@@%,,,@@@@@%             @@                            
#                            @   @@@@&#***@@@@@#                        @                            
#                           *@     ((                 ,@@(((((   .@     @                            
#                           *@                                          @#                           
#                            @       &@@@@@@@@        .@                /@                           
#                            &%   @(      &%  (      % #&@@@ @.          @                           
#                             @,     /@@@@@@* (   *.  @@@@@@             @#                          
#                             @@     @@@@@@ @%(.   @                     @#                          
#                              @               @   @.                    @#                          
#       @@@.                   %@              @     @,                  @#                          
#       @#  (@@@@@@(.           @*            (@      @*                 @#                          
#         *@#        /@@@@@#/   /@           ./       .@                ,@#                          
#          @,                 ,@@@            .,@@.                    @@ @%                         
#         @@                      @@              *. @,&            @ (@@  .@@@*                     
#        #@  /@@                   (@       #&  /  @  % @ @        &@ @@ @      @@@@@                
#                @@&                 /@   .@  (@@@@@@@@@@/   @.  @@%#@@                              
#                   @@(                @.@  , @@@@@@@@@@@@   *@ @ %@@ %                              
#                     *@@              %@**@   @@@@@@@@@(@       %@&&@                               
#                        @@(            &@@@.   @      &&       /@#@                                 
#                           @@#           @(@@     ***         @@                                    
#                              @@            @@@*@           @@ %                                    
#                               ,@@           (  @/@@@@@@@@@. .                                      
#                                  @@(            *@ @  @   @                                        
#                                    /@#                                                             
#                                      @@.                                                           
#                                       &%                                                           
#                                       &%                                                           
#                                        @                                                           
#                                        @@                                                          
#                                         @%                                                         
#                                          @                                                         
#                                          @*                                                        
#                                          ,@                                                        
#                                           /@                                                       
#                                            @                                                       
#                                            @/                                                      
#                                            *@                                                      
#                                            .@                                                      
#                                            .@                                                      
#                                             @                                                      
#                                              @(                                                    
#                                              @(                                                    


func use_ability(index):
	ability_index = index
	match index:
		0:
			#Логика бомбы
			if abilities_timer[index].is_stopped():
				var bomb = BOMB.instance()
				bomb.position = last_movment_target
				get_tree().current_scene.add_child(bomb)
				abilities_timer[index].start()
				
		1:
			#Логика хилки
			if abilities_timer[index].is_stopped():
				stats.health += 10
				if stats.health > stats.max_health:
					stats.health = stats.max_health
				abilities_timer[index].start()
				
