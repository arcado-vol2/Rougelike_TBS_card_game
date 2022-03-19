#Короче, тут код выделения юнитов и контроля камерой
extends Node2D
var dragging = false
var selected_units = []
var weakref_selected = []
var drag_start_position = Vector2.ZERO
var select_rectangle = RectangleShape2D.new()
var position_dep_cam = Vector2.ZERO

onready var select_draw = $Select_Draw
onready var camera = $Camera2D
onready var pointer = $move_target_animation
onready var hud = $Camera2D/hud

const CAMERA_MOVE_SPEED = 10
const CAMERA_MOVE_MARGIN = 20

func _ready():
	camera.position = get_viewport_rect().size / 2
func _physics_process(delta):
	print(UNIT_GLOBAL.stats)
	calc_move(get_viewport().get_mouse_position(), delta)
	
	

func _unhandled_input(event):
	#Выделение юнитов
	if event is InputEventMouseMotion:
		position_dep_cam  = event.position  + camera.position - get_viewport_rect().size / 2
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		
		#print(event.position, " event")
		if event.pressed:
			if selected_units.size() >0:
				hud.update_label("ПИЗДА СЛОНА")
			for unit in weakref_selected:
				if unit.get_ref():
					if unit.get_ref().is_in_group("unit"):
						unit.get_ref().unselected()
			selected_units = []
			weakref_selected = []
			dragging = true
			drag_start_position = position_dep_cam
		elif dragging:
			dragging = false
			select_draw.update_status(drag_start_position, position_dep_cam, dragging)
			var drag_end_position = position_dep_cam
			select_rectangle.extents = (drag_end_position - drag_start_position)/2
			var space 	= get_world_2d().direct_space_state
			var query = Physics2DShapeQueryParameters.new()
			query.set_shape(select_rectangle)
			query.transform = Transform2D(0, (drag_end_position + drag_start_position)/2)
			selected_units = space.intersect_shape(query)
			for unit in selected_units:
				if unit.collider.is_in_group("unit") and unit.collider.unit_owner == 0:
					unit.collider.selected()
					weakref_selected.append(weakref(unit.collider))
			if selected_units.size() >0:
				hud.update_label(selected_units[0].collider.name)
	if dragging:
		if event is InputEventMouseMotion:
			select_draw.update_status(drag_start_position, position_dep_cam, dragging)
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		pointer.position = position_dep_cam
		pointer.frame = 0
		
func get_movment_group():
	return weakref_selected
#контроль камеры	
func calc_move(mouse_pos, delta):
	var viewport_size = get_viewport_rect().size
	var move_vector = Vector2.ZERO
	if mouse_pos.x < CAMERA_MOVE_MARGIN:
		move_vector.x -= 1
	if mouse_pos.x > viewport_size.x - CAMERA_MOVE_MARGIN:
		move_vector.x += 1
	if mouse_pos.y < CAMERA_MOVE_MARGIN:
		move_vector.y -= 1
	if mouse_pos.y > viewport_size.y - CAMERA_MOVE_MARGIN:
		move_vector.y += 1
	camera.position += move_vector*CAMERA_MOVE_SPEED
#Всё
