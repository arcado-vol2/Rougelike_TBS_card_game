extends Node2D
#Блок кода для отрисовки рамки выделения

var drag_start = Vector2.ZERO
var drag_end = Vector2.ZERO
var dragging = false

func _draw():
	if dragging:
		draw_rect(Rect2(drag_start, drag_end - drag_start), Color(0.4,0.4,1), false)



func update_status(start_pos, end_pos, drag):
	drag_start = start_pos
	drag_end = end_pos
	dragging = drag
	update() 


	
