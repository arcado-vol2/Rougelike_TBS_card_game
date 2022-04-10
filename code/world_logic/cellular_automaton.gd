extends Node

var left
var right
var top
var bottom
var rng = RandomNumberGenerator.new()
var noise=[]
var wrlmap=[]

func _ready():
	pass 

func _init(lef,righ,tp,bot,chance):
	left=lef
	right=righ
	top=tp
	bottom=bot
	rng.seed = hash(OS.get_datetime()["second"] + OS.get_datetime()["minute"] + OS.get_datetime()["hour"])
	randomize()
	var curchance
	for x in range (0, right-left+3): # генерируем шум и второй массив для последующих итераций
		noise.append([])
		wrlmap.append([])
		for y in range(top-1,bottom+2):
			if ((x==0)|| (x==right-left+2) || (y==top-1) || (y==bottom+1)):
				noise[x].append(1)
				wrlmap[x].append(1)
			else:
				curchance=rng.randi()%101
				if curchance<=chance:
					noise[x].append(1)
					wrlmap[x].append(1)
				else:
					noise[x].append(0)
					wrlmap[x].append(0)

func Draw():
	for x in range(0,right-left+1):
		for y in range(0,bottom-top+1):
			find_parent("TileMap").set_cell(left+x,top+y,noise[x][y])

func iterate(iternum): 
	for iteration in range(0,iternum):
		for x in range(1,right-left+1):
			for y in range(1,bottom-top+1):
				if neighwalls(x,y)>4:
					wrlmap[x][y]=1
				else:
					wrlmap[x][y]=0
		for x in range(1,right-left):
			for y in range(1,bottom-top):
				noise[x][y]=wrlmap[x][y]

func neighwalls(x,y):
	var count=0
	for x1 in range(x-1,x+2):
		for y1 in range (y-1,y+2):
			if (y1==y) && (x1==x):
				continue
			if noise[x1][y1]==1:
				count+=1
	return count
