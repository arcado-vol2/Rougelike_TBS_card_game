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
const minWidth = 15
const maxWidth = 20
const minHeight = 15
const maxHeight = 20
const trimmax=4
const trimmin=2
export var trimTiles=2
var verticalSplit
var horizontalSplit

var leftroom
var rightroom
var con

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

func IsLeaf(): # является ли комната листом ?
	return ((horizontalSplit==false) && (verticalSplit==false))

func Split(): # разделение комнат
	var rand=randi()%2
	if (rand==0 && GetWidth() >= 2*minWidth):
		VerticalSplit()
	elif (GetHeight()>=2*minHeight):
		HorizontalSplit()
	if (GetHeight()>2*maxHeight && IsLeaf()):
		HorizontalSplit()
	if (GetWidth()>2*maxWidth+2 && IsLeaf()):
		VerticalSplit()

func VerticalSplit(): 
	verticalSplit=true
	rng.randomize()
	var coord = rng.randi_range(left + minWidth,right-minWidth+1)
	leftroom = binary_room.new(left, coord-1, top, bottom,0)
	leftroom.name="leftroom"
	add_child(leftroom)
	rightroom = binary_room.new(coord, right, top, bottom,0)
	rightroom.name="rightroom"
	add_child(rightroom)
	
	leftroom.Split()
	rightroom.Split()

func HorizontalSplit():
	horizontalSplit = true
	rng.randomize()
	var coord = rng.randi_range(top+minHeight,bottom-minHeight+1)
	leftroom = binary_room.new(left, right, top, coord-1,0)
	leftroom.name="toproom"
	add_child(leftroom)
	rightroom = binary_room.new(left, right, coord, bottom,0)
	rightroom.name="bottomroom"
	add_child(rightroom)
	
	leftroom.Split()
	rightroom.Split()


func _ready():
	randomize() # Replace with function body.

func Drawb(): #Отрисовка комнат
	if (IsLeaf()):
		self.Draw(0)
	else:
		leftroom.Drawb()
		rightroom.Drawb()

func trim(): # случайная обрезка краев комнат
	rng.randomize()
	var trimTileslf=rng.randi_range(trimmin,trimmax)
	var trimTilesrt=rng.randi_range(trimmin,trimmax)
	var trimTilesbt=rng.randi_range(trimmin,trimmax)
	var trimTilestp=rng.randi_range(trimmin,trimmax)
	left += trimTileslf
	right -= trimTilesrt
	top += trimTilestp
	bottom -= trimTilesbt
	if (leftroom!=null):
		leftroom.trim()
	if (rightroom!=null):
		rightroom.trim()

func GetRigthConnections(): #Найти правые точки соединения
	var connections =[]
	if (!IsLeaf()):
		if(rightroom!=null):
			connections.append_array(rightroom.GetRigthConnections())
		if(horizontalSplit && leftroom!=null):
			connections.append_array(leftroom.GetRigthConnections())
	else:
		for y in range(bottom-CorridorMargin,top+CorridorMargin-1,-1):
			var allptns=Vector2(right+1,y)
			connections.append(allptns)
	return connections

func GetLeftConnections(): #Найти левые точки соединения
	var connections =[]
	if (!IsLeaf()):
		if(leftroom!=null):
			connections.append_array(leftroom.GetLeftConnections())
		if(horizontalSplit && rightroom!=null):
			connections.append_array(rightroom.GetLeftConnections())
	else:
		for y in range(bottom-CorridorMargin,top+CorridorMargin-1,-1):
			var allptns=Vector2(left-1,y)
			connections.append(allptns)
	return connections

func GetTopConnections(): #Найти верхние точки соединения
	var connections =[]
	if (!IsLeaf()):
		if(leftroom!=null):
			connections.append_array(leftroom.GetTopConnections())
		if(verticalSplit && rightroom!=null):
			connections.append_array(rightroom.GetTopConnections())
	else:
		for x in range(left+CorridorMargin,right-CorridorMargin+1):
			var allptns=Vector2(x,top-1)
			connections.append(allptns)
	return connections

func GetBottomConnections(): #Найти нижниеточки соединения
	var connections =[]
	if (!IsLeaf()):
		if(rightroom!=null):
			connections.append_array(rightroom.GetBottomConnections())
		if(verticalSplit && leftroom!=null):
			connections.append_array(leftroom.GetBottomConnections())
	else:
		for x in range(left+CorridorMargin,right-CorridorMargin+1):
				var allptns=Vector2(x,bottom+1)
				connections.append(allptns)
	return connections

func GetIntersectionGroups(points): #Определить группы соединения для формирования коридоров
	var groups = []
	points.sort()
	var num
	var grx=0
	var gry=0
	var cnt=0
	var firstTime=true
	var currentGroup=[]
	for i in range(0,points.size()):
		num=points[i].z
		grx=points[i-1].x
		gry=points[i-1].y
		if (firstTime || points[i-1].z!=points[i].z-1):
			if(!firstTime):
				var prom=[grx,gry,currentGroup]
				groups.append(prom)
				cnt+=1
			firstTime=false
			currentGroup=Vector2(num,num)
		else:
			currentGroup.y+=1
	if (!firstTime):
		var prom=[grx,gry,currentGroup]
		groups.append(prom)
	var rezgroups=[]
	cnt=0
	for al in groups:
		var f=al[2].x
		for on in range (al[2].x,al[2].y+1):
			if (on-f >= minCorridorThickness):
				var prom=[al[0],al[1],Vector2(f,on)]
				rezgroups.append(prom)
				f+=1
		cnt+=1
	return rezgroups

func Intersecty(arr1,arr2): #Найти смежные точки соединения по y
	var arr3=[]
	for x in arr1:
		for y in arr2:
			if x.y==y.y:
				arr3.append(Vector3(x.x,y.x,x.y))
			if y>x:
				continue
	return arr3
	
func Intersectx(arr1,arr2): #Найти смежные точки соединения по x
	var arr3=[]
	for x in arr1:
		for y in arr2:
			if x.x==y.x:
				arr3.append(Vector3(x.y,y.y,x.x))
			if y>x:
				continue
	return arr3

func AddCoridors(): #Добавить коридоры
	var corridor
	if (IsLeaf()):
		return;
	if (leftroom!=null):
		leftroom.AddCoridors()
	if (rightroom!=null):
		rightroom.AddCoridors()
	if (leftroom!=null && rightroom!=null):
		if (verticalSplit):
			var positions = Intersecty(leftroom.GetRigthConnections(),rightroom.GetLeftConnections())
			var groups=GetIntersectionGroups(positions)
			var p = groups[rng.randi_range(0,groups.size()-1)]
			corridor = room.new(p[0],p[1],p[2].x,p[2].y,0)
			con=corridor
			corridor.name="corridor" 
			add_child(corridor)
			corridor.Draw(0)
		if (horizontalSplit):
			var positions = Intersectx(leftroom.GetBottomConnections(),rightroom.GetTopConnections())
			var groups=GetIntersectionGroups(positions)
			var p = groups[rng.randi_range(0,groups.size()-1)]
			corridor = room.new(p[2].x,p[2].y,p[0],p[1],0)
			con=corridor
			corridor.name="corridor" 
			add_child(corridor)
			corridor.Draw(0)

func neigh(x,y): #являются ли соседи пустыми или стенами
	return ((find_parent("TileMap").get_cell(x,y)==1) &&
	(find_parent("TileMap").get_cell(x-1,y)==1 ||find_parent("TileMap").get_cell(x-1,y)==-1) &&
	(find_parent("TileMap").get_cell(x+1,y)==1 ||find_parent("TileMap").get_cell(x+1,y)==-1) &&
	(find_parent("TileMap").get_cell(x,y-1)==1 ||find_parent("TileMap").get_cell(x,y-1)==-1) &&
	(find_parent("TileMap").get_cell(x,y+1)==1 ||find_parent("TileMap").get_cell(x,y+1)==-1) &&
	(find_parent("TileMap").get_cell(x-1,y-1)==1 ||find_parent("TileMap").get_cell(x-1,y-1)==-1) &&
	(find_parent("TileMap").get_cell(x+1,y-1)==1 ||find_parent("TileMap").get_cell(x+1,y-1)==-1) &&
	(find_parent("TileMap").get_cell(x+1,y+1)==1 ||find_parent("TileMap").get_cell(x+1,y+1)==-1) &&
	(find_parent("TileMap").get_cell(x-1,y+1)==1 ||find_parent("TileMap").get_cell(x-1,y+1)==-1))

func optimize(a,b,c,d): #Удаление ненужных стен
	for x in range(a,b+1):
		for y in range (c,d+1):
			if neigh(x,y):
				find_parent("TileMap").set_cell(x,y,-1)
