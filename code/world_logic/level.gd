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
var current_state = game_states.WANDERING
var current_battle_state = battle_states.player_choice
var current_event = events.none

var path_finder: AstarPathfinder
var player_units: Array
var enemy_units: Array
var possible_tiles: TileMap
var current_play_unit_index = 0
var possible_cels: PoolVector2Array

onready var turn_label = get_node("../../../hand_substrate/turn/text")
onready var action_q_label = get_node("../../../action_queue/text")
onready var action_q_ap = get_node("../../../action_queue/AnimationPlayer")
onready var parent = get_node("../../..")
export var lvl_type: String

var action_queue = []
var action_i = 0

var rad = 0
var damage = 0
func start():
	path_finder = AstarPathfinder.new(get_node("objects/{}/astar_nav_mesh".format([lvl_type], "{}")))
	player_units = $objects/units/player.get_children()
	possible_tiles = get_node("objects/{}/possible_tiles".format([lvl_type], "{}"))
	enemy_units = $objects/units/enemy.get_children()
	for unit in player_units:
		unit.connect("movement_done", self, "move")
		unit.unselect()
	player_units[0].select()
	parent.current_hand = player_units[0].get_child(0).get_hand()
	parent.current_deck = player_units[0].get_child(0).get_deck()
	for unit in enemy_units:
		unit.connect("clicked", self, "applay_damage")

func _show_possible_tiles(radius):
	if radius>1:
		possible_cels = path_finder.get_points_in_radius(player_units[current_play_unit_index].position, radius)
		for point in possible_cels:
			possible_tiles.set_cellv(point, 0)

func _show_possible_tiles_4_attack(radius):
	if radius>1:
		possible_cels = path_finder.get_points_in_radius(player_units[current_play_unit_index].position, radius, true)
		for point in possible_cels:
			possible_tiles.set_cellv(point, 1)
			
func _hide_possible_tiles():
	possible_tiles.clear()

func _unhandled_input(event):
	if event.is_action_pressed("ui_up"):
		#для тестов
		player_units[0].position = $objects/bunker_tile_set/floor.map_to_world($objects/bunker_tile_set/floor.get_used_cells()[0])+ Vector2(24,24)
		player_units[1].position = $objects/bunker_tile_set/floor.map_to_world($objects/bunker_tile_set/floor.get_used_cells()[0])+ Vector2(48,24)
		enemy_units[0].position = player_units[0].position + Vector2(48,48)
		enemy_units[1].position = player_units[0].position + Vector2(48,48)

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
							var t = make_input_local(event).position
							if path_finder.ground_tile_map.world_to_map(t) in possible_cels:
								var tmp = path_finder.get_move_path(player_units[current_play_unit_index].position,t)
								player_units[current_play_unit_index].set_path(tmp)
								if tmp.size()-1 < rad:
									rad -= (tmp.size()-1)
							else:
								move()

func move(r = null):
	if r!=null:
		rad = r[0]+1
	if rad == 1 and current_battle_state == battle_states.player_point:
		next_action()
		return
	_show_possible_tiles(rad)

func attack(in_vars):
	rad = in_vars[0]
	damage = in_vars[1]
	_show_possible_tiles_4_attack(rad)
	if possible_targets(rad, true) == 0:
		next_action()
		return

func applay_damage(unit):
	unit.take_damage(damage)
	possible_targets(rad, false)
	next_action()

func closer(a, b):
	if a.position.distance_to(player_units[current_play_unit_index].position) < b.position.distance_to(player_units[current_play_unit_index].position):
		return true
	return false

func possible_targets(rad, show):
	if enemy_units.size()==0:
		return 0
	enemy_units.sort_custom(self, "closer")
	var curr_rad = rad *16
	var amount = 0
	for u in enemy_units:
		if u.position.distance_to(player_units[current_play_unit_index].position) > curr_rad:
			break
		if show:
			u.in_danger()
			amount +=1
		else:
			u.no_longer_in_danger()
	return amount

func start_action(in_q):
	if current_state == game_states.BATTLE:
		action_i = 0
		action_q_ap.play("show_queue")
		action_queue = in_q
		current_battle_state = battle_states.player_point
		parent.hide_a_hand()
		call_action()

func next_action():
	_hide_possible_tiles()
	action_q_ap.play("next_queue")
	action_i+=1
	call_action()

func call_action():
	if action_i < action_queue.size():
		rad = 0 
		damage = 0
		action_q_label.text = action_queue[action_i][0]
		match action_queue[action_i][0]:
			"move":
				current_event = events.move
			"attack":
				current_event = events.attack
		call(action_queue[action_i][0], action_queue[action_i][1])
	else:
		current_event = events.none
		action_q_ap.play("hide_queue")
		parent.show_a_hand()


func _on_skip_pressed():
	next_action()


func _on_end_turn_pressed():
	player_units[current_play_unit_index].unselect()
	player_units[current_play_unit_index].get_child(0).save_hand(parent.current_hand)
	player_units[current_play_unit_index].get_child(0).save_deck(parent.current_deck)
	current_play_unit_index = (current_play_unit_index + 1) % player_units.size()
	player_units[current_play_unit_index].select()
	parent.current_hand = player_units[current_play_unit_index].get_child(0).get_hand()
	parent.current_deck = player_units[current_play_unit_index].get_child(0).get_deck()

