extends Node2D

onready var parent = get_parent()
onready var sprites = [$top, $bot]
onready var x_ressource = $bot_ressource
onready var y_ressource = $top_ressource

var type = 'plastic_junction'

var neighbors = []

var x_input = []
var x_output = []

var y_input = []
var y_output = []

var current_x_item = null
var current_y_item = null

var x_inventory = 0
var y_inventory = 0
var inventory_size = 1

var input_items = ['scrap', 'wood', 'water', 'biomass', 'plastic', 'co2']

var input_dirs = []

var grid_size = 16

var cooldown = .15
var x_cooltimer = cooldown
var y_cooltimer = cooldown

var checked = false

var on_screen = false

var x_item_received_from = null
var y_item_received_from = null

func _ready():
	z_index = position.y / grid_size
	
	get_spawned()

func get_spawned():
	check_neighbors()

func check_neighbors():
	checked = true
	
	for sprite in sprites:
		sprite.frame = parent.cursor.frame % 2
	
	neighbors.clear()
	x_input.clear()
	x_output.clear()
	y_input.clear()
	y_output.clear()
	
	add_neighbor(0, Vector2(position.x/parent.grid_size, position.y/parent.grid_size - 1)) #up
	add_neighbor(1, Vector2(position.x/parent.grid_size + 1, position.y/parent.grid_size)) #right
	add_neighbor(2, Vector2(position.x/parent.grid_size, position.y/parent.grid_size + 1)) #down
	add_neighbor(3, Vector2(position.x/parent.grid_size - 1, position.y/parent.grid_size)) #left

func add_neighbor(side, pos): #side is the side you are checking for (for example if items get put on the conveyor from the left, if it's facging right
	if parent.units[pos.x][pos.y] != null:
		var neighbor = parent.units[pos.x][pos.y]
		neighbors.append(neighbor)
		
		if 'junction' in neighbor.type:
			if side % 2 == 0:
				if neighbor.y_input.size() > 0 and y_input.size() == 0:
					y_input.append(neighbor)
				elif neighbor.y_output.size() > 0 and y_output.size() == 0:
					y_output.append(neighbor)
				else:
					pass
			else:
				if neighbor.x_input.size() > 0 and x_input.size() == 0:
					x_input.append(neighbor)
				elif neighbor.x_output.size() > 0 and x_output.size() == 0:
					x_output.append(neighbor)
				else:
					pass
		else:
			if side % 2 == 0: #y direction
				add_neighbor_to_list(neighbor, y_input, y_output, side)
			else: #x direction
				add_neighbor_to_list(neighbor, x_input, x_output, side)
		
		if neighbor.checked == false:
			neighbor.check_neighbors()

func add_neighbor_to_list(neighbor, input, output, side):
	if "conveyor" in neighbor.type:
		if (side + 2) % 4 == neighbor.dir:
			input.append(neighbor)
		else:
			output.append(neighbor)
	elif "router" in neighbor.type:
		if side != neighbor.dir:
			input.append(neighbor)
		else:
			output.append(neighbor)
	else: #if it's a factory
		input.append(neighbor)

func _process(delta):
	display_item(x_ressource, x_cooltimer, x_item_received_from)
	display_item(y_ressource, y_cooltimer, y_item_received_from)
	
	
	checked = false
	
	
	var x_stuff = move_item(x_inventory, current_x_item, x_output, x_cooltimer, delta)
	
	x_cooltimer = x_stuff[0]
	if x_stuff[1]:
		x_inventory = 0
		current_x_item = null
		update()
	
	
	var y_stuff = move_item(y_inventory, current_y_item, y_output, y_cooltimer, delta)
	
	y_cooltimer = y_stuff[0]
	if y_stuff[1]:
		y_inventory = 0
		current_y_item = null
		
		update()

func display_item(ressource, cooltimer, item_received_from):
	if on_screen:
		if cooltimer <= cooldown:
			if item_received_from != null:
				if cooltimer <= 0:
					ressource.position = Vector2(0, 0)
				else:
					var normalizer = 1.0 / cooldown
					ressource.position = (item_received_from * cooltimer * normalizer)

func move_item(inventory, current_item, output, cooltimer, delta):
	var moved_item = false
	
	if inventory > 0:
		cooltimer -= delta
		if output.size() == 1:
			
			if cooltimer <= 0:
				moved_item = output[0].receive_item(current_item, 1, self)
				if moved_item:
					cooltimer = cooldown
	return [cooltimer, moved_item]

func update():
	if current_x_item == null:
		x_ressource.visible = false
	else:
		x_ressource.animation = current_x_item
		x_ressource.visible = true
	
	if current_y_item == null:
		y_ressource.visible = false
	else:
		y_ressource.animation = current_y_item
		y_ressource.visible = true

func receive_item(item: String, item_amount: int, provider):
	if provider in x_input:
		if item in input_items:
			if x_inventory > 0:
				return false
			
			x_inventory += item_amount
			current_x_item = item
			update()
			
			if provider.type in parent.conveyors:
				x_item_received_from = provider.position - position
				x_ressource.position = x_item_received_from
			else:
				x_item_received_from = null
			
			return true
	
	elif provider in y_input:
		if item in input_items:
			if y_inventory > 0:
				return false
			
			y_inventory += item_amount
			current_y_item = item
			update()
			
			if provider.type in parent.conveyors:
				y_item_received_from = provider.position - position
				y_ressource.position = y_item_received_from
			else:
				y_item_received_from = null
			
			return true

func remove_this():
	parent.units[position.x/grid_size][position.y/grid_size] = null
	queue_free()

func delete_this():
	parent.units[position.x/grid_size][position.y/grid_size] = null
	parent.delete_this.append(self)
	
	for neighbor in neighbors:
		neighbor.check_neighbors()
