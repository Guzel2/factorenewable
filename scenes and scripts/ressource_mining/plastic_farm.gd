extends Node2D

onready var parent = get_parent()
onready var sprite = find_node('sprite')

var type = 'plastic_farm'

var neighbors = []
var input_neighbors = []
var output_neighbors = []

var checked = false

var grid_size = 16

var production_time = 0
var production_timer = production_time

var inventory = {
	'plastic': 0,
}

var dir = 0

var inventory_size = 10
var input_items = []

var plastic_range = 3
var production_per_tile = .05

var on_screen = false

func _ready():
	z_index = position.y / grid_size
	
	sprite.frame = dir
	
	check_nature()
	check_neighbors()

func check_neighbors():
	checked = true
	
	neighbors.clear()
	input_neighbors.clear()
	output_neighbors.clear()
	
	add_neighbor(0, Vector2(position.x/grid_size, position.y/grid_size - 1)) #up_left
	add_neighbor(0, Vector2(position.x/grid_size + 1, position.y/grid_size - 1)) #up_right
	add_neighbor(1, Vector2(position.x/grid_size + 2, position.y/grid_size)) #right_up
	add_neighbor(1, Vector2(position.x/grid_size + 2, position.y/grid_size + 1)) #right_down
	add_neighbor(2, Vector2(position.x/grid_size + 1, position.y/grid_size + 2)) #down_right
	add_neighbor(2, Vector2(position.x/grid_size, position.y/grid_size + 2)) #down_left
	add_neighbor(3, Vector2(position.x/grid_size - 1, position.y/grid_size + 1)) #left_down
	add_neighbor(3, Vector2(position.x/grid_size - 1, position.y/grid_size)) #left_up
	
	check_nature()

func add_neighbor(side, pos): #side is the side you are checking for (for example if items get put on the conveyor from the left, if it's facging right
	if parent.units[pos.x][pos.y] != null:
		var neighbor = parent.units[pos.x][pos.y]
		neighbors.append(neighbor)
		
		if "conveyor" in neighbor.name:
			if (side + 2) % 4 != neighbor.dir:
				output_neighbors.append(neighbor)
		elif "router" in neighbor.name:
			if neighbor.dir == side:
				output_neighbors.append(neighbor)
		else:
			output_neighbors.append(neighbor)
		
		if neighbor.checked == false:
			neighbor.check_neighbors()

func check_nature():
	var water_tiles = 0
	
	var tiles_to_check = []
	
	var dir_vector
	
	match dir:
		0:
			dir_vector = Vector2.UP
		1:
			dir_vector = Vector2.RIGHT
		2:
			dir_vector = Vector2.DOWN
		3:
			dir_vector = Vector2.LEFT
	
	var start_pos_1 = Vector2(0, 0)
	var start_pos_2 = Vector2(0, 0)
	
	match dir:
		0:
			start_pos_1 = Vector2(0, 0)
			start_pos_2 = Vector2(1, 0)
		1:
			start_pos_1 = Vector2(1, 0)
			start_pos_2 = Vector2(1, 1)
		2:
			start_pos_1 = Vector2(1, 1)
			start_pos_2 = Vector2(0, 1)
		3:
			start_pos_1 = Vector2(0, 0)
			start_pos_2 = Vector2(0, 1)
	
	for x in plastic_range:
		tiles_to_check.append(start_pos_1 + x*dir_vector)
		tiles_to_check.append(start_pos_2 + x*dir_vector)
	
	while !tiles_to_check.empty():
		var tile = tiles_to_check.pop_front()
		
		if parent.nature.get_cell(tile.x + position.x/grid_size, tile.y + position.y/grid_size) == parent.water_id:
			water_tiles += 1
	
	if water_tiles > 0:
		production_time = (1.0/production_per_tile)/water_tiles
		production_timer = production_time
	
	#var unit_tiles = 0 #reduce production depending on how many adjacent factories
	
	#while x <= forest_range:
	#	var y = start_pos.y
	#	while y <= forest_range:
	#		if abs(x) + abs(y) <= forest_range:
	#			if parent.units[x][y] != null and !('conv' in parent.units[x][y].name):
	#				unit_tiles += 1
	
	#production_time *= pow(2, unit_tiles) 

func _process(delta):
	checked = false
	
	if inventory['plastic'] < inventory_size and production_time > 0:
		production_timer -= delta
		if production_timer <= 0:
			production_timer = production_time
			inventory['plastic'] += 1
	
	if inventory['plastic'] > 0:
		if output_neighbors.size() > 0:
			var searching_for_output = 0
			while searching_for_output < 8:
				var moved_item = output_neighbors[0].receive_item('plastic', 1, self)
				
				output_neighbors.append(output_neighbors.pop_front())
				
				if moved_item:
					inventory['plastic'] -= 1
					break
				else:
					searching_for_output += 1

func receive_item(item: String, item_amount: int, provider):
	return false

func delete_this():
	parent.units[position.x/grid_size][position.y/grid_size] = null
	parent.units[position.x/grid_size + 1][position.y/grid_size] = null
	parent.units[position.x/grid_size][position.y/grid_size + 1] = null
	parent.units[position.x/grid_size + 1][position.y/grid_size + 1] = null
	parent.delete_this.append(self)
	
	for neighbor in neighbors:
		neighbor.check_neighbors()


func _on_area_mouse_entered():
	pass
	#print(production_time)
