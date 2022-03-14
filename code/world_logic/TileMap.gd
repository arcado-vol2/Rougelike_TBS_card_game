extends TileMap


func _ready():
	var binary_room = load("res://code/world_logic/binary_room.gd")
	var rt = binary_room.new(0,100,0,100,0)
	add_child(rt)
	rt.Draw(1)
	rt.Split()
	rt.trim()
	rt.Drawb() 
	rt.AddCoridors()
	#rt.optimize(0,100,0,100) #Размеры карты, для удаления ненужных стен

