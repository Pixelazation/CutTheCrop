extends CharacterBody2D

@export var speed: float = 200  # Movement speed
@export var score: int = 0
@onready var tilemap = $".."  # Adjust path if needed
@onready var crop_layer = $"../crops"
@onready var opponent = $"../Player2"
@onready var score_label = $"../../UI/P1 Info/Score"

var crop_tile = Vector2i(11, 1)

func _ready():
	var initial_position = position
	if is_colliding_with_walls(initial_position):
		position = find_nearest_non_wall_tile(initial_position)

func _process(delta):
	move_character(delta)
	place_crop()

func move_character(delta):
	var direction = Vector2.ZERO

	if Input.is_action_pressed("p1_left"):
		direction.x = -1
	elif Input.is_action_pressed("p1_right"):
		direction.x = 1
	if Input.is_action_pressed("p1_up"):
		direction.y = -1  
	elif Input.is_action_pressed("p1_down"):
		direction.y = 1  

	direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()
	
func place_crop():
	var tile_pos = crop_layer.local_to_map(position)
	update_score(tile_pos)
	crop_layer.set_cell(tile_pos, 1, crop_tile)  # Adjust tile ID as needed

func update_score(tile_pos: Vector2):
	var tile_data = crop_layer.get_cell_tile_data(tile_pos)
	
	if (!tile_data):
		score += 1
		Globals.player1_score+=1
		return
		
	var crop = tile_data.get_custom_data("environment")
	
	if crop != "crop1":
		score += 1
		Globals.player1_score+=1
	if crop == "crop2":
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
