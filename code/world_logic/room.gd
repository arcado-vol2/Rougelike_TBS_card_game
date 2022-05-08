extends Node2D


var size

func make_room(_pos,_size):
	position=_pos
	size=_size
	var col=RectangleShape2D.new()
	col.custom_solver_bias=1
	col.extents=size
	$CollisionShape2D.shape=col

