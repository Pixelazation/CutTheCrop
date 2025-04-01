extends TileMapLayer

class_name MazeGen

##2D vector using integer coordinates
##Stores starting position
var starting_pos = Vector2i()
##The layer being modified
const main_layer = 0
##tile coordinates for walls
const path_atlas_coords = Vector2i(0, 0)
const normal_wall_atlas_coords = Vector2i(3, 3)
##const walkable_atlas_coords = Vector2i(0, 0)
##tile source id for placing tiles
const SOURCE_ID = 1

##mazes dimensions
var y_dim = Globals.grid_size
var x_dim = Globals.grid_size

##starting position of the maze
@export var starting_coords = Vector2i(0, 0)

var adj4 = [
	Vector2i(-1, 0),
	Vector2i(1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1),
]

func _ready() -> void:
	##Globals.letters_to_show.clear()
	place_walk()
	place_border()
	dfs(starting_coords)
	
func place_walk():
	var grid_size = Globals.grid_size+1  # Get the grid size from the global script
	for x in range(grid_size):
		for y in range(grid_size):
			set_cell(Vector2i(x,y), SOURCE_ID, path_atlas_coords)  # Adjust 0 to the correct tile ID/index
	
func place_border():
	for y in range(-1, y_dim):
		place_wall(Vector2(-1, y))
	for x in range(-1, x_dim):
		place_wall(Vector2(x, -1))
	for y in range(-1, y_dim + 1):
		place_wall(Vector2(x_dim, y))
	for x in range(-1, x_dim + 1):
		place_wall(Vector2(x, y_dim))

##unlike TileMap (deprecated), we don't use layers for set_cell
		
func delete_cell_at(pos: Vector2):
	set_cell(pos, SOURCE_ID, path_atlas_coords)

func place_wall(pos: Vector2):
	set_cell(pos, SOURCE_ID, normal_wall_atlas_coords)

func will_be_converted_to_wall(spot: Vector2i):
	return (spot.x % 2 == 1 and spot.y % 2 == 1)	
	
func is_wall(pos):
	return get_cell_atlas_coords(pos) in [
		normal_wall_atlas_coords
	]

func can_move_to(current: Vector2i):
	return (
			current.x >= 0 and current.y >= 0 and\
			current.x < x_dim and current.y < y_dim and\
			not is_wall(current)
	)
	
func dfs(start: Vector2i):
	var fringe: Array[Vector2i] = [start]
	var seen = {}
	while fringe.size() > 0:
		var current: Vector2i 
		
		current = fringe.pop_back() as Vector2i

		if current in seen or not can_move_to(current):
			continue
		
		seen[current] = true
		
		if current.x % 2 == 1 and current.y % 2 == 1:
			place_wall(current)
			continue
			
		##set_cell(current, SOURCE_ID, walkable_atlas_coords)
		
		var found_new_path = false
		adj4.shuffle()
		for pos in adj4:
			var new_pos = current + pos
			if new_pos not in seen and can_move_to(new_pos):
				##why is this from 1 to 1?
				var chance_of_no_loop = randf_range(0, 1)
				
				if will_be_converted_to_wall(new_pos) and chance_of_no_loop <= 0.1:
					place_wall(new_pos)
				else:
					found_new_path = true
					fringe.append(new_pos)
					
		#if we hit a dead end or are at a cross section
		if not found_new_path:
			place_wall(current)
