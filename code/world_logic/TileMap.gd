extends TileMap
var prefabs


func _BSP():
	prefabs = [Save_load_system.load_prefab(), Save_load_system.load_file(1)]
	var binary_room = load("res://code/world_logic/binary_room.gd")
	var rt = binary_room.new(0,30,0,30,0)
	add_child(rt)
	rt.Draw(1)
	rt.Split()
	rt.trim()
	rt.Drawb() 
	rt.AddCoridors()

func _cell():
	var cellar = load("res://code/world_logic/BSP_+_cellar.gd")
	var t = cellar.new(Vector2.ZERO, 20,20,0.5,2)
	add_child(t)
	t.cellar_auto(2,2)
	t.fill([[10, 10]])
	t.draw()
	
func _ready():
	_cell()
	#rt.optimize(0,100,0,100) #Размеры карты, для удаления ненужных стен

func get_prefabs():
	return prefabs
