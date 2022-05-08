extends Node




var rng = RandomNumberGenerator.new()
var canvas = []

func _ready():
	for i in range(100):
		var t = []
		for j in range(100):
			t.append(0)
		canvas.append(t)

func parabolla(point1, point2):
	var b = (point2[1] - point1[1])/(0.5*point2[0] + pow(point1[0],2)/(2*point2[0]) - point1[0])
	var a = -b/(2*point2[0])
	var c = point1[1]  - pow(point1[0],2)*a -  point1[0]*b
	return [a,b,c]


func draw_ray(point1, point2):
	var dx = point2.x - point1.x
	var dy = point2.y - point2.y
	var sign_x = 1 if dx>0 else -1 if dx<0 else 0
	var sign_y = 1 if dy>0 else -1 if dy<0 else 0
	   
	if dx < 0: dx = -dx
	if dy < 0: dy = -dy
	
	var el
	var pdx
	var pdy
	var es
	if dx > dy:
		pdx = sign_x
		pdy = 0
		es = dy
		el = dx
	else:
		pdx = 0
		pdy = sign_y
		es = dx
		el = dy
		
	var x = point1.x
	var y = point1.y
	var error = el/2
	var t = 0    
	#tile_map.set_cell(x,y,-1)

	while t < el:
		error -= es
		if error < 0:
			error += el
			x += sign_x
			y += sign_y
		else:
			x += pdx
			y += pdy
		t += 1
		#tile_map.set_cell(x,y,1)


class math_line:
	func _init( p1, p2):
		self.k  = (p1[1] - p2[1])/(p1[0] - p2[0])
		self.d = p2[1] - self.k*p2[0]
	func get_point(x):
		return int(self.k*x + self.d)
		
		
func _split(ln, min_w = 2, max_w = 10):
	var t = ln
	var t1 = []
	for i in range(len(ln)):
		var r = rng.randi_range(0,max_w)
		if ln[i]/2 - r >= 3:    
			t+=_split([ln[i]/2 - r])
			t+=_split([ln[i]/2 + r])
			if len(t)!=0:
				t.remove(0)
	ln =  t  
	return ln



func suboptimal_path(start_point, end_point, start_range, end_range):
	#Базовые данные
	if start_point.x > end_point.x:
		var buffer = start_point
		start_point = end_point
		end_point = buffer
	var x_split = _split([end_point.x - start_point.x])
	
	#Генерация вершин в пределах линий
	var border_1 = math_line.new([start_point[0],start_point[1] + start_range], 
	[end_point[0],end_point[1] + end_range])
	var border_2 = math_line.new([start_point[0],start_point[1] - start_range], 
	[end_point[0],end_point[1] - end_range])
	
	var tmp = start_point[0]-1
	var points = []
	for i in range(len(x_split)):
		tmp += x_split[i]
		var b1 = points[i][1] + x_split[i]
		var b2 = points[i][1] - x_split[i]
		
		b1 = min(b1,border_1.get_point(tmp))
		b2 = max(b2,border_2.get_point(tmp))
		points.append([tmp, rng.randi_range(b2,b1)])
			
	points[len(points)-1] = end_point
	#Создание дополнительных вершин
	var tmp_points = [points[0]]
	for i in range(1,len(points)-1):
		tmp.append(points[i])
		
		var mx = max(points[i][1], points[i+1][1])
		var mn = min(points[i][1], points[i+1][1])
		var d = abs(mn - mx)
		
		tmp_points.append(Vector2(
			rng.randint(points[i][0]+int(x_split[i]*0.2), points[i+1][0]-int(x_split[i]*0.2)),
			rng.randint(mn+int(d*0.2),mx-int(d*0.2)) ))
	tmp_points.append(points[len(points)])
	points = tmp_points.copy()
	var last_point = start_point
	#cглаживание
	for i in range(1,len(points)):
		#Первая половинка параболлы
		var par
		if (i)%2==1:
			par = parabolla(points[i-1],points[i])			
		#Вторая половинка параболлы 
		else:
			par = parabolla(points[i],points[i-1])
		var a = par[0]
		var b = par[1]
		var c = par[2]
		for x in range(points[i-1][0],points[i][0]+1):
			var p = [x,int( a*pow(x,2)+b*x+c )]
			draw_ray(last_point, p)
			last_point = p

