extends Node2D

enum game_states {
	BATTLE,
	WANDERING,
	CUTSCENE,
}
var current_state = game_states.BATTLE

var path_finder: AstarPathfinder
var player_units: Array
var enemy_units: Array
var possible_tiles: TileMap
var current_play_unit_index = 0
var possible_cels: PoolVector2Array

export var lvl_type: String


func start():
	path_finder = AstarPathfinder.new(get_node("objects/{}/astar_nav_mesh".format([lvl_type], "{}")))
	player_units = $objects/units/player.get_children()
	possible_tiles = get_node("objects/{}/possible_tiles".format([lvl_type], "{}"))
	
func _show_possible_tiles(radius):
	possible_cels = path_finder.get_points_in_radius(player_units[current_play_unit_index].position, radius)
	for point in possible_cels:
		possible_tiles.set_cellv(point, 0)

func _hide_possible_tiles():
	possible_tiles.clear()


func _unhandled_input(event):
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
					_hide_possible_tiles()
					var t = get_global_mouse_position()
					if path_finder.ground_tile_map.world_to_map(t) in possible_cels:
						var tmp = path_finder.get_move_path(player_units[current_play_unit_index].position,t)
						player_units[current_play_unit_index].set_path(tmp)
	

