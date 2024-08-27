extends Node2D

onready var parent = get_parent()
onready var low_power_message = find_node('low_power_message')

var type = 'electric_pump'

var neighbors = []
var input_neighbors = []
var output_neighbors = []

var checked = false

var grid_size = 16

var production_time = 0
var production_timer = production_time
var production_per_tile = .25 #this amount gets produced per tile, per second

var power_consumption = .5
var is_powered = false

var inventory = {
	'water': 0,
}

var inventory_size = 30
var input_items = []

var on_screen = false

func _ready():
	z_index = position.y / grid_size
	
	var water_tiles = 0.0
	
	if parent.nature.get_cell(position.x/grid_size, position.y/grid_size) == parent.water_id:
		water_tiles += 1
	if parent.nature.get_cell(position.x/grid_size + 1, position.y/grid_size) == parent.water_id:
		water_tiles += 1
	if parent.nature.get_cell(position.x/grid_size, position.y/grid_size + 1) == parent.water_id:
		water_tiles += 1
	if parent.nature.get_cell(position.x/grid_size + 1, position.y/grid_size + 1) == parent.water_id:
		water_tiles += 1
	
	if water_tiles > 0:
		production_time = (1.0/production_per_tile)/water_tiles
		production_timer = production_time
	
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
	
	if inventory['water'] < inventory_size and production_time > 0 and is_powered:
		production_timer -= delta
		if production_timer <= 0:
			production_timer = production_time
			inventory['water'] += 1
	
	if inventory['water'] > 0:
		if output_neighbors.size() > 0:
			var searching_for_output = 0
			while searching_for_output < 8:
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
	var remove_this = null
	for unit in parent.power_consumer.size():
		if parent.power_consumer[unit] == self:
			remove_this = unit
	parent.power_consumer.remove(remove_this)
	
	parent.units[position.x/grid_size][position.y/grid_size] = null
	parent.units[position.x/grid_size + 1][position.y/grid_size] = null
	parent.units[position.x/grid_size][position.y/grid_size + 1] = null
	parent.units[position.x/grid_size + 1][position.y/grid_size + 1] = null
	parent.delete_this.append(self)
	
	for neighbor in neighbors:
		neighbor.check_neighbors()
