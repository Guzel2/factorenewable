extends Node2D

onready var parent = get_parent()
onready var cursor = find_node('cursor')
onready var nature = find_node('nature')
onready var player = find_node('player')

onready var needs_tile_text = find_node('needs_tile_text')

var hq = null

var mouse_in_ui = false
var deleted_something = false
var delete_this = []
var units_deleted = 0
var unit_delete_cap = 25

var grid_size = 16

var units = []
var map_size_x = 100
var map_size_y = 100

var dirt_id = 0
var city_id = 1
var tree_id = 2
var mountain_id = 3
var water_id = 4

var mouse_dir = 0

var unit_to_place = null

var player_dir = Vector2(0, 0)
var player_friction = .9

var tree_count = 0
var unit_cost = {
	'conveyor': {
		'scrap': 2
	},
	'conv_junction': {
		'scrap': 3
	},
	'conv_router': {
		'scrap': 3
	},
	'plastic_conveyor': {
		'scrap': 1,
		'plastic': 1
	},
	'plastic_junction': {
		'scrap': 2,
		'plastic': 2
	},
	'plastic_router': {
		'scrap': 2,
		'plastic': 2
	},
	'big_mine': {
		'scrap': 35
	},
	'forester': {
		'scrap': 20
	},
	'pump': {
		'scrap': 10,
		'wood': 15
	},
	'biomass_press': {
		'scrap': 15,
		'wood': 20,
	},
	'plastic_farm': {
		'scrap': 25,
		'water': 10,
	},
	'bio_generator': {
		'scrap': 60,
		'wood': 20,
		'water': 5,
	},
	'solar_panel': {
		'scrap': 30,
		'wood': 25,
		'water': 40,
		'plastic': 50,
	},
	'electric_pump': {
		'scrap': 10,
		'wood': 30,
		'plastic': 15
	},
	'co2_collector': {
		'scrap': 20,
		'plastic': 30
	},
	'bio_air_booster': {
		'scrap': 15,
		'water': 30
	}
}

var unit_names
var conveyors = ['conveyor', 'conv_router', 'conv_junction', 'plastic_conveyor', 'plastic_router', 'plastic_junction']
var big_units = ['big_mine', 'biomass_press', 'plastic_farm', 'bio_generator', 'solar_panel', 'electric_pump', 'co2_collector', 'bio_air_booster']
var rotate_units = ['conveyor', 'conv_router', 'plastic_conveyor', 'plastic_router', 'plastic_farm']
var no_output_units = ['bio_generator', 'solar_panel', 'bio_air_booster']

var level

var save_path = "user://save"
var auto_save_time = 60.0
var auto_save_timer = auto_save_time


var total_co2_removed = 0
var average_co2_removal = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var co2_changers = []

var co2_time = 1.0
var co2_timer = 0.0

var co2_remove_per_tree = 0.005

var power_producers = []
var power_consumer = []
var average_power = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var current_average_power = 0

var power_time = 1.0
var power_timer = 0.0

#var noise = OpenSimplexNoise.new()

#func _ready():
#	noise.seed = 0
#	noise.octaves = 3
#	noise.period = 4.0
#	noise.persistence = .1
#	noise.lacunarity = 2.0
#	
#	var img = noise.get_image(map_size_x, map_size_y)
#	
#	var texture = ImageTexture.new()     
#	texture.create_from_image(img) 
#	
#	sprite.texture = texture
#	
#	for x in range(map_size_x):
#		var line = []
#		for y in range(map_size_y):
#			var num = noise.get_noise_2d(x, y)
#			if num < -.4:
#				num = 1
#			elif num > .4:
#				num = 2
#			else:
#				num = 0
#			line.append(num)
#		level.append(line)

func enter():
	visible = true
	set_process(true)
	player.camera.current = true
	player.ui.unit_display.change_category('conveyor')

func exit():
	visible = false
	set_process(false)
	player.camera.current = false
	
	save()
	
	for x in units.size():
		for y in units[x].size():
			delete_unit(Vector2(x, y))
	
	player.tutorial.step_num = 9
	player.tutorial.go_to_next_position()
	hq.delete_this()

func _ready():
	unit_names = unit_cost.keys()
	
	set_level(0, true)
	
	select_unit(null)

func _process(delta):
	delete_units()
	
	auto_save_timer -= delta
	if auto_save_timer <= 0:
		auto_save_timer = auto_save_time
		save()
		print('autosaved')
	
	if Input.is_action_just_pressed("escape"):
		exit()
		parent.main_menu.enter()
	
	if Input.is_action_just_released("scroll_down"):
		if unit_to_place != null:
			mouse_dir += 1
			if mouse_dir > 3:
				mouse_dir = 0
		else:
			player.zoom_out()
	if Input.is_action_just_released("scroll_up"):
		if unit_to_place != null:
			mouse_dir -= 1
			if mouse_dir < 0:
				mouse_dir = 3
		else:
			player.zoom_in()
	
	var grid_mouse_pos = get_global_mouse_position() / grid_size
	
	grid_mouse_pos = set_cursor(grid_mouse_pos)
	
	if Input.is_action_pressed("left_click"):
		if !mouse_in_ui and player.tutorial.step_num > 5 :
			if unit_to_place != null:
				spawn_unit(grid_mouse_pos)
		
		else: #maybe change the way stuff is build, plan before then place? it's not super fun
			if player.ui.unit_display.hovering_unit != null:
				select_unit(player.ui.unit_display.hovering_unit)
			
			elif player.ui.unit_display.hovering_category != null:
				player.ui.unit_display.change_category(player.ui.unit_display.hovering_category)
	
	if Input.is_action_just_pressed("left_click"):
		if player.tutorial.active:
			if player.tutorial.step_num < 2:
				player.tutorial.go_to_next_position()
			
			elif player.tutorial.step_num == 2 and unit_to_place == 'conveyor':
				player.tutorial.go_to_next_position()
			
			elif player.tutorial.step_num > 3 and player.tutorial.step_num < 5:
				player.tutorial.go_to_next_position()
			
			elif player.tutorial.step_num == 5:
				player.tutorial.go_to_next_position()
				spawn_conveyor(0, Vector2(17, 19), null)
				spawn_conveyor(3, Vector2(25, 20), null)
				spawn_big_mine(Vector2(26, 20), null, 0)
			
			elif player.tutorial.step_num == 8:
				player.tutorial.go_to_next_position()
				spawn_conveyor(0, Vector2(13, 15), null)
		
		if player.ui.unit_description.currently_active:
			player.ui.unit_description.exit()
		elif player.ui.task_description.currently_active:
			player.ui.task_description.exit()
		elif mouse_in_ui:
			if player.ui.selected_unit_display.hovering and !(player.tutorial.step_num == 4 or player.tutorial.step_num == 5):
				player.ui.unit_description.enter()
				
				if player.tutorial.step_num == 3:
					player.tutorial.go_to_next_position()
			
			if player.ui.task_display.hovering and player.tutorial.step_num > 8:
				player.ui.task_description.enter(player.ui.task_display.hovering_task)
	
	
	if Input.is_action_just_pressed("right_click"):
		deleted_something = false
	
	if Input.is_action_just_released("right_click"):
		if !deleted_something:
			select_unit(null)
	
	if Input.is_action_pressed("right_click"):
		delete_unit(grid_mouse_pos)
		
		if player.tutorial.step_num == 9:
			player.tutorial.go_to_next_position()
	
	if Input.is_action_just_pressed("middle_click"):
		copy_unit()
	
	
	co2_check(delta)
	power_check(delta)

func delete_units():
	if delete_this.size() > 0 and units_deleted < unit_delete_cap:
		var x = delete_this.size()
		if x > unit_delete_cap:
			x = unit_delete_cap
		
		while x > 0:
			var unit = delete_this.pop_front()
			unit.queue_free()
			x -= 1

func save():
	var map = []
	
	for x in range(map_size_x):
		var line = []
		for y in range(map_size_y):
			line.append(nature.get_cell(x, y))
		map.append(line)
	
	var temp_unit_list = []
	
	for line in units:
		for unit in line:
			if unit:
				temp_unit_list.append(unit)
	
	var unit_list = []
	
	while temp_unit_list != []:
		var unit = temp_unit_list.pop_front()
		var unit_name = unit.type
		var unit_info = []
		
		unit_info.append(unit_name)
		
		match unit_name:
			'headquarter':
				unit_info.append(unit.position / unit.grid_size)
				
			'conveyor':
				unit_info.append(unit.position / unit.grid_size)
				unit_info.append(unit.dir)
				unit_info.append(unit.current_item)
			
			'conv_junction': 
				unit_info.append(unit.position / unit.grid_size)
				unit_info.append(unit.current_x_item)
				unit_info.append(unit.current_y_item)
			
			'conv_router': 
				unit_info.append(unit.position / unit.grid_size)
				unit_info.append(unit.dir)
				unit_info.append(unit.current_item)
			
			'plastic_conveyor':
				unit_info.append(unit.position / unit.grid_size)
				unit_info.append(unit.dir)
				unit_info.append(unit.current_item)
			
			'plastic_junction': 
				unit_info.append(unit.position / unit.grid_size)
				unit_info.append(unit.current_x_item)
				unit_info.append(unit.current_y_item)
			
			'plastic_router': 
				unit_info.append(unit.position / unit.grid_size)
				unit_info.append(unit.dir)
				unit_info.append(unit.current_item)
			
			'big_mine':
				unit_info.append(unit.position / unit.grid_size)
				unit_info.append(unit.inventory.duplicate())
				unit_info.append(unit.used_ressources)
			
			'forester':
				unit_info.append(unit.position / unit.grid_size)
				unit_info.append(unit.inventory.duplicate())
			
			'pump':
				unit_info.append(unit.position / unit.grid_size)
				unit_info.append(unit.inventory.duplicate())
				unit_info.append(unit.used_ressources)
			
			'biomass_press':
				unit_info.append(unit.position / unit.grid_size)
				unit_info.append(unit.inventory.duplicate())
			
			'plastic_farm':
				unit_info.append(unit.position / unit.grid_size)
				unit_info.append(unit.inventory.duplicate())
				unit_info.append(unit.dir)
			
			'bio_generator':
				unit_info.append(unit.position / unit.grid_size)
				unit_info.append(unit.inventory.duplicate())
			
			'solar_panel':
				unit_info.append(unit.position / unit.grid_size)
			
			'electric_pump':
				unit_info.append(unit.position / unit.grid_size)
				unit_info.append(unit.inventory.duplicate())
			
			'co2_collector':
				unit_info.append(unit.position / unit.grid_size)
				unit_info.append(unit.inventory.duplicate())
			
			'bio_air_booster':
				unit_info.append(unit.position / unit.grid_size)
				unit_info.append(unit.inventory.duplicate())
		
		var already_in_the_list = false
		for old_unit in unit_list:
			if unit_info[1] == old_unit[1]:
				already_in_the_list = true
		
		if !already_in_the_list:
			unit_list.append(unit_info)
	
	var save_file = [player.inventory, player.total_count, total_co2_removed, unit_list, map]
	
	save_file(save_file, save_path + String(level) + '.dat')

func load_save():
	if read_file(save_path + String(level) + '.dat') != null:
		var save_file = read_file(save_path + String(level) + '.dat')
		
		player.inventory = save_file[0]
		
		for key in player.inventory.keys():
			player.update_ui(key, 0, false)
		
		player.total_count = save_file[1]
		
		total_co2_removed = save_file[2]
		
		for x in range(map_size_x):
			for y in range(map_size_y):
				nature.set_cell(x, y, save_file[4][x][y])
				nature.update_bitmask_area(Vector2(x, y))
		
		var units_to_place = save_file[3]
		
		while !units_to_place.empty():
			var unit = units_to_place.pop_front()
			
			match unit[0]:
				'headquarter':
					spawn_headquarter(unit[1])
				
				'conveyor':
					spawn_conveyor(unit[2], unit[1], unit[3])
				
				'conv_junction': 
					spawn_conv_junction(unit[1], unit[2], unit[3])
				
				'conv_router': 
					spawn_conv_router(unit[2], unit[1], unit[3])
				
				'plastic_conveyor':
					spawn_plastic_conveyor(unit[2], unit[1], unit[3])
				
				'plastic_junction': 
					spawn_plastic_junction(unit[1], unit[2], unit[3])
				
				'plastic_router': 
					spawn_plastic_router(unit[2], unit[1], unit[3])
				
				'big_mine':
					spawn_big_mine(unit[1], unit[2], unit[3])
				
				'forester':
					spawn_forester(unit[1], unit[2])
				
				'pump':
					spawn_pump(unit[1], unit[2], unit[3])
				
				'biomass_press':
					spawn_biomass_press(unit[1], unit[2])
				
				'plastic_farm':
					spawn_plastic_farm(unit[1], unit[2], unit[3])
				
				'bio_generator':
					spawn_bio_generator(unit[1], unit[2])
				
				'solar_panel':
					spawn_solar_panel(unit[1])
				
				'electric_pump':
					spawn_electric_pump(unit[1], unit[2])
				
				'co2_collector':
					spawn_electric_pump(unit[1], unit[2])
					
				'bio_air_booster':
					spawn_bio_air_booster(unit[1], unit[2])
		
		for x in range(map_size_x):
			for y in range(map_size_y):
				if units[x][y] != null:
					units[x][y].check_neighbors()

func save_file(content, path):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_var(content)
	file.close()

func read_file(path):
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_var()
	file.close()
	return(content)

func set_level(local_level: int, new_save: bool):
	player.ui.task_display.tasks_not_finished()
	
	total_co2_removed = 0
	
	level = local_level
	match level:
		0: 
			map_size_x = 75
			map_size_y = 50
			
			player.position = Vector2(17, 18)*grid_size
		1: 
			map_size_x = 100
			map_size_y = 100
			
			player.position = Vector2(27, 16)*grid_size
		2: 
			map_size_x = 150
			map_size_y = 100
			
			player.position = Vector2(79, 17)*grid_size
	
	player.z_index = map_size_y
	cursor.z_index = map_size_y
	needs_tile_text.z_index = map_size_y
	
	for x in units.size():
		for y in units[x].size():
			delete_unit(Vector2(x, y))
	
	units.clear()
	
	for _x in range(map_size_x):
		var line = []
		for _y in range(map_size_y):
			line.append(null)
		units.append(line)
	
	#print(units.size(), '  ', units[0].size())
	
	nature.queue_free()
	var new_nature = load("res://scenes and scripts/level_design/level" + String(level) + ".tscn").instance()
	nature = new_nature
	add_child(nature)
	
	tree_count = 0
	
	for x in range(map_size_x):
		for y in range(map_size_y):
			if nature.get_cell(x, y) == tree_id:
				tree_count += 1
	
	if new_save: #build basic base
		match level:
			0:
				spawn_headquarter(Vector2(16, 17))
			1:
				spawn_headquarter(Vector2(26, 15))
			2:
				spawn_headquarter(Vector2(78, 16))
				spawn_big_mine(Vector2(86, 24), null, 0)
				spawn_big_mine(Vector2(86, 22), null, 0)
				spawn_conveyor(0, Vector2(85, 24), null)
				spawn_conveyor(0, Vector2(85, 23), null)
				spawn_conveyor(0, Vector2(85, 22), null)
				spawn_conveyor(0, Vector2(85, 21), null)
				spawn_conveyor(0, Vector2(85, 20), null)
				spawn_conveyor(0, Vector2(85, 19), null)
				spawn_conveyor(0, Vector2(85, 18), null)
				spawn_conveyor(3, Vector2(85, 17), null)
				spawn_conveyor(3, Vector2(84, 17), null)
				spawn_conveyor(3, Vector2(83, 17), null)
				spawn_conveyor(3, Vector2(82, 17), null)
				spawn_conveyor(3, Vector2(81, 17), null)
				spawn_conveyor(3, Vector2(80, 17), null)
		
		player.set_starting_ressource(level)
	else:
		load_save()
	
	player.level = level
	player.remove_task_display()
	player.spawn_task_display()
	
	player.ui.unit_display.set_level(level)

func co2_check(delta):
	co2_timer += delta
	
	if co2_timer >= co2_time:
		co2_timer = 0
		
		var co2_remove = float(tree_count) * co2_remove_per_tree
		
		for unit in co2_changers:
			co2_remove += unit.co2_removal
		
		average_co2_removal.pop_back()
		average_co2_removal.push_front(co2_remove)
		
		total_co2_removed += co2_remove
		
		var last_10_second_average = 0.0
		for second in average_co2_removal:
			last_10_second_average += second
		#print(total_co2_removed)

func power_check(delta):
	power_timer += delta
	
	if power_timer >= power_time:
		power_timer = 0
		
		var current_power = 0
		
		for unit in power_producers:
			current_power += unit.power_output
		
		for unit in power_consumer:
			if current_power >= unit.power_consumption:
				current_power -= unit.power_consumption
				unit.is_powered = true
			else:
				unit.low_power_message.set_warning_message()
				unit.is_powered = false
		
		if current_power > 0:
			for unit in power_consumer:
				unit.low_power_message.cancel()
		
		average_power.pop_back()
		average_power.push_front(current_power)
		
		var last_10_second_average = 0.0
		for second in average_power:
			last_10_second_average += second
		current_average_power = last_10_second_average/10

func set_cursor(grid_mouse_pos):
	if unit_to_place != null:
		cursor.visible = true
		
		if !(unit_to_place in big_units):
			grid_mouse_pos.x = floor(grid_mouse_pos.x)
			grid_mouse_pos.y = floor(grid_mouse_pos.y)
			cursor.position = Vector2(grid_size/2, grid_size/2) + grid_mouse_pos * grid_size
		else:
			grid_mouse_pos.x = round(grid_mouse_pos.x)
			grid_mouse_pos.y = round(grid_mouse_pos.y)
			cursor.position = grid_mouse_pos * grid_size
			grid_mouse_pos -= Vector2(1, 1)
		
		if unit_to_place in rotate_units:
			if unit_to_place in conveyors:
				cursor.rotation_degrees = 90 * mouse_dir
			else:
				cursor.rotation_degrees = 0
				cursor.frame = mouse_dir
		else:
			cursor.rotation_degrees = 0
	return grid_mouse_pos

func spawn_unit(grid_mouse_pos):
	var enough_ressource = true
	
	for material in unit_cost[unit_to_place].keys():
		if player.inventory[material] < unit_cost[unit_to_place][material]:
			enough_ressource = false
	
	var spawned = false
	
	if enough_ressource:
		if unit_to_place in conveyors:
			if units[grid_mouse_pos.x][grid_mouse_pos.y] == null:
				spawned = spawn_any_conv(grid_mouse_pos)
			elif units[grid_mouse_pos.x][grid_mouse_pos.y].type in conveyors:
				var unit_to_replace = units[grid_mouse_pos.x][grid_mouse_pos.y]
				
				for material in unit_cost[unit_to_replace.type].keys():
					player.update_ui(material, unit_cost[unit_to_replace.type][material], true)
				
				unit_to_replace.remove_this()
				spawned = spawn_any_conv(grid_mouse_pos)
				
		elif !(unit_to_place in big_units):
			if units[grid_mouse_pos.x][grid_mouse_pos.y] == null:
				match unit_to_place:
					'forester':
						spawned = spawn_forester(grid_mouse_pos, null)
					'pump':
						spawned = spawn_pump(grid_mouse_pos, null, 0)
		else:
			if units[grid_mouse_pos.x + 1][grid_mouse_pos.y + 1] == null and units[grid_mouse_pos.x][grid_mouse_pos.y + 1] == null and units[grid_mouse_pos.x + 1][grid_mouse_pos.y] == null and units[grid_mouse_pos.x][grid_mouse_pos.y] == null:
				match unit_to_place:
					'big_mine': 
						spawned = spawn_big_mine(grid_mouse_pos, null, 0)
					'biomass_press':
						spawned = spawn_biomass_press(grid_mouse_pos, null)
					'plastic_farm':
						spawned = spawn_plastic_farm(grid_mouse_pos, null, mouse_dir)
					'bio_generator':
						spawned = spawn_bio_generator(grid_mouse_pos, null)
					'solar_panel':
						spawned = spawn_solar_panel(grid_mouse_pos)
					'electric_pump':
						spawned = spawn_electric_pump(grid_mouse_pos, null)
					'co2_collector':
						spawned = spawn_co2_collector(grid_mouse_pos, null)
					'bio_air_booster':
						spawned = spawn_bio_air_booster(grid_mouse_pos, null)
	
	if spawned:
		for material in unit_cost[unit_to_place].keys():
			player.update_ui(material, -unit_cost[unit_to_place][material], false)
		
		if unit_to_place in big_units:
			var tree_tiles = []
			for x in range(2):
				for y in range(2):
					match nature.get_cell(grid_mouse_pos.x + x, grid_mouse_pos.y + y):
						tree_id:
							tree_tiles.append(Vector2(grid_mouse_pos.x + x, grid_mouse_pos.y + y))
			
			for tree_tile in tree_tiles:
				remove_tree(tree_tile)
		else:
			var tile_id = nature.get_cell(grid_mouse_pos.x, grid_mouse_pos.y)
			if tile_id == tree_id:
				remove_tree(grid_mouse_pos)

func spawn_any_conv(grid_mouse_pos):
	var spawned = false
	
	match unit_to_place:
		'conveyor':
			spawned = spawn_conveyor(mouse_dir, grid_mouse_pos, null)
		'conv_router':
			spawned = spawn_conv_router(mouse_dir, grid_mouse_pos, null)
		'conv_junction':
			var can_place = check_junction_neighbors(grid_mouse_pos)
			
			if can_place == true:
				spawned = spawn_conv_junction(grid_mouse_pos, null, null)
		'plastic_conveyor':
			spawned = spawn_plastic_conveyor(mouse_dir, grid_mouse_pos, null)
		'plastic_router':
			spawned = spawn_plastic_router(mouse_dir, grid_mouse_pos, null)
		'plastic_junction':
			var can_place = check_junction_neighbors(grid_mouse_pos)
			
			if can_place == true:
				spawned = spawn_plastic_junction(grid_mouse_pos, null, null)
	
	return spawned

func check_junction_neighbors(pos: Vector2):
	var can_place = true
	
	var neighbors = []
	neighbors.append(units[pos.x][pos.y - 1])
	neighbors.append(units[pos.x][pos.y + 1])
	neighbors.append(units[pos.x - 1][pos.y])
	neighbors.append(units[pos.x + 1][pos.y])
	
	for neighbor in neighbors:
		if neighbor != null:
			if 'junction' in neighbor.name:
				can_place = false
				needs_tile_text.label.text = 'You cannot place a junction directly next to a junction.'
				needs_tile_text.active = true
				needs_tile_text.active_timer = needs_tile_text.active_time
	
	return can_place

func delete_unit(grid_mouse_pos):
	if units[grid_mouse_pos.x][grid_mouse_pos.y] != null:
		var unit = units[grid_mouse_pos.x][grid_mouse_pos.y]
		
		var do_not_delete = false
		
		if 'headquarter' in unit.name:
			do_not_delete = true
		
		elif unit.type in conveyors:
			for material in unit_cost[unit.type].keys():
				player.update_ui(material, unit_cost[unit.type][material], true)
		else:
			for material in unit_cost[unit.type].keys():
				player.update_ui(material, unit_cost[unit.type][material]/2, true)
		
		if !do_not_delete:
			units[grid_mouse_pos.x][grid_mouse_pos.y].delete_this()
			deleted_something = true

func copy_unit():
	var cursor_pos = get_global_mouse_position() / grid_size
	cursor_pos.x = floor(cursor_pos.x)
	cursor_pos.y = floor(cursor_pos.y)
	
	if units[cursor_pos.x][cursor_pos.y] != null:
		if !('headquarter' in units[cursor_pos.x][cursor_pos.y].name):
			select_unit(units[cursor_pos.x][cursor_pos.y].type)

func select_unit(unit_type):
	unit_to_place = unit_type
	
	for container in player.ui.unit_display.containers:
		if container.unit == unit_type:
			container.outline.visible = true
		else:
			container.outline.visible = false
	
	if unit_to_place == null:
		cursor.visible = false
		player.ui.selected_unit_display.visible = false
		
		player.ui.area_col.set_polygon(player.ui.standard_polygon)
		
	else:
		cursor.animation = unit_to_place
		player.ui.selected_unit_display.visible = true
		player.ui.selected_unit_display.select_unit(unit_type)

func unit_needs_tile(tile0, tile1, tile2):
	var text = 'Place this unit on'
	
	var tiles = [tile0, tile1, tile2]
	
	for tile in tiles:
		if tile != tile0 and tile != null:
			text += ' and'
		match tile:
			dirt_id:
				text += ' an empty tile'
			city_id:
				text += ' a city tile'
			tree_id:
				text += ' a tree tile'
			mountain_id:
				text += ' a mountain tile'
			water_id:
				text += ' a water tile'
	
	text += '.'
	
	needs_tile_text.label.text = text
	needs_tile_text.active = true
	needs_tile_text.active_timer = needs_tile_text.active_time

func spawn_tree(pos: Vector2):
	nature.set_cell(pos.x, pos.y, tree_id)
	nature.update_bitmask_area(pos)
	tree_count += 1
	
	for line in units:
		for forester in line:
			if forester != null and 'forester' in forester.name:
				forester.check_nature()

func remove_tree(pos: Vector2):
	tree_count -= 1
	spawn_dirt(pos)

func spawn_dirt(pos: Vector2):
	nature.set_cell(pos.x, pos.y, dirt_id)
	nature.update_bitmask_area(pos)

func spawn_conveyor(dir: int, pos: Vector2, item):
	var tile_id = nature.get_cell(pos.x, pos.y)
	if tile_id != mountain_id and tile_id != water_id:
		var conveyor = load("res://scenes and scripts/conveyor/conveyor.tscn").instance()
		conveyor.position = Vector2(grid_size*pos.x, grid_size*pos.y)
		units[pos.x][pos.y] = conveyor
		conveyor.dir = dir
		conveyor.current_item = item
		if item != null:
			conveyor.inventory = 1
		add_child(conveyor)
		
		return true

func spawn_conv_router(dir: int, pos: Vector2, item):
	var tile_id = nature.get_cell(pos.x, pos.y)
	if tile_id != mountain_id and tile_id != water_id:
		var conv_router = load("res://scenes and scripts/conveyor/conv_router.tscn").instance()
		conv_router.position = Vector2(grid_size*pos.x, grid_size*pos.y)
		units[pos.x][pos.y] = conv_router
		conv_router.dir = dir
		conv_router.current_item = item
		if item != null:
			conv_router.inventory = 1
		add_child(conv_router)
		
		return true

func spawn_conv_junction(pos: Vector2, current_x_item, current_y_item):
	var tile_id = nature.get_cell(pos.x, pos.y)
	if tile_id != mountain_id and tile_id != water_id:
		var conv_junction = load("res://scenes and scripts/conveyor/conv_junction.tscn").instance()
		conv_junction.position = Vector2(grid_size*pos.x, grid_size*pos.y)
		units[pos.x][pos.y] = conv_junction
		conv_junction.current_x_item = current_x_item
		if current_x_item != null:
			conv_junction.x_inventory = 1
		conv_junction.current_y_item = current_y_item
		if current_y_item != null:
			conv_junction.y_inventory = 1
		add_child(conv_junction)
		
		return true

func spawn_plastic_conveyor(dir: int, pos: Vector2, item):
	var tile_id = nature.get_cell(pos.x, pos.y)
	if tile_id != mountain_id and tile_id != water_id:
		var plastic_conveyor = load("res://scenes and scripts/conveyor/plastic_conveyor.tscn").instance()
		plastic_conveyor.position = Vector2(grid_size*pos.x, grid_size*pos.y)
		units[pos.x][pos.y] = plastic_conveyor
		plastic_conveyor.dir = dir
		plastic_conveyor.current_item = item
		if item != null:
			plastic_conveyor.inventory = 1
		add_child(plastic_conveyor)
		
		return true

func spawn_plastic_router(dir: int, pos: Vector2, item):
	var tile_id = nature.get_cell(pos.x, pos.y)
	if tile_id != mountain_id and tile_id != water_id:
		var plastic_router = load("res://scenes and scripts/conveyor/plastic_route.tscn").instance()
		plastic_router.position = Vector2(grid_size*pos.x, grid_size*pos.y)
		units[pos.x][pos.y] = plastic_router
		plastic_router.dir = dir
		plastic_router.current_item = item
		if item != null:
			plastic_router.inventory = 1
		add_child(plastic_router)
		
		return true

func spawn_plastic_junction(pos: Vector2, current_x_item, current_y_item):
	var tile_id = nature.get_cell(pos.x, pos.y)
	if tile_id != mountain_id and tile_id != water_id:
		var plastic_junction = load("res://scenes and scripts/conveyor/plastic_junction.tscn").instance()
		plastic_junction.position = Vector2(grid_size*pos.x, grid_size*pos.y)
		units[pos.x][pos.y] = plastic_junction
		plastic_junction.current_x_item = current_x_item
		if current_x_item != null:
			plastic_junction.x_inventory = 1
		plastic_junction.current_y_item = current_y_item
		if current_y_item != null:
			plastic_junction.y_inventory = 1
		add_child(plastic_junction)
		
		return true

func spawn_headquarter(pos: Vector2):
	var can_place = true
	
	for x in range(2):
		for y in range(2):
			if nature.get_cell(pos.x + x, pos.y + y) == mountain_id or nature.get_cell(pos.x + x, pos.y + y) == water_id:
				can_place = false
	
	if can_place:
		var headquarter = load("res://scenes and scripts/ressource_mining/headquarter.tscn").instance()
		headquarter.position = Vector2(grid_size*pos.x, grid_size*pos.y)
		units[pos.x][pos.y] = headquarter
		units[pos.x + 1][pos.y] = headquarter
		units[pos.x][pos.y + 1] = headquarter
		units[pos.x + 1][pos.y + 1] = headquarter
		add_child(headquarter)
		hq = headquarter

func spawn_big_mine(pos: Vector2, inventory, used_ressources: int):
	var can_place = true
	
	var city_tiles = 0
	
	for x in range(2):
		for y in range(2):
			match nature.get_cell(pos.x + x, pos.y + y):
				mountain_id:
					can_place = false
				water_id:
					can_place = false
				city_id:
					city_tiles += 1
	
	if city_tiles == 0:
		can_place = false
		
		unit_needs_tile(city_id, null, null)
	
	if can_place:
		var big_mine = load("res://scenes and scripts/ressource_mining/big_mine.tscn").instance()
		big_mine.position = Vector2(grid_size*pos.x, grid_size*pos.y)
		units[pos.x][pos.y] = big_mine
		units[pos.x + 1][pos.y] = big_mine
		units[pos.x][pos.y + 1] = big_mine
		units[pos.x + 1][pos.y + 1] = big_mine
		if inventory != null:
			big_mine.inventory = inventory
		big_mine.used_ressources = used_ressources
		add_child(big_mine)
		
		return true

func spawn_biomass_press(pos: Vector2, inventory):
	var can_place = true
	
	for x in range(2):
		for y in range(2):
			match nature.get_cell(pos.x + x, pos.y + y):
				mountain_id:
					can_place = false
				water_id:
					can_place = false
	
	if can_place:
		var biomass_press = load("res://scenes and scripts/factory/biomass_press.tscn").instance()
		biomass_press.position = Vector2(grid_size*pos.x, grid_size*pos.y)
		units[pos.x][pos.y] = biomass_press
		units[pos.x + 1][pos.y] = biomass_press
		units[pos.x][pos.y + 1] = biomass_press
		units[pos.x + 1][pos.y + 1] = biomass_press
		if inventory != null:
			biomass_press.inventory = inventory
		add_child(biomass_press)
		
		return true

func spawn_forester(pos: Vector2, inventory):
	var tile_id = nature.get_cell(pos.x, pos.y)
	if tile_id != mountain_id and tile_id != water_id:
		var forester = load("res://scenes and scripts/ressource_mining/forester.tscn").instance()
		forester.position = Vector2(grid_size*pos.x, grid_size*pos.y)
		units[pos.x][pos.y] = forester
		if inventory != null:
			forester.inventory = inventory
		add_child(forester)
		
		return true

func spawn_pump(pos: Vector2, inventory, used_ressources: int):
	var tile_id = nature.get_cell(pos.x, pos.y)
	if tile_id == water_id:
		var pump = load("res://scenes and scripts/ressource_mining/pump.tscn").instance()
		pump.position = Vector2(grid_size*pos.x, grid_size*pos.y)
		units[pos.x][pos.y] = pump
		if inventory != null:
			pump.inventory = inventory
		pump.used_ressources = used_ressources
		add_child(pump)
		
		return true
	else:
		unit_needs_tile(water_id, null, null)

func spawn_plastic_farm(pos: Vector2, inventory, dir: int):
	var can_place = true
	
	var water_tiles = 0
	var dirt_tiles = 0
	
	for x in range(2):
		for y in range(2):
			match nature.get_cell(pos.x + x, pos.y + y):
				mountain_id:
					can_place = false
				water_id:
					water_tiles += 1
				dirt_id:
					dirt_tiles += 1
	
	if water_tiles == 0 or dirt_tiles == 0:
		can_place = false
		unit_needs_tile(water_tiles, dirt_tiles, null)
	
	if can_place:
		var plastic_farm = load("res://scenes and scripts/ressource_mining/plastic_farm.tscn").instance()
		plastic_farm.position = Vector2(grid_size*pos.x, grid_size*pos.y)
		units[pos.x][pos.y] = plastic_farm
		units[pos.x + 1][pos.y] = plastic_farm
		units[pos.x][pos.y + 1] = plastic_farm
		units[pos.x + 1][pos.y + 1] = plastic_farm
		if inventory != null:
			plastic_farm.inventory = inventory
		plastic_farm.dir = dir
		add_child(plastic_farm)
		
		return true

func spawn_bio_generator(pos: Vector2, inventory):
	var can_place = true
	
	for x in range(2):
		for y in range(2):
			match nature.get_cell(pos.x + x, pos.y + y):
				mountain_id:
					can_place = false
				water_id:
					can_place = false
	
	if can_place:
		var bio_generator = load("res://scenes and scripts/factory/bio_generator.tscn").instance()
		bio_generator.position = Vector2(grid_size*pos.x, grid_size*pos.y)
		units[pos.x][pos.y] = bio_generator
		units[pos.x + 1][pos.y] = bio_generator
		units[pos.x][pos.y + 1] = bio_generator
		units[pos.x + 1][pos.y + 1] = bio_generator
		if inventory != null:
			bio_generator.inventory = inventory
		power_producers.append(bio_generator)
		add_child(bio_generator)
		
		return true

func spawn_solar_panel(pos: Vector2):
	var can_place = true
	
	for x in range(2):
		for y in range(2):
			match nature.get_cell(pos.x + x, pos.y + y):
				mountain_id:
					can_place = false
				water_id:
					can_place = false
	
	if can_place:
		var solar_panel = load("res://scenes and scripts/factory/solar_panel.tscn").instance()
		solar_panel.position = Vector2(grid_size*pos.x, grid_size*pos.y)
		units[pos.x][pos.y] = solar_panel
		units[pos.x + 1][pos.y] = solar_panel
		units[pos.x][pos.y + 1] = solar_panel
		units[pos.x + 1][pos.y + 1] = solar_panel
		power_producers.append(solar_panel)
		add_child(solar_panel)
		
		return true

func spawn_electric_pump(pos: Vector2, inventory):
	var can_place = true
	
	var water_tiles = 0
	
	for x in range(2):
		for y in range(2):
			match nature.get_cell(pos.x + x, pos.y + y):
				mountain_id:
					can_place = false
				water_id:
					water_tiles += 1
	
	if water_tiles == 0:
		can_place = false
		
		unit_needs_tile(water_id, null, null)
	
	if can_place:
		var electric_pump = load("res://scenes and scripts/ressource_mining/electric_pump.tscn").instance()
		electric_pump.position = Vector2(grid_size*pos.x, grid_size*pos.y)
		units[pos.x][pos.y] = electric_pump
		units[pos.x + 1][pos.y] = electric_pump
		units[pos.x][pos.y + 1] = electric_pump
		units[pos.x + 1][pos.y + 1] = electric_pump
		if inventory != null:
			electric_pump.inventory = inventory
		power_consumer.append(electric_pump)
		add_child(electric_pump)
		
		return true

func spawn_co2_collector(pos: Vector2, inventory):
	var can_place = true
	
	for x in range(2):
		for y in range(2):
			match nature.get_cell(pos.x + x, pos.y + y):
				mountain_id:
					can_place = false
				water_id:
					can_place = false
	
	if can_place:
		var co2_collector = load("res://scenes and scripts/ressource_mining/co2_collector.tscn").instance()
		co2_collector.position = Vector2(grid_size*pos.x, grid_size*pos.y)
		units[pos.x][pos.y] = co2_collector
		units[pos.x + 1][pos.y] = co2_collector
		units[pos.x][pos.y + 1] = co2_collector
		units[pos.x + 1][pos.y + 1] = co2_collector
		if inventory != null:
			co2_collector.inventory = inventory
		power_consumer.append(co2_collector)
		add_child(co2_collector)
		
		return true

func spawn_bio_air_booster(pos: Vector2, inventory):
	var can_place = true
	
	for x in range(2):
		for y in range(2):
			match nature.get_cell(pos.x + x, pos.y + y):
				mountain_id:
					can_place = false
				water_id:
					can_place = false
	
	if can_place:
		var bio_air_booster = load("res://scenes and scripts/factory/bio_air_booster.tscn").instance()
		bio_air_booster.position = Vector2(grid_size*pos.x, grid_size*pos.y)
		units[pos.x][pos.y] = bio_air_booster
		units[pos.x + 1][pos.y] = bio_air_booster
		units[pos.x][pos.y + 1] = bio_air_booster
		units[pos.x + 1][pos.y + 1] = bio_air_booster
		if inventory != null:
			bio_air_booster.inventory = inventory
		co2_changers.append(bio_air_booster)
		add_child(bio_air_booster)
		
		return true
