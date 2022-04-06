extends Node2D


onready var tile_map = $TileMap

func _ready():
	#Save_load_system.overwrite_file([],1)
	var tmp = Save_load_system.load_file(1)
	print(tmp)


func _on_Button_pressed():
	var tmp = []
	var wals = $TileMap.get_used_cells()
	var wals_x = []
	var wals_y =[]
	for i in wals:
		wals_x.append(i[0])
		wals_y.append(i[1])
	for obj in $Obj.get_children():
		tmp.append({obj.name:[obj.get_id(), obj.position]})
	
	Save_load_system.add_to_file({
		"name":$Control/LineEdit.text,
		"wals": $TileMap.get_used_cells(),
		"objects": tmp,
		"size": Vector2(wals_x.max(), wals_y.max())
	}, 1)
