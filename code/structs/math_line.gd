extends Node

class_name math_line

var k
var d
func _init( p1, p2):
		k  = (p1[1] - p2[1])/(p1[0] - p2[0])
		d = p2[1] - k*p2[0]
func get_point(x) -> int:
	return int(k*x + d)
