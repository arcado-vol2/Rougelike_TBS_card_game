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



func Draw(tiletp):
	#var prefabs = find_parent("TileMap").get_prefabs()
	var size = Vector2(right - left + 1 ,bottom - top + 1)
	
	var tmp = Label.new()
	tmp.text = str(size)
	tmp.margin_left = left*32
	tmp.margin_top = top*32
	
	find_parent("TileMap").add_child(tmp)
	for x in range (left,right+1):
		for y in range (bottom,top-1,-1):
			find_parent("TileMap").set_cell(x,y,tiletp)
	
	
