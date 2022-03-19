extends Node


var stats = {}

func add_unit(name, unit):
	stats[name] = unit
		

func remove_unit(name):
	if stats.has(name):
		stats.erase(name)
