extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var binary_room = load("res://code/world_logic/binary_room.gd")
	var f = binary_room.new(0,100,0,100,0)
	add_child(f)
	f.Split()
	f.trim()
	f.Drawb() # Replace with function body.
	f.AddCoridors()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
