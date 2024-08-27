extends Node2D

onready var parent = get_parent()

var type = 'forester'

var neighbors = []
var output_neighbors = []

var checked = false

var grid_size = 16

var production_time = 0
var production_timer = production_time

var tree_time = 5
var tree_timer = tree_time

var inventory = {
	'wood': 0,
	'water': 0,
}

var inventory_size = 10
var input_items = ['water']

var forest_range = 2
var production_per_tile = .1

var on_screen = false

func _ready():
	z_index = position.y / grid_size
	
	check_nature()
	check_neighbors()

func check_neighbors():
	checked = true
	
	neighbors.clear()
	output_neighbors.clear()
	
	add_neighbor(0, Vector2(position.x/parent.grid_size, position.y/parent.grid_size - 1)) #up
	add_neighbor(1, Vector2(position.x/parent.grid_size + 1, position.y/parent.grid_size)) #right
	add_neighbor(2, Vector2(position.x/parent.grid_size, position.y/parent.grid_size + 1)) #down
	add_neighbor(3, Vector2(position.x/parent.grid_size - 1, position.y/parent.grid_size)) #left
	
	check_nature()

func add_neighbor(side, pos): #side is the side you are checking for (for example if items get put on the conveyor from the left, if it's facging right
	if parent.units[pos.x][pos.y] != null:
		var neighbor = parent.units[pos.x][pos.y]
		neighbors.append(neighbor)
		
		if "conveyor" in neighbor.type:
			if (side + 2) % 4 != neighbor.dir:
				output_neighbors.append(neighbor)
		elif "router" in neighbor.type:
			if neighbor.dir == side:
				output_neighbors.append(neighbor)
		else:
			output_neighbors.append(neighbor)
		
		if neighbor.checked == false:
			neighbor.check_neighbors()

func check_nature():
	var start_pos = Vector2(-forest_range, -forest_range)
	var x = start_pos.x
	
	var tree_tiles = 0
	
	while x <= forest_range:
		var y = start_pos.y
		while y <= forest_range:
			if abs(x) + abs(y) <= forest_range:
				if parent.nature.get_cell(x + position.x/grid_size, y + position.y/grid_size) == parent.tree_id:
					tree_tiles += 1
					
				#if !(x == 0 and y == 0):
				#	parent.spawn_conveyor(0, Vector2(x + position.x/grid_size, y + position.y/grid_size))
			
			y += 1
		x += 1
	
	if tree_tiles > 0:
		production_time = (1.0/production_per_tile)/tree_tiles
		production_timer = production_time
	
	
	#var unit_tiles = 0 #reduce production depending on how many adjacent factories
	
	#while x <= forest_range:
	#	var y = start_pos.y
	#	while y <= forest_range:
	#		if abs(x) + abs(y) <= forest_range:
	#			if parent.units[x][y] != null and !('conv' in parent.units[x][y].name):
	#				unit_tiles += 1
	
	#production_time *= pow(2, unit_tiles) 

func plant_tree():
	var possible_tiles = []
	
	var start_pos = Vector2(-forest_range, -forest_range)
	var x = start_pos.x
	
	while x <= forest_range:
		var y = start_pos.y
		while y <= forest_range:
			if abs(x) + abs(y) <= forest_range:
				if parent.units[x + position.x/grid_size][y + position.y/grid_size] == null:
					if parent.nature.get_cell(x + position.x/grid_size, y + position.y/grid_size) == parent.dirt_id:
						possible_tiles.append(Vector2(x + position.x/grid_size, y + position.y/grid_size))
			
			y += 1
		x += 1
	
	if possible_tiles.size() > 0:
		possible_tiles.shuffle()
		parent.spawn_tree(possible_tiles[0])
		return true
	else:
		return false

func _process(delta):
	checked = false
	
	if inventory['wood'] < inventory_size and production_time > 0:
		production_timer -= delta
		if production_timer <= 0:
			production_timer = production_time
			inventory['wood'] += 1
	
	if inventory['wood'] > 0:
		if output_neighbors.size() > 0:
			var searching_for_output = 0
			while searching_for_output < 4:
				var moved_item = output_neighbors[0].receive_item('wood', 1, self)
				
				output_neighbors.append(output_neighbors.pop_front())
				
				if moved_item:
					inventory['wood'] -= 1
					break
				else:
					searching_for_output += 1
	
	if production_timer > 0:
		if inventory['water'] == inventory_size:
			tree_timer -= delta
			
			if tree_timer <= 0:
				tree_timer = tree_time
				if plant_tree():
					inventory['water'] = 0

func receive_item(item: String, item_amount: int, provider):
	if item in input_items:
		if inventory[item] + item_amount <= inventory_size:
			inventory[item] += item_amount
			return true
		return false

func delete_this():
	parent.units[position.x/grid_size][position.y/grid_size] = null
	parent.delete_this.append(self)
	
	for neighbor in neighbors:
		neighbor.check_neighbors()


func _on_area_mouse_entered():
	pass
	#print(production_time)
