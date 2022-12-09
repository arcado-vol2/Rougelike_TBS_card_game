extends Node2D

const RATE: float = 8.0

onready var icon = $CardBase/bars/stats/icon/Sprite
onready var attack = $CardBase/bars/stats/attack/text
onready var speed = $CardBase/bars/stats/speed/text
onready var defence = $CardBase/bars/stats/defence/text
onready var image = $CardBase/bars/image/Sprite
onready var main = $CardBase/bars/discription/main/dis/text
onready var reaction = $CardBase/bars/discription/reaction/dis/text
onready var card_back = $card_back
onready var card_name = $CardBase/bars/name/text
onready var separation_bar = $CardBase/bars/discription/separation_line
onready var card_db = preload("res://code/card_logic/cards_database.gd")
onready var main_block = $CardBase/bars/discription/main
onready var reaction_block = $CardBase/bars/discription/reaction

export var real_card_name = "template"

var animate = false
var max_y

var card_size
var card_info

var hand_angle
var hand_size = Vector2(99,99)
var hand_pos

var target_pos = position 
var target_ang = rotation_degrees
var target_size = scale

var changing_pos = false
var changing_ang = false
var changing_size = false

var position_in_hand

var active_type = 0

enum {
	in_hand,
	focus,
	in_mouse,
}
var state = in_hand


func _ready():	
	card_size = $CardBase.get_rect().size + Vector2(4,4)
	card_info = card_db.DATA[card_db.get(real_card_name)]
	icon.frame = card_info[0]
	attack.text = str(card_info[1][0]) + "/" + str(card_info[1][1])
	speed.text = str(card_info[2])
	defence.text = str(card_info[3])
	image.texture = load("res://texture/cards/cards_image/"+card_info[4]+".png")
	card_name.text = str(card_info[5])
	main.text = str(card_info[6])
	if card_info[6] == "":
		separation_bar.visible = false
		main_block.visible = false
		
	if card_info[7] == "":
		separation_bar.visible = false
		reaction_block.visible = false
	reaction.text = str(card_info[7])
	
func set_position_in_hand(pos):
	position_in_hand = pos

func update_active_type(in_type):
	active_type = in_type

func get_card_size():
	return card_size

func get_target_pos():
	return target_pos

func set_target_pos(pos):
	target_pos  = pos
	changing_pos = true
	
func set_target_angle(angle):
	target_ang  = angle
	changing_ang = true
	
func set_target_size(size):
	target_size  = size
	changing_size = true

func _physics_process(delta):
	match state:
		in_hand, focus:
			if changing_pos:
				position = position.linear_interpolate(target_pos,RATE*delta)
			if position.is_equal_approx(target_pos):
				changing_pos = false
			if changing_ang:
				rotation_degrees = rad2deg(lerp(deg2rad(rotation_degrees),deg2rad(target_ang), RATE*delta))
			if is_equal_approx(rotation_degrees,target_ang):
				changing_ang = false
			if changing_size:
				scale = scale.linear_interpolate(target_size,RATE*delta)
			if scale.is_equal_approx(target_size):
				changing_size = false
			if not (changing_size and changing_ang and changing_ang):
				state = in_hand
				animate = false
		in_mouse:
			if changing_size:
				scale = scale.linear_interpolate(target_size,RATE*delta)
			position = get_parent().get_local_mouse_position()


func _on_focus_mouse_entered():
	if not animate:
		z_index = 1
		set_target_size(Vector2.ONE)
		set_target_angle(0)
		set_target_pos(Vector2(hand_pos.x, max_y)- Vector2(0,$CardBase.get_rect().size.y/2))
		state = focus
		get_parent().focus(position_in_hand)

func save_hand_parameters():
	hand_angle = target_ang
	hand_pos = target_pos
	if scale < hand_size:
			hand_size = scale

func _on_focus_mouse_exited():
	reset_to_hand_pos()
	get_parent().unfocus()

func reset_to_hand_pos():
	if not animate:
		z_index = 0
		set_target_angle(hand_angle)
		set_target_size(hand_size)
		set_target_pos(hand_pos)
		state = in_hand




func _on_focus_button_down():
	state = in_mouse
	set_target_size(Vector2(0.4,0.4))
	set_target_angle(0)


func _on_focus_button_up():
	if position.y <= get_parent().dead_zone:
		activate_card(active_type,0)
	else:
		state = focus
		reset_to_hand_pos()
		_on_focus_mouse_exited()
	

func activate_card(active_type, turn_type):
	var methods = []
	var methods_vars = []
	if turn_type == 0:
		print(active_type)
		match active_type:
			#По описанию
			2:
				methods = card_info[8]
				methods_vars = card_info[10] 
			#Спринт
			0:
				methods = ["move"]
				methods_vars = [[card_info[2]]]
			#Атака
			1:
				methods = ["attack"]
				methods_vars = [[card_info[1]]]
	else:
		match active_type:
			#По описанию
			0:
				methods = card_info[9]
				methods_vars = card_info[11] 
			#В его обход
			1:
				methods = ["defence"]
				methods_vars = [[card_info[3]]]
	get_parent().get_parent().trow_a_card(position_in_hand, methods, methods_vars)
