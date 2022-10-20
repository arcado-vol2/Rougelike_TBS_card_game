extends Node


static func find_mst(coord):
	#Prim's algorithm
	var path=AStar2D.new()
	path.add_point(path.get_available_point_id(),coord.pop_front())
	while coord: #Repeat until there're no disconnected rooms
		var min_dist= INF 
		var min_p=null
		var p=null #current node position
		for p1 in path.get_points():
			p1=path.get_point_position(p1)
			for p2 in coord:
				if p1.distance_to(p2) < min_dist:
					min_dist=p1.distance_to(p2)
					min_p=p2
					p=p1
		var id = path.get_available_point_id()
		path.add_point(id, min_p)
		path.connect_points(path.get_closest_point(p),id)
		coord.erase(min_p)
	return path

static func drawCorridors(buildingFuncRef,path,rooms):
	var corridors =[]
	for room in rooms.get_children():
		var p = path.get_closest_point(room.mapPosition)
		for connection in path.get_point_connections(p):
			if not connection in corridors:
				var start = path.get_point_position(p)
				var end = path.get_point_position(connection)
				buildingFuncRef.call_func(start,end)
			corridors.append(p)

func _ready():
	pass 


