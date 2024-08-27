extends Node2D

onready var parent = get_parent()

var type = 'bio_air_booster'

var neighbors = []
var input_neighbors = []
var output_neighbors = []

var checked = false

var grid_size = 16

var production_time = 2
var production_timer = production_time

var co2_removal = 0
var potential_co2_removal = 2.0

var inventory = {
	'biomass': 0,
	'co2': 0,
}

var input_items = ['biomass', 'co2']

var inventory_size = 40

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
	
	if production_timer <= 0:
		if inventory['biomass'] > 0 and inventory['co2'] > 1:
			production_timer = production_time
			inventory['biomass'] -= 1
			inventory['co2'] -= 2
			co2_removal = potential_co2_removal
		else:
			co2_removal = 0
	else: #this unit is active
		production_timer -= delta

func receive_item(item: String, item_amount: int, provider):
	if item in input_items:
		if inventory[item] + item_amount <= inventory_size:
			inventory[item] += item_amount
			return true
		return false

func delete_this():
	var remove_this = null
	for unit in parent.co2_changers.size():
		if parent.co2_changers[unit] == self:
			remove_this = unit
	parent.co2_changers.remove(remove_this)
	
	parent.units[position.x/grid_size][position.y/grid_size] = null
	parent.units[position.x/grid_size + 1][position.y/grid_size] = null
	parent.units[position.x/grid_size][position.y/grid_size + 1] = null
	parent.units[position.x/grid_size + 1][position.y/grid_size + 1] = null
	parent.delete_this.append(self)
	
	for neighbor in neighbors:
		neighbor.check_neighbors()
	
