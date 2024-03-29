extends Node




var rng = RandomNumberGenerator.new()
var start_range = 5
var end_range = 5
var radius = 2
onready var tile_map

func setTilemap(tileMap):
	tile_map=tileMap


#Математическая функция параболлы
func parabolla(point1, point2):
	var b
	var a
	if point1.y == point2.y or point1.x == point2.x:
		b = 0
		a = 0
	else:
		b = (point2[1] - point1[1])/(0.5*point2[0] + pow(point1[0],2)/(2*point2[0]) - point1[0])
		a = -b/(2*point2[0])
	var c = point1[1]  - pow(point1[0],2)*a -  point1[0]*b
	return [a,b,c]

#Функция создания прямой
func draw_ray(p1,p2, radius = 0, flip = false):
	#p1 и p2 - точки старта и конца
	#radius - толщина
	#flip - для смены x на y
	var x1
	var y1
	var x2
	var y2
	
	if flip:
		x1 = p1[1]
		y1 = p1[0]
		x2 = p2[1]
		y2 = p2[0]
	
	else:
		x1 = p1[0]
		y1 = p1[1]
		x2 = p2[0]
		y2 = p2[1]
	
	#далее всё строго по алгоритму Брезенхэма	
	var dx = x2 - x1
	var dy = y2 - y1
	var sign_x = 1 if dx>0 else -1 if dx<0 else 0
	var sign_y = 1 if dy>0 else -1 if dy<0 else 0
	if dx < 0: dx = -dx
	if dy < 0: dy = -dy
	var es
	var el  
	var pdx
	var pdy      
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
	var x = x1
	var y = y1
	var error = el/2
	var t = 0   
	
	#Тут толщина по окружности
	for x_2 in radius:
			for y_2 in radius:
				if pow(x_2,2) + pow(y_2,2) <= pow(radius,2):
					tile_map.set_cell(x + x_2, y + y_2 ,0)
					tile_map.set_cell(x - x_2, y + y_2 ,0)
					tile_map.set_cell(x + x_2, y - y_2 ,0)
					tile_map.set_cell(x - x_2, y - y_2 ,0)
	
	
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
		
		#А тут только кусок
		if pdx == 1:
			for i in radius:
				tile_map.set_cell(x,y+i,0)
				tile_map.set_cell(x,y-i,0)
		else:
			for i in radius:
				tile_map.set_cell(x+i,y,0)
				tile_map.set_cell(x-i,y,0)
		tile_map.set_cell(x,y,0)

#функция разбиения массива
func _split(ln,max_w = 10):
	var t = []
	for i in ln:
		if i>=max_w:
			var r = rng.randi_range(0, max_w/2)
			t+=_split([i/2+r],max_w)
			t+=_split([i/2-r],max_w)
		else:
			t.append(i)
	return t

func suboptimal_path(start_point: Vector2, end_point: Vector2):
	#Базовые данные	
	var flip = true
	#Тут усё для поворота
	#ксором проверяем положение
	if  ((not (end_point.x - start_point.x > end_point.y - start_point.y)) or (end_point.x - start_point.x < - end_point.y + start_point.y)) and ((end_point.x - start_point.x > end_point.y - start_point.y) or (not (end_point.x - start_point.x < - end_point.y + start_point.y))):
		var buff = start_point.x
		start_point.x = start_point.y
		start_point.y = buff
		buff = end_point.x
		end_point.x = end_point.y
		end_point.y = buff
	else:
		flip = false
	
	if start_point.x > end_point.x:
		var buffer = start_point
		start_point = end_point
		end_point = buffer
		buffer = start_range
		start_range = end_range
		end_range = buffer
	var x_split = _split([int(end_point.x - start_point.x)], 10)
	
	
	#Генерация вершин в пределах линий
	var border_1 = math_line.new([start_point[0],start_point[1] + start_range], 
	[end_point[0],end_point[1] + end_range])
	var border_2 = math_line.new([start_point[0],start_point[1] - start_range], 
	[end_point[0],end_point[1] - end_range])
	var tmp = start_point[0]-1
	var points = [start_point]
	for i in range(len(x_split)):
		tmp += x_split[i]
		var b1 = points[i][1] + x_split[i]
		var b2 = points[i][1] - x_split[i]
		b1 = min(b1,border_1.get_point(tmp))
		b2 = max(b2,border_2.get_point(tmp))
		points.append( Vector2(tmp, rng.randi_range(b2,b1)) )
	points[len(points)-1] = end_point
	
	
	#Создание дополнительных вершин
	var tmp_points = [points[0]]
	for i in range(1,len(points)-1):
		tmp_points.append(points[i])
		var max_y = max(points[i][1], points[i+1][1])
		var min_y = min(points[i][1], points[i+1][1])
		var d_y = abs( max_y - min_y)
		var d_x = abs(min(points[i][0], points[i+1][0]) - max(points[i][0], points[i+1][0]))
		#Выбираем случайную точку в пределах x и у двух ближащих точек
		#                   ___---0                              ___---0
		#        ___--о--‾‾‾               ==>         -o----‾‾‾‾
		#  0--‾‾‾                                  0--/ 
		tmp_points.append(Vector2(points[i][0] + int(d_x*rng.randf_range(0.35,0.65)), min_y + int(d_y*rng.randf_range(0.35,0.65))  ))
	tmp_points.append(points[len(points)-1])
	points = tmp_points.duplicate()
	
	#cглаживание
	var last_point = start_point
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
		var p
		#в общем порядке рисуем прямую от прошлой точки, принадлежащей
		#параболле к текущей
		for x in range(points[i-1][0],points[i][0]+1):
			p = Vector2(x,int( a*pow(x,2)+b*x+c ))
			draw_ray(last_point, p, radius, flip)
			last_point = p


#фигня для тестирования
func _on_Button_pressed():
	_test_use()


func _test_use():
	for point in tile_map.get_used_cells():
		tile_map.set_cell(point[0],point[1],-1)
	var tmp = [$start_x.value, $start_y.value, $end_x.value,$end_y.value, $range_start.value, $range_end.value]
	for i in 1:
		suboptimal_path(Vector2(tmp[0], tmp[1]), Vector2(tmp[2], tmp[3]))

#func _process(delta):
#
#	$start.position = Vector2($start_x.value, $start_y.value)
#	$end.position = Vector2($end_x.value,$end_y.value)
