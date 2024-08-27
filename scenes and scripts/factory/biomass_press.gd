extends Node2D

onready var parent = get_parent()

var type = 'biomass_press'

var neighbors = []
var input_neighbors = []
var output_neighbors = []

var checked = false

var grid_size = 16

var production_time = .75
var production_timer = production_time

var inventory = {
	'wood': 0,
	'water': 0,
	'biomass': 0,
}

var input_items = ['wood', 'water']

var inventory_size = 30

var on_screen = false

func _ready():
	z_index = position.y / grid_size
	
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
	
	if inventory['wood'] > 1 and inventory['water'] > 0 and inventory['biomass'] < inventory_size:
		production_timer -= delta
		if production_timer <= 0:
			production_timer = production_time
			inventory['biomass'] += 2
			inventory['wood'] -= 2
			inventory['water'] -= 1
	
	if inventory['biomass'] > 0:
		if output_neighbors.size() > 0:
			var searching_for_output = 0
			while searching_for_output < 8:
				var moved_item = output_neighbors[0].receive_item('biomass', 1, self)
				
				output_neighbors.append(output_neighbors.pop_front())
				
				if moved_item:
					inventory['biomass'] -= 1
					break
				else:
					searching_for_output += 1

func receive_item(item: String, item_amount: int, provider):
	if item in input_items:
		if inventory[item] + item_amount <= inventory_size:
			inventory[item] += item_amount
			return true
		return false

func delete_this():
	parent.units[position.x/grid_size][position.y/grid_size] = null
	parent.units[position.x/grid_size + 1][position.y/grid_size] = null
	parent.units[position.x/grid_size][position.y/grid_size + 1] = null
	parent.units[position.x/grid_size + 1][position.y/grid_size + 1] = null
	parent.delete_this.append(self)
	
	for neighbor in neighbors:
		neighbor.check_neighbors()
	
