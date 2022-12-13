extends Node

var max_stats = []

export var health = 10
export var armor = 0

var deck = ["template","br_156","br_156","br_156", "adaptiv_sheald", "adaptiv_sheald", "adaptiv_sheald", "boots_dr1", "boots_dr1", "boots_dr1"]
var hand = []

func _ready():
	max_stats = {"health":health, "armor":armor}

func reset_stats():
	health = max_stats["health"]
	armor = max_stats["armor"]

func save_hand(in_hand):
	hand = in_hand

func save_deck(in_deck):
	deck = in_deck

func get_hand():
	return hand

func get_deck():
	return deck
