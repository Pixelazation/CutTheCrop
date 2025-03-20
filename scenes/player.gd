extends CharacterBody2D

@export var speed: float = 200  # Movement speed
@onready var tilemap = $"../TileMapLayer"  # Adjust path if needed

func _process(delta):
	move_character(delta)

func move_character(delta):
	var direction = Vector2.ZERO

	if Input.is_action_pressed("ui_left"):
		direction.x = -1
	elif Input.is_action_pressed("ui_right"):
		direction.x = 1
	if Input.is_action_pressed("ui_up"):
		direction.y = -1  
	elif Input.is_action_pressed("ui_down"):
		direction.y = 1  

	direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()


func is_colliding_with_walls(target_position: Vector2) -> bool:
	if tilemap:
		var tile_pos = tilemap.local_to_map(target_position)
		var tile_data = tilemap.get_cell_tile_data(1, tile_pos)  # Layer 1 = "walls"
		
		return tile_data != null and tile_data.get_collision_polygons_count() > 0
	return false
