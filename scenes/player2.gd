extends CharacterBody2D

@export var speed: float = 200  # Movement speed
@export var score: int = 0
@onready var tilemap = $"../TileMapLayer"  # Adjust path if needed
@onready var crop_layer = $"../crops"
@onready var wall_layer = $"../walls"
@onready var opponent = $"../Player1"
@onready var score_label = $"../../UI/P2 Info/Score"
@onready var nav_agent := $Pathfinder as NavigationAgent2D

var crop_tile = Vector2i(9, 5)

func _ready():
	var initial_position = position
	if is_colliding_with_walls(initial_position):
		position = find_nearest_non_wall_tile(initial_position)
	makepath()

func _physics_process(delta):
	move_character(delta)
	place_crop()

func move_character(delta):
	var direction = Vector2.ZERO

	#if Input.is_action_pressed("p2_left"):
		#direction.x = -1
	#elif Input.is_action_pressed("p2_right"):
		#direction.x = 1
	#if Input.is_action_pressed("p2_up"):
		#direction.y = -1  
	#elif Input.is_action_pressed("p2_down"):
		#direction.y = 1  

	#direction = direction.normalized()
	
	direction = to_local(nav_agent.get_next_path_position()).normalized()
	
	velocity = direction * speed
	move_and_slide()
	
func makepath():
	var curr_tile = crop_layer.local_to_map(position)
	var best_tile = get_best_tile(get_adjacent_tile_data(curr_tile))
	
	nav_agent.target_position = crop_layer.to_global(crop_layer.map_to_local(best_tile))
	
func get_adjacent_tiles(tile_pos: Vector2i) -> Array:
	var neighbors = []
	#var directions = [
		#Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)
	#]
	
	var radius = 2
	var directions = []
	
	for i in range(-radius, radius + 1):
		for j in range(-radius, radius + 1):
			if i != 0 and j != 0:
				directions.append(Vector2i(i, j))
	
	randomize()
	directions.shuffle()
	
	for direction in directions:
		var neighbor_pos = tile_pos + direction
		neighbors.append(neighbor_pos)

	return neighbors
	
func get_adjacent_tile_data(tile_pos: Vector2i) -> Dictionary:
	var adjacent_tiles = get_adjacent_tiles(tile_pos)
	var data = {}

	for neighbor in adjacent_tiles:
		var tile_data = crop_layer.get_cell_tile_data(neighbor)
		if tile_data:
			data[neighbor] = tile_data.get_custom_data("environment")
		else:
			data[neighbor] = "empty"

	return data
	
func get_best_tile(tile_data: Dictionary):
	var best_tile := Vector2i(-1, -1)
	
	for tile in tile_data:
		var tile_info = wall_layer.get_cell_tile_data(tile) as TileData
		
		if best_tile == Vector2i(-1, -1):
			if tile_info and not tile_info.get_collision_polygons_count(0) > 0:
				best_tile = tile
		elif tile_data[tile] == "crop1":
			best_tile = tile
		elif tile_data[tile] == "empty" and tile_data[best_tile] == "crop2":
			if tile_info and not tile_info.get_collision_polygons_count(0) > 0:
				best_tile = tile
		#elif tile_data[tile] == "crop2":
			#best_tile = tile
				
	return best_tile
	
func _on_pathfinder_timer_timeout():
	makepath()
	
func _on_pathfinder_navigation_finished():
	makepath()

	
func place_crop():
	var tile_pos = crop_layer.local_to_map(position)
	update_score(tile_pos)
	crop_layer.set_cell(tile_pos, 1, crop_tile)  # Adjust tile ID as needed
	
func update_score(tile_pos: Vector2):
	var tile_data = crop_layer.get_cell_tile_data(tile_pos)
	
	if (!tile_data):
		score += 1
		return
		
	var crop = tile_data.get_custom_data("environment")
	
	if crop != "crop2":
		score += 1
	if crop == "crop1":
		opponent.score -= 1
		
	score_label.text = str(score)

func is_colliding_with_walls(target_position: Vector2) -> bool:
	if tilemap:
		var tile_pos = tilemap.local_to_map(target_position)
		var tile_data = tilemap.get_cell_tile_data(tile_pos)  # Layer 1 = "walls"
		
		return tile_data != null and tile_data.get_collision_polygons_count() > 0
	return false

func find_nearest_non_wall_tile(start_position: Vector2) -> Vector2:
	var directions = [
		Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1),
		Vector2(1, 1), Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1)
	]
	var queue = [start_position]
	var visited = {}
	visited[start_position] = true

	while queue.size() > 0:
		var current_position = queue.pop_front()
		for direction in directions:
			var new_position = current_position + direction * tilemap.cell_size
			if not visited.has(new_position):
				if not is_colliding_with_walls(new_position):
					return new_position
				queue.append(new_position)
				visited[new_position] = true
				
	return start_position
