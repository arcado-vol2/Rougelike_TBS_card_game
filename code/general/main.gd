extends Node2D

var activation_deck = []
var turn = 0

enum game_state {
	MOVE,
	FIGHT
}

func add_new_entity(entity_name):
	if not entity_name in activation_deck:
		activation_deck.append(entity_name)	

func shuffle_activation_deck():
	activation_deck.shuffle()

func make_a_turn():
	pass
