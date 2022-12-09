extends Node2D

enum game_states {
	BATTLE,
	WANDERING,
	CUTSCENE,
}
enum battle_states {
	player_choice,
	player_point,
	enemy
}
enum events {
	none,
	move,
	attack
}
var current_state = game_states.BATTLE
var current_battle_state = battle_states.player_choice
var current_event = events.none

var path_finder: AstarPathfinder
var player_units: Array
var enemy_units: Array
var possible_tiles: TileMap
var current_play_unit_index = 0
var possible_cels: PoolVector2Array

onready var turn_label = get_node("../../../hand_substrate/turn/text")
onready var action_q_label = get_node("../../../hand_substrate/action_queue/text")
onready var ap = get_node("../../../AnimationPlayer")

export var lvl_type: String

var action_queue = []
var action_i = 0

var move_rad = 0

func start():
	path_finder = AstarPathfinder.new(get_node("objects/{}/astar_nav_mesh".format([lvl_type], "{}")))
	player_units = $objects/units/player.get_children()
	possible_tiles = get_node("objects/{}/possible_tiles".format([lvl_type], "{}"))
	
	for unit in player_units:
		unit.connect("movement_done", self, "move")
		
	


func _show_possible_tiles(radius):
	if radius>1:
		possible_cels = path_finder.get_points_in_radius(player_units[current_play_unit_index].position, radius)
		for point in possible_cels:
			possible_tiles.set_cellv(point, 0)

func _hide_possible_tiles():
	possible_tiles.clear()


func _unhandled_input(event):
	if event.is_action_pressed("ui_up"):
		#для тестов
		player_units[0].position = $objects/bunker_tile_set/floor.map_to_world($objects/bunker_tile_set/floor.get_used_cells()[0])+ Vector2(32,32)
		#
	
	if event.is_action_pressed("ui_home") and current_state == game_states.BATTLE:
		player_units[current_play_unit_index].set_path([player_units[current_play_unit_index].position])
		_show_possible_tiles(30)
	if event is InputEventMouseButton:
		match current_state:
			game_states.WANDERING:
				if event.button_mask == BUTTON_MASK_LEFT:
					var tmp = path_finder.get_move_path(player_units[current_play_unit_index].position,get_global_mouse_position())
					tmp.remove(0)
					player_units[current_play_unit_index].set_path(tmp)
			game_states.BATTLE:
				if event.button_mask == BUTTON_MASK_LEFT:
					match current_event:
						events.move:
							_hide_possible_tiles()
							var t = get_global_mouse_position()
							if path_finder.ground_tile_map.world_to_map(t) in possible_cels:
								var tmp = path_finder.get_move_path(player_units[current_play_unit_index].position,t)
								player_units[current_play_unit_index].set_path(tmp)
								if tmp.size()-1 < move_rad:
									move_rad -= (tmp.size()-1)
							else:
								move()
						events.attack:
							next_action()
		

func move(r = null):
	if r!=null:
		move_rad = r[0]+1
	if move_rad == 1 and current_battle_state == battle_states.player_point:
		next_action()
	_show_possible_tiles(move_rad)


func attack(in_vars):
	var rad = in_vars[0]
	var damage = in_vars[1]
	print(rad," " ,damage)

func start_action(in_q):
	if current_state == game_states.BATTLE:
		action_i = 0
		ap.play("show_queue")
		action_queue = in_q
		current_battle_state = battle_states.player_point
		call_action()

func next_action():
	ap.play("next_queue")
	action_i+=1
	call_action()

func call_action():
	if action_i < action_queue.size():
		action_q_label.text = action_queue[action_i][0]
		match action_queue[action_i][0]:
			"move":
				current_event = events.move
			"attack":
				current_event = events.attack
		call(action_queue[action_i][0], action_queue[action_i][1])
	else:
		current_event = events.none
		ap.play("hide_queue")
