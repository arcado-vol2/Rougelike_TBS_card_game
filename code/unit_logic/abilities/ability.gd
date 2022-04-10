extends Node
class_name ability

var timer: Timer
var stats
var mana_cost

func _init(_stats, _timer, _cost):
	stats = _stats
	timer = _timer
	mana_cost = _cost

# 0 - всё ок
# 1 - маны не хватает
# 2 - таймер не прошёл
func use():
	if stats.mana - mana_cost >= 0:
		if timer.time_left == 0:
			stats.mana -= mana_cost
			timer.start()
			ability_logic()
			return 0 
		return 2
	return 1
	
func ability_logic():
	pass
