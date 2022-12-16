extends Node2D

const card_base = preload("res://scenes/cards/card_base.tscn")

export var card_scale = 0.4

onready var hand_node = $hand
onready var ap = $AnimationPlayer
onready var active_type_sprite = $card_type/Sprite
onready var level = $ViewportContainer/Viewport/level

var current_hand = []
var current_deck = []
var hand_angle = deg2rad(20)
var radius
var hand_center
var center_card_y
var max_y
var max_hand_size = 10

var active_type = 2
var action_type = 0
#Я ебал в рот этого годота, для безопастности мы удаляем объект на следующем кадре, но сука следующий кадр
#это не следующий кадр, а кадр после него, вот и приходится чудить
#но с другой стороны, это чисто моя шиза 
var rerange_flag = false
var rerange_frames = 0


#Метод восстановления руки при смене выбранного юнита
func restore_hand(hand):
	current_hand = []
	draw_a_card(hand.size(), hand)

#Задаём начальные параметры для расчёта руки
func _ready():
	set_physics_process(false)
	hand_center = Vector2(hand_node.get_rect().size.x/2, 0)
	center_card_y = 0
	ap = get_node("AnimationPlayer")
	radius = (hand_node.get_rect().size.x * sin((PI - hand_angle)/2))/sin(hand_angle)
	hand_center.y = - sqrt(pow(radius,2) - pow(hand_center.x,2))
	max_y = max(sqrt(pow(radius,2)) + hand_center.y, -sqrt(pow(radius,2)) + hand_center.y)
	
#Существует лишь потому что у движка есть особенность обработки удаления обхектов
func _physics_process(delta):
	if rerange_flag:
		rerange_frames+=1
		if rerange_frames >=2:
			rerange_hand()
			rerange_flag = false
			rerange_frames = 0
			set_physics_process(false)

#Обработка событий клавиатуры
func _unhandled_input(event):
	$ViewportContainer/Viewport.input(event)
	#Изменение типа активации карты
	if event.is_action_pressed("next_card_type"):
		ap.play("next")
		active_type = (active_type + 1) % 3
		active_type_sprite.frame = active_type
		change_active_type()
	if event.is_action_pressed("prev_card_type"):
		ap.play("next")
		active_type = active_type - 1
		active_type = active_type % 3 if active_type>=0 else 3 + active_type % 3 
		active_type_sprite.frame = active_type
		change_active_type()
	if active_type!= 0:
		action_type = -1

#функция для изменения типа активации для всех карт в руке
func change_active_type():
	for card in hand_node.get_children():
		card.update_active_type(active_type)

#добор карты
func draw_a_card(count = 1, deck = null, card = null ):
	print(deck)
	if card != null:
		return
	if deck == null:
		deck = current_deck
	for card in count:
		if deck.size() >=1 and current_hand.size()+1 <= max_hand_size:
			current_hand.append(deck.pop_front())
			var tmp_card = card_base.instance()
			tmp_card.scale = Vector2(card_scale,card_scale)
			tmp_card.real_card_name = current_hand.back()
			tmp_card.position = Vector2(hand_node.get_rect().size.x+100,0)
			tmp_card.set_position_in_hand(current_hand.size()-1)
			tmp_card.max_y = max_y
			tmp_card.update_active_type(active_type)
			hand_node.add_child(tmp_card)
	rerange_hand()

func neg_or_pos(val):
	if val >=0:
		return -1
	return 1
	
func rerange_hand():
	var center = hand_center.x
	var one_offset = hand_node.get_rect().size.x / (current_hand.size()+1)
	var hand_by_node = hand_node.get_children()
	var shear = 0
	if one_offset >= 94:
		shear = 0.2
	for card_i in hand_by_node.size():
		var target_position = Vector2.ZERO
		if hand_node.focused_i!=-1:
			if card_i < hand_node.focused_i:
				target_position.x = (card_i) * one_offset
			elif card_i > hand_node.focused_i:
				target_position.x = (card_i+2) * one_offset
			else:
				continue
		else:
			target_position.x = (card_i+1) * one_offset
		var card_sep = center - target_position.x
		if shear != 0:
			target_position.x += card_sep * shear	
		target_position.y = max(sqrt(pow(radius,2) +  pow(hand_center.x - target_position.x,2)) + hand_center.y,
		-sqrt(pow(radius,2) +  pow(hand_center.x - target_position.x,2)) + hand_center.y)
		hand_by_node[card_i].set_target_angle( neg_or_pos(card_sep) * rad2deg(asin(abs(card_sep)/radius)) )
		hand_by_node[card_i].set_target_pos(target_position)
		hand_by_node[card_i].save_hand_parameters()



func _on_Button_pressed():
	#call("draw_a_card") чтобы блять не забыть
	draw_a_card()

func trow_a_card(card_i, metods, metods_vars):
	hand_node.get_child(card_i).queue_free()
	current_hand.pop_at(card_i)
	for card in hand_node.get_children():
		if card.position_in_hand > card_i:
			card.set_position_in_hand(card.position_in_hand-1)
	hand_node.focused_i = -1 
	rerange_flag = true
	set_physics_process(true)
	print(metods, metods_vars)
	var t_q = []
	for i in metods.size():
		t_q.append([metods[i], metods_vars[i]])
	
	level.start_action(t_q)

func fold_a_hand():
	var center = hand_center.x
	for card in hand_node.get_children():
		card.set_target_pos(Vector2(center,10))

func hide_a_hand():
	print(ap)
	ap.play("hide_hand")

func show_a_hand():
	ap.play("show_hand")




func _on_bunker_tile_set_loading_complete():
	$loading_screen.queue_free()


func _on_cave_tile_set_loading_complete():
	$loading_screen.queue_free()
