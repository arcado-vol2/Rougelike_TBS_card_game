extends Node

#Надо рассписать термины 
#turn - ход одного юнита
#stage - тип ходов - игрока или компа
#phase - фаза игры - исследование или битва
var rng = RandomNumberGenerator.new()

onready var level = get_parent().get_child(0)
onready var player_units = level.get_node("objects/units/player")
onready var enemy_units = level.get_node("objects/units/enemy")
onready var hand_controller = get_node("../../..")

enum {
	player_stage,
	enemy_stage,
}
enum {
	wandering,
	battle,
}
var stage = null
var current_player_unit = null
var current_enemys= null

var phase = null
var initiative_deck = []

var enemys = []
var enemys_types = []
var players = []

func _ready():
	rng.randomize()

func change_phase(ph):
	match ph:
		wandering:
			if phase != ph:
				hand_controller.hide_a_hand()
		battle:
			if phase != ph:
				hand_controller.show_a_hand()


func get_possible_enemys():
	#тут надо добавить обращение к туману войны и комнатам, что for шёл не по всем, а только по нужным
	var keys = []
	var value = {}
	for en in enemy_units.get_children():
		if not en.unit_name in keys:
			keys.append(en.unit_name)
			value[en.unit_name] = [en]
		else:
			value[en.unit_name].append(en)
	enemys = value
	enemys_types = keys

func start_battle():
	stage = battle
	get_possible_enemys()
	players = player_units.get_children()
	start_stage()
	

func start_stage():
	def_initiative()


func def_initiative():
	for k in enemys_types:
		initiative_deck.append_array([k,k])
	for u in players:
		initiative_deck.append(u)
	initiative_deck.shuffle()

func get_initiative():
	if initiative_deck.size() == 0:
		def_initiative()
	var curr = initiative_deck[0]
	if typeof(curr) == 4:
		stage = enemy_stage
		current_enemys = enemys[curr]
		initiative_deck.erase(curr)
		initiative_deck.erase(curr)
	else:
		stage = player_stage
		current_player_unit = curr
		initiative_deck.pop_front()

func start_turn():
	get_initiative()
	match stage:
		player_stage:
			call_hand()
			call_main_action()
			call_other_action()
		enemy_stage:
			for en in current_enemys:
				AI()
				print("AI turn")
	

func AI():
	pass

func call_hand():
	pass

func call_main_action():
	pass
	
func call_other_action():
	pass



