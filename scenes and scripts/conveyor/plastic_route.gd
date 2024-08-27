extends Node2D

onready var parent = get_parent()
onready var sprite = $sprite
onready var ressource = $ressource

var type = 'plastic_router'

var neighbors = []
var input_neighbors = [] #the units that load onto this conveyor
var output_neighbors = [] #the units that receive from this conveyor

var current_item = null
var inventory = 0
var inventory_size = 1

var input_items = ['scrap', 'wood', 'water', 'biomass', 'plastic', 'co2']

var dir = 0 #0 is up, 1 is right, 2 is down, 3 is left
var input_dir
var output_dirs = []

var grid_size = 16

var cooldown = .15
var cooltimer = cooldown

var checked = false

var on_screen = false

var item_received_from = null

func _ready():
	z_index = position.y / grid_size
	
	get_spawned()

func get_spawned():
	input_dir = (dir + 2) % 4
	
	#rotation
	if dir == 0:
		output_dirs = [0, 1, 3]
	elif dir == 1:
		sprite.position = Vector2(grid_size, 0)
		output_dirs = [0, 1, 2]
	elif dir == 2:
		output_dirs = [1, 2, 3]
		sprite.position = Vector2(grid_size, grid_size)
	else:
		output_dirs = [0, 2, 3]
		sprite.position = Vector2(0, grid_size)
	
	sprite.rotation_degrees = 90*dir
	
	check_neighbors()

func check_neighbors():
	checked = true
	
	sprite.frame = parent.cursor.frame
	
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
		
		if (dir + 2) % 4 == side:
			input_neighbors.append(neighbor)
		else:
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

func _process(delta):
	if on_screen:
		if cooltimer != cooldown:
			if item_received_from != null:
				if cooltimer <= 0:
					ressource.position = Vector2(0, 0)
				else:
					var normalizer = 1.0 / cooldown
					ressource.position = (item_received_from * cooltimer * normalizer)
	
	checked = false
	
	if inventory > 0: 
		cooltimer -= delta
		if cooltimer <= 0:
			if output_neighbors.size() > 0:
				var searching_for_output = 0
				while searching_for_output < 3:
					
					var moved_item = output_neighbors[0].receive_item(current_item, 1, self)
					
					output_neighbors.append(output_neighbors.pop_front())
					
					if moved_item:
						inventory -= 1
						current_item = null
						update()
						cooltimer = cooldown
						break
					else:
						searching_for_output += 1

func update():
	if current_item == null:
		ressource.visible = false
	else:
		ressource.animation = current_item
		ressource.visible = true

func receive_item(item: String, item_amount: int, provider):
	if provider in input_neighbors:
		if item in input_items:
			if inventory > 0:
				return false
			
			inventory += item_amount
			current_item = item
			update()
			
			if provider.type in parent.conveyors:
				item_received_from = provider.position - position
				ressource.position = item_received_from
				
				if 'junction' in provider.type:
					if item_received_from.y != 0:
						ressource.z_index = 20
					else:
						ressource.z_index = 10
				
			else:
				item_received_from = null
			
			return true

func remove_this():
	parent.units[position.x/grid_size][position.y/grid_size] = null
	parent.delete_this.append(self)

func delete_this():
	parent.units[position.x/grid_size][position.y/grid_size] = null
	parent.delete_this.append(self)
	
	for neighbor in neighbors:
		neighbor.check_neighbors()
