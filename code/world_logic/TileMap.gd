extends TileMap
var prefabs


func _BSP():
	#prefabs = [Save_load_system.load_prefab(), Save_load_system.load_file(1)]
	var binary_room = load("res://code/world_logic/binary_room.gd")
	var rt = binary_room.new(0,50,0,50,0)
	add_child(rt)
	rt.Draw(1)
	rt.Split()
	rt.trim()
	rt.Drawb() 
	rt.AddCoridors()
	rt.optimize(0,100,0,100) #Размеры карты, для удаления ненужных стен

func _cell():
	var cellular = load("res://code/world_logic/BSP_+_cellular.gd")
	var t = cellular.new(Vector2.ZERO, 20,20,0.5,2)
	add_child(t)
	t.cellular_auto(2,2)
	t.fill([[10, 10]])
	t.draw()
	
func _ready():
	pass
	#_cell()

func get_prefabs():
	return prefabs
