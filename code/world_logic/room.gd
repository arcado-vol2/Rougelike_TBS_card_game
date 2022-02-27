extends Node

var left
var right
var top
var bottom
var tile

func GetWidth():
	return right-left+1

func GetHeight():
	return bottom-top+1

func _init(a,b,c,d,e):
	left=a
	right=b
	top=c
	bottom=d
	tile=e

func GetLeft():
	return left
func GetRight():
	return right
func GetTop():
	return top
func GetBottom():
	return bottom

func Draw():
	for x in range (left,right+1):
		for y in range (bottom,top-1,-1):
			find_parent("TileMap").set_cell(x,y,tile)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
