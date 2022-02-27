extends room
export var tlrand = 0
var room=load("res://code/world_logic/room.gd")
var binary_room=load("res://code/world_logic/binary_room.gd")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var rng = RandomNumberGenerator.new()
const minCorridorThickness=2
const CorridorMargin=1 
const minWidth = 7
const maxWidth = 15
const minHeight = 7
const maxHeight = 15
const trimTiles=1
const trimtales=1
var verticalSplit
var horizontalSplit

var leftroom
var rightroom 

func _init(a,b,c,d,e).(a,b,c,d,e):
	rng.seed = hash(OS.get_datetime()["second"] + OS.get_datetime()["minute"] + OS.get_datetime()["hour"])
	randomize()
	#tlrand=randi()%18+1
	#tile=tlrand
	tile = 0
	verticalSplit=false
	horizontalSplit=false
	leftroom=null
	rightroom=null
	if (GetHeight()<minHeight) || (GetWidth()<minWidth):
		print("error, room is too small")

func IsLeaf():
	return ((horizontalSplit==false) && (verticalSplit==false))

func Split():
	var rand=randi()%2
	if (rand==0 && GetWidth() >= 2*minWidth):
		VerticalSplit()
	elif (GetHeight() >=2*minHeight):
		HorizontalSplit()
	if (GetHeight()>maxHeight && IsLeaf()):
		HorizontalSplit()
	if (GetWidth()>maxHeight && IsLeaf()):
		VerticalSplit()

func VerticalSplit():
	verticalSplit=true
	rng.randomize()
	var coord = rng.randi_range(left + minWidth,right-minWidth+1)
	leftroom = binary_room.new(left, coord-1, top, bottom,0)
	add_child(leftroom)
	rightroom = binary_room.new(coord, right, top, bottom,0)
	add_child(rightroom)
	
	leftroom.Split()
	rightroom.Split()

func HorizontalSplit():
	horizontalSplit = true
	rng.randomize()
	var coord = rng.randi_range(top+minHeight,bottom-minHeight+1)
	leftroom = binary_room.new(left, right, top, coord-1,0)
	add_child(leftroom)
	rightroom = binary_room.new(left, right, coord, bottom,0)
	add_child(rightroom)
	
	leftroom.Split()
	rightroom.Split()


func _ready():
	randomize() # Replace with function body.

func Drawb():
	if (IsLeaf()):
		self.Draw()
	else:
		leftroom.Drawb()
		rightroom.Drawb()

func trim():
	left += trimTiles
	right -= trimTiles
	top += trimTiles
	bottom -= trimTiles
	if (leftroom!=null):
		leftroom.trim()
	if (rightroom!=null):
		rightroom.trim()

func GetRigthConnections():
	var connections =[]
	if (!IsLeaf()):
		if(rightroom!=null):
			connections.append_array(rightroom.GetRigthConnections())
		if(horizontalSplit && leftroom!=null):
			connections.append_array(leftroom.GetRigthConnections())
	else:
		for y in range(bottom-CorridorMargin,top+CorridorMargin-1,-1):
			connections.append(y)
	return connections

func GetLeftConnections():
	var connections =[]
	if (!IsLeaf()):
		if(leftroom!=null):
			connections.append_array(leftroom.GetLeftConnections())
		if(horizontalSplit && rightroom!=null):
			connections.append_array(rightroom.GetLeftConnections())
	else:
		for y in range(bottom-CorridorMargin,top+CorridorMargin-1,-1):
			connections.append(y)
	return connections

func GetTopConnections():
	var connections =[]
	if (!IsLeaf()):
		if(leftroom!=null):
			connections.append_array(leftroom.GetTopConnections())
		if(verticalSplit && rightroom!=null):
			connections.append_array(rightroom.GetTopConnections())
	else:
		for x in range(left+CorridorMargin,right-CorridorMargin+1):
			connections.append(x)
	return connections

func GetBottomConnections():
	var connections =[]
	if (!IsLeaf()):
		if(rightroom!=null):
			connections.append_array(rightroom.GetBottomConnections())
		if(verticalSplit && leftroom!=null):
			connections.append_array(leftroom.GetBottomConnections())
	else:
		for x in range(left+CorridorMargin,right-CorridorMargin+1):
			connections.append(x)
	return connections

func GetIntersectionGroups(points):
	var groups = []
	points.sort()
	var num
	var firstTime=true
	var currentGroup=Vector2.ZERO
	for i in range(0,points.size()):
		num=points[i]
		if (firstTime || points[i-1]!=points[i]-1):
			if(!firstTime):
				groups.append(currentGroup)
			firstTime=false
			currentGroup=Vector2(num,num)
		else:
			currentGroup.y+=1
	if (!firstTime):
		groups.append(currentGroup)
	var rezgroups=[]
	for x in groups:
		if (x.y-x.x >= minCorridorThickness):
			rezgroups.append(x)
	return rezgroups

func Intersect(arr1,arr2):
	var arr3=[]
	for x in arr1:
		for y in arr2:
			if x==y:
				arr3.append(x)
	return arr3

func AddCoridors():
	var corridor
	if (IsLeaf()):
		return;
	if (leftroom!=null):
		leftroom.AddCoridors()
	if (rightroom!=null):
		rightroom.AddCoridors()
	if (leftroom!=null && rightroom!=null):
		if (verticalSplit):
			print(leftroom.GetRigthConnections(), " ", rightroom.GetLeftConnections() )
			var positions = Intersect(leftroom.GetRigthConnections(),rightroom.GetLeftConnections())
			var groups=GetIntersectionGroups(positions)
			var p = groups[0]#rng.randi_range(0,groups.size())]
			corridor = room.new(leftroom.right+1,rightroom.left-1,p.x,p.y,0)
			add_child(corridor)
			corridor.Draw()
		if (horizontalSplit):
			var positions = Intersect(leftroom.GetBottomConnections(),rightroom.GetTopConnections())
			var groups=GetIntersectionGroups(positions)
			var p = groups[0]#rng.randi_range(0,groups.size())]
			corridor = room.new(p.x,p.y,leftroom.bottom+1,rightroom.top-1,0)
			add_child(corridor)
			corridor.Draw()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
