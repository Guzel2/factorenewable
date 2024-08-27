extends Node2D

onready var parent = get_parent()

var type = 'headquarter'

var checked = false

var grid_size = 16

var inventory = {
	'scrap': 0,
	'wood': 0,
	'water': 0,
	'biomass': 0,
	'plastic': 0,
	'co2': 0,
}

var keys = inventory.keys()
var input_items = keys

var inventory_size = 30

var on_screen = false

func _ready():
	z_index = position.y / grid_size

func _process(_delta):
	for item in keys:
		if inventory[item] > 0:
			parent.player.update_ui(item, inventory[item], false)
			inventory[item] = 0

func check_neighbors():
	pass

func receive_item(item: String, item_amount: int, provider):
	inventory[item] += item_amount
	return true

func delete_this():
	parent.units[position.x/grid_size][position.y/grid_size] = null
	parent.units[position.x/grid_size + 1][position.y/grid_size] = null
	parent.units[position.x/grid_size][position.y/grid_size + 1] = null
	parent.units[position.x/grid_size + 1][position.y/grid_size + 1] = null
	parent.delete_this.append(self)
	
	check_this(position.x/grid_size, position.y/grid_size - 1) #up_left
	check_this(position.x/grid_size + 1, position.y/grid_size - 1) #up_right
	check_this(position.x/grid_size + 2, position.y/grid_size) #right_up
	check_this(position.x/grid_size + 2, position.y/grid_size + 1) #right_down
	check_this(position.x/grid_size + 1, position.y/grid_size + 2) #down_right
	check_this(position.x/grid_size, position.y/grid_size + 2) #down_left
	check_this(position.x/grid_size - 1, position.y/grid_size + 1) #left_down
	check_this(position.x/grid_size - 1, position.y/grid_size) #left_up

func check_this(x: int, y: int):
	if parent.units[x][y] != null:
		parent.units[x][y].check_neighbors()
