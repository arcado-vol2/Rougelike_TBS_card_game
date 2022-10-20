extends Node

var leftRoom
var rightRoom

var rng=RandomNumberGenerator.new()
onready var BSP_script=load("res://code/world_logic/BSP_script.gd")

var left
var right
var top
var bottom

var verticalSplit = false
var horizontalSplit = false
var trimTiles=2
const minWidth=15
const minHeight=15
const maxWidth=20
const maxHeight=20

func getWidth():
	return right-left+1

func getHeight():
	return bottom-top+1

func isLeaf():
	return (verticalSplit==false) && (horizontalSplit==false)

func _init(_left,_right,_top,_bottom):
	rng.randomize()
	left=_left
	right=_right
	top=_top
	bottom=_bottom

func split():
	var rand = rng.randi()%2
	if(rand==0 && getWidth()>=2*minWidth):
		verticalSplit()
	elif(getHeight()>=2*minHeight):
		horizontalSplit()
	if (getHeight()>2*maxHeight && isLeaf()):
		horizontalSplit()
	if (getWidth()>2*maxWidth && isLeaf()):
		verticalSplit()

func verticalSplit():
	verticalSplit=true
	rng.randomize()
	var coord = rng.randi_range(left + minWidth,right-minWidth+1)
	leftRoom = BSP_script.new(left, coord-1, top, bottom)
	leftRoom.name="leftroom"
	add_child(leftRoom)
	rightRoom = BSP_script.new(coord, right, top, bottom)
	rightRoom.name="rightroom"
	add_child(rightRoom)

	leftRoom.split()
	rightRoom.split()

func horizontalSplit():
	horizontalSplit = true
	rng.randomize()
	var coord = rng.randi_range(top+minHeight,bottom-minHeight+1)
	leftRoom = BSP_script.new(left, right, top, coord-1)
	leftRoom.name="toproom"
	add_child(leftRoom)
	rightRoom = BSP_script.new(left, right, coord, bottom)
	rightRoom.name="bottomroom"
	add_child(rightRoom)

	leftRoom.split()
	rightRoom.split()


