extends Node2D

onready var parent = get_parent()
onready var camera = find_node('camera')
onready var ui = $ui
onready var tutorial = find_node('tutorial')

var dir = Vector2(0, 0)
var friction = .9

var inventory = {
	'scrap': 0,
	'wood': 0,
	'water': 0,
	'biomass': 0,
	'plastic': 0,
	'co2': 0,
}

var total_count = {
	'scrap': 0,
	'wood': 0,
	'water': 0,
	'biomass': 0,
	'plastic': 0,
	'co2': 0,
}

var level = 0

var task_description = {
	0: [
		'Collect 300 Scrap'
	],
	
	1: [
		'Collect 2000 Scrap',
		'Plant 60 Trees'
	],
	2: [
		'Remove 1000 CO2',
		'Collect 250 Plastic',
		'Generate Power/Sec',
	]
}

var task_values = {
	0: [
		[90, 300],
	],
	1: [
		[100, 2000],
		[20, 60],
	],
	2: [
		[0, 1000],
		[0, 250],
		[0, 10],
	]
}

var zoom_level_time = [0, 0, 0, 0, 0, 0, 0, 0, 0]
var zoom_level = 4

var average_production = {
	'scrap': 0,
	'wood': 0,
	'water': 0,
	'biomass': 0,
	'plastic': 0,
	'co2': 0,
}

var old_count = {
	'scrap': 0,
	'wood': 0,
	'water': 0,
	'biomass': 0,
	'plastic': 0,
	'co2': 0,
}

var average_production_time = 4.0
var average_production_timer = 0.0

func _ready():
	spawn_task_display()

func set_starting_ressource(level: int):
	var keys = inventory.keys()
	for key in keys:
		inventory[key] = 0
		total_count[key] = 0
	
	update_ui('scrap', 0, false)
	update_ui('wood', 0, false)
	update_ui('water', 0, false)
	update_ui('biomass', 0, false)
	update_ui('plastic', 0, false)
	update_ui('co2', 0, false)
	
	match level:
		0:
			update_ui('scrap', 90, false)
		1:
			update_ui('scrap', 100, false)
		2:
			update_ui('scrap', 200, false)
			update_ui('wood', 50, false)
		3:
			pass

func spawn_task_display():
	var y_offset = 26
	var x = 0
	for task_text in task_description[level]:
		var container = load("res://scenes and scripts/ui/task_display/task_container.tscn").instance()
		container.text = task_text
		container.position.y += y_offset * x
		
		container.starting_value = task_values[level][x][0]
		container.target_value = task_values[level][x][1]
		
		container.task_num = x
		
		ui.task_display.add_child(container)
		ui.task_display.containers.append(container)
		
		x += 1

func remove_task_display():
	for container in ui.task_display.containers:
		container.queue_free()
	ui.task_display.containers.clear()

func _process(delta):
	if tutorial.step_num == 10:
		movement(delta)
		zoom_level_time[zoom_level] += delta
	
	check_tasks()
	
	update_average_production(delta)

func movement(delta):
	var temp_dir = Vector2(0, 0)
	
	if Input.is_action_pressed("up"):
		temp_dir += Vector2.UP
	if Input.is_action_pressed("down"):
		temp_dir += Vector2.DOWN
	if Input.is_action_pressed("left"):
		temp_dir += Vector2.LEFT
	if Input.is_action_pressed("right"):
		temp_dir += Vector2.RIGHT
	
	if position.x < 0:
		temp_dir.x += 1
	if position.x > parent.map_size_x * parent.grid_size:
		temp_dir.x -= 1
	
	if position.y < 0:
		temp_dir.y += 1
	if position.y > parent.map_size_y * parent.grid_size:
		temp_dir.y -= 1
	
	dir += temp_dir.normalized()
	
	position += dir * delta * 60
	
	dir *= friction

func check_tasks():
	match level:
		0:
			ui.task_display.update_tasks(0, total_count['scrap'])
			if total_count['scrap'] > task_values[level][0][1]:
				ui.task_display.tasks_finished()
		1:
			ui.task_display.update_tasks(0, total_count['scrap'])
			ui.task_display.update_tasks(1, parent.tree_count)
			
			if total_count['scrap'] > task_values[level][0][1] and parent.tree_count > task_values[level][1][1] :
				ui.task_display.tasks_finished()
		2:
			ui.task_display.update_tasks(0, parent.total_co2_removed)
			ui.task_display.update_tasks(1, total_count['plastic'])
			ui.task_display.update_tasks(2, parent.current_average_power)
			
			if parent.total_co2_removed > task_values[level][0][1] and total_count['plastic'] > task_values[level][1][1] and parent.current_average_power > task_values[level][2][1]:
				ui.task_display.tasks_finished()
		3:
			pass

func update_ui(item: String, amount: int, refund: bool):
	inventory[item] += amount
	if amount >= 0 and !refund:
		total_count[item] += amount
	ui.ressource_display.containers[item].display_number(inventory[item])
	
	if parent.unit_to_place != null:
		ui.selected_unit_display.select_unit(parent.unit_to_place)
	
	if tutorial.step_num == 6 and amount >= 0 and !refund:
		if item == 'scrap':
			tutorial.go_to_next_position()

func zoom_in():
	if scale.x > 0.64:
		camera.zoom *= 0.8
		scale *= 0.8
		zoom_level -= 1

func zoom_out():
	if scale.x < 1.953125:
		camera.zoom *= 1.25
		scale *= 1.25
		zoom_level += 1

func update_average_production(delta: float):
	average_production_timer += delta
	
	if average_production_timer >= average_production_time:
		average_production_timer = 0
		
		var keys = average_production.keys()
		
		for key in keys:
			if total_count[key] > old_count[key]:
				average_production[key] = float(total_count[key]-old_count[key]) / average_production_time
				old_count[key] = total_count[key]
	
	if tutorial.step_num == 7 and average_production['scrap'] > 0.8 and average_production['scrap'] < 2:
		var big_mine_count = 0
		
		for line in parent.units:
			for unit in line:
				if unit != null:
					if 'big_mine' in unit.name:
						big_mine_count += 1
		
		if big_mine_count > 4:
			tutorial.go_to_next_position()


func _on_area_area_entered(area):
	var unit = area.get_parent()
	
	unit.on_screen = true

func _on_area_area_exited(area):
	var unit = area.get_parent()
	
	unit.on_screen = false
