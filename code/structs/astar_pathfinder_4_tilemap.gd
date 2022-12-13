extends Reference
class_name AstarPathfinder

var ground_tile_map: TileMap
var astar: AStar2D

func _init(_ground_tile_map: TileMap):
	ground_tile_map = _ground_tile_map
	_init_astar(ground_tile_map)


func _init_astar(astar_tile_map: TileMap):
	astar = AStar2D.new()
	var TILE_ADJ = astar_tile_map.cell_size / 2 # Смещение к центру тайла
	var cells = astar_tile_map.get_used_cells()
	cells.sort() # Сортруем тайлы по X и Y координатам
	
	for i in range(cells.size()):
		var cell = cells[i]
		 # Регистрируем точку (Vector2) в центре тайла как узел Astar
		astar.add_point(i, astar_tile_map.map_to_world(cell) + TILE_ADJ)
		
		# Массив сосединх точек для соединения узлов Astar
		var neighbours = [ 
			Vector2(cell.x, cell.y - 1), # top cell
			Vector2(cell.x - 1, cell.y), # left cell
			Vector2(cell.x - 1, cell.y - 1), # top left cell
			Vector2(cell.x - 1, cell.y + 1), # top right cell
		]
		
		for neghbour in neighbours:
			if astar_tile_map.get_cellv(neghbour) == TileMap.INVALID_CELL:
				continue
			astar.connect_points(i, astar.get_closest_point(astar_tile_map.map_to_world(neghbour) + TILE_ADJ))


# Возвращает путь (массив точек) от точки до точки
func get_move_path(from: Vector2, to: Vector2) -> PoolVector2Array:
	return astar.get_point_path(
		astar.get_closest_point(from), 
		astar.get_closest_point(to)
		)


# Возвращает ближайшую точку в центре ячейки на сетке к переданной точке
func get_closest_grid_position(to: Vector2) -> Vector2:
	return astar.get_point_position(astar.get_closest_point(to))


# Возвращает массив всех соседних точек в определенном радиусе
func get_points_in_radius(point: Vector2, radius: int, diogonals = false) -> PoolVector2Array:
	var points = PoolVector2Array()
	var tile_map_cell = ground_tile_map.world_to_map(point)
	
	var opened_cells = Dictionary()
	var cells_to_open = [tile_map_cell]
	for i in range(radius):
		var new_candidates = Array()
		for open_candidate_i in range(cells_to_open.size()):
			var cell_to_open = cells_to_open.pop_back()
			if ground_tile_map.get_cellv(cell_to_open) == TileMap.INVALID_CELL or opened_cells.has(cell_to_open):
				continue
			var neighbour_cells = [
				Vector2(cell_to_open.x - 1, cell_to_open.y),
				Vector2(cell_to_open.x, cell_to_open.y - 1),
				Vector2(cell_to_open.x + 1, cell_to_open.y),
				Vector2(cell_to_open.x, cell_to_open.y + 1)
			]
			if diogonals:
				neighbour_cells.append_array([
					Vector2(cell_to_open.x + 1, cell_to_open.y - 1),
					Vector2(cell_to_open.x + 1, cell_to_open.y + 1 ),
					Vector2(cell_to_open.x - 1, cell_to_open.y - 1),
					Vector2(cell_to_open.x - 1, cell_to_open.y + 1 ),
				])
			new_candidates.append_array(neighbour_cells)
			opened_cells[cell_to_open] = true
			points.append(cell_to_open)
		cells_to_open = new_candidates
	return points



func are_equal_cell_points(a: Vector2, b: Vector2) -> bool:
	return ground_tile_map.world_to_map(a) == ground_tile_map.world_to_map(b)
