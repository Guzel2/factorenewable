extends Node2D

onready var parent = get_parent()
onready var warning_message = find_node('warning_message')

var type = 'pump'

var neighbors = []
var input_neighbors = []
var output_neighbors = []

var checked = false

var grid_size = 16

var production_time = 0
var production_timer = production_time
var production_per_tile = .2

var inventory = {
	'water': 0,
}

var inventory_size = 10
var input_items = []

var ressource_limit_per_tile = 50
var ressource_low_percentage = .75

var available_ressources = 0
var used_ressources = 0

var removed_tiles = false

var on_screen = false

func _ready():
	z_index = position.y / grid_size
	
	var water_tiles = 0
	
	if parent.nature.get_cell(position.x/grid_size, position.y/grid_size) == parent.water_id:
		water_tiles += 1
	
	if water_tiles > 0:
		production_time = (1.0/production_per_tile)/water_tiles
		production_timer = production_time
		
		available_ressources = ressource_limit_per_tile * water_tiles
	
	check_neighbors()

func check_neighbors():
	checked = true
	
	neighbors.clear()
	input_neighbors.clear()
	output_neighbors.clear()
	
	add_neighbor(0, Vector2(position.x/parent.grid_size, position.y/parent.grid_size - 1)) #up
	add_neighbor(1, Vector2(position.x/parent.grid_size + 1, position.y/parent.grid_size)) #right
	add_neighbor(2, Vector2(position.x/parent.grid_size, position.y/parent.grid_size + 1)) #down
	add_neighbor(3, Vector2(position.x/parent.grid_size - 1, position.y/parent.grid_size)) #left

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
	
	if inventory['water'] < inventory_size and production_time > 0:
		production_timer -= delta
		if production_timer <= 0:
			production_timer = production_time
			inventory['water'] += 1
			used_ressources += 1
			
			if used_ressources > float(available_ressources) * ressource_low_percentage:
				if !removed_tiles:
					parent.nature.set_cell(position.x/grid_size, position.y/grid_size, parent.dirt_id)
					parent.nature.update_bitmask_region(Vector2(position.x/grid_size, position.y/grid_size))
					removed_tiles = true
					
					warning_message.set_warning_message('Unit is running low on ressources.')
				
				if used_ressources >= available_ressources:
					production_time = 0
					
					warning_message.set_warning_message("Unit has depleted all of it's ressources.")
	
	if inventory['water'] > 0:
		if output_neighbors.size() > 0:
			var searching_for_output = 0
			while searching_for_output < 4:
				var moved_item = output_neighbors[0].receive_item('water', 1, self)
				
				output_neighbors.append(output_neighbors.pop_front())
				
				if moved_item:
					inventory['water'] -= 1
					break
				else:
					searching_for_output += 1

func receive_item(item: String, item_amount: int, provider):
	return false

func delete_this():
	parent.units[position.x/grid_size][position.y/grid_size] = null
	parent.delete_this.append(self)
	
	for neighbor in neighbors:
		neighbor.check_neighbors()
	
