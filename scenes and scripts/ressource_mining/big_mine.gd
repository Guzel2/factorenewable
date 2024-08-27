extends Node2D

onready var parent = get_parent()
onready var warning_message = find_node('warning_message')

var type = 'big_mine'

var neighbors = []
var input_neighbors = []
var output_neighbors = []

var checked = false

var grid_size = 16

var production_time = 0
var production_timer = production_time
var production_per_tile = .2 #this amount gets produced per tile, per second

var inventory = {
	'scrap': 0,
}

var inventory_size = 30
var input_items = []

var ressource_limit_per_tile = 100
var ressource_low_percentage = .75

var available_ressources = 0
var used_ressources = 0

var removed_tiles = false

var on_screen = false

func _ready():
	z_index = position.y / grid_size
	
	var city_tiles = 0.0
	
	if parent.nature.get_cell(position.x/grid_size, position.y/grid_size) == parent.city_id:
		city_tiles += 1
	if parent.nature.get_cell(position.x/grid_size + 1, position.y/grid_size) == parent.city_id:
		city_tiles += 1
	if parent.nature.get_cell(position.x/grid_size, position.y/grid_size + 1) == parent.city_id:
		city_tiles += 1
	if parent.nature.get_cell(position.x/grid_size + 1, position.y/grid_size + 1) == parent.city_id:
		city_tiles += 1
	
	if city_tiles > 0:
		production_time = (1.0/production_per_tile)/city_tiles
		production_timer = production_time
		
		available_ressources = ressource_limit_per_tile * city_tiles
	
	check_neighbors()

func check_neighbors():
	checked = true
	
	input_neighbors.clear()
	output_neighbors.clear()
	neighbors.clear()
	
	add_neighbor(0, Vector2(position.x/grid_size, position.y/grid_size - 1)) #up_left
	add_neighbor(0, Vector2(position.x/grid_size + 1, position.y/grid_size - 1)) #up_right
	add_neighbor(1, Vector2(position.x/grid_size + 2, position.y/grid_size)) #right_up
	add_neighbor(1, Vector2(position.x/grid_size + 2, position.y/grid_size + 1)) #right_down
	add_neighbor(2, Vector2(position.x/grid_size + 1, position.y/grid_size + 2)) #down_right
	add_neighbor(2, Vector2(position.x/grid_size, position.y/grid_size + 2)) #down_left
	add_neighbor(3, Vector2(position.x/grid_size - 1, position.y/grid_size + 1)) #left_down
	add_neighbor(3, Vector2(position.x/grid_size - 1, position.y/grid_size)) #left_up

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

func _process(delta):
	checked = false
	
	if inventory['scrap'] < inventory_size and production_time > 0:
		production_timer -= delta
		if production_timer <= 0:
			production_timer = production_time
			inventory['scrap'] += 1
			used_ressources += 1
			
			if used_ressources > float(available_ressources) * ressource_low_percentage:
				if !removed_tiles:
					parent.nature.set_cell(position.x/grid_size, position.y/grid_size, parent.dirt_id)
					parent.nature.set_cell(position.x/grid_size + 1, position.y/grid_size, parent.dirt_id)
					parent.nature.set_cell(position.x/grid_size, position.y/grid_size + 1, parent.dirt_id)
					parent.nature.set_cell(position.x/grid_size + 1, position.y/grid_size + 1, parent.dirt_id)
					parent.nature.update_bitmask_region(Vector2(position.x/grid_size, position.y/grid_size), Vector2(position.x/grid_size + 1, position.y/grid_size + 1))
					removed_tiles = true
					
					warning_message.set_warning_message('Unit is running low on ressources.')
				
				if used_ressources >= available_ressources:
					production_time = 0
					
					warning_message.set_warning_message("Unit has depleted all of it's ressources.")
	
	if inventory['scrap'] > 0:
		if output_neighbors.size() > 0:
			var searching_for_output = 0
			while searching_for_output < 8:
				var moved_item = output_neighbors[0].receive_item('scrap', 1, self)
				
				output_neighbors.append(output_neighbors.pop_front())
				
				if moved_item:
					inventory['scrap'] -= 1
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
