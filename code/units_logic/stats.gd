extends Node

var max_stats = []

export var health = 10
export var armor = 0

var deck = []
var hand = []

func _ready():
	max_stats = {"health":health, "armor":armor}

func reset_stats():
	health = max_stats["health"]
	armor = max_stats["armor"]

func set_hand(in_hand):
	hand = in_hand

func set_deck(in_deck):
	deck = in_deck
