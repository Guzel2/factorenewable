extends Sprite

onready var parent = get_parent()

var containers = []
var category_containers = []
var hovering_unit = null
var hovering_category = null

var units_per_category = {}

var available_units_per_level = [
	{
		'conveyor': ['conveyor', 'conv_junction', 'conv_router'],
		'ressource_mine': ['big_mine'],
		'factory': []
	},
	{
		'conveyor': ['conveyor', 'conv_junction', 'conv_router'],
		'ressource_mine': ['big_mine', 'forester', 'pump'],
		'factory': ['biomass_press']
	},
	{
		'conveyor': ['conveyor', 'conv_junction', 'conv_router', 'plastic_conveyor', 'plastic_junction', 'plastic_router'],
		'ressource_mine': ['big_mine', 'forester', 'pump', 'plastic_farm', 'electric_pump', 'co2_collector'],
		'factory': ['biomass_press', 'solar_panel', 'bio_generator', 'bio_air_booster']
	},
]

func _ready():
	yield(get_tree().create_timer(0.1), "timeout")
	
	for x in range(9):
		var container = load("res://scenes and scripts/ui/unit_display/unit_container.tscn").instance()
		
		container.position = Vector2(4 + (x % 3) * 21, 4 + (x/3) * 23)
		containers.append(container)
		
		add_child(container)
	
	var categories = units_per_category.keys()
	for x in range(3):
		var category_container = load("res://scenes and scripts/ui/unit_display/unit_category.tscn").instance()
		
		category_container.position = Vector2(70, 4) + Vector2(0, 23*x)
		category_container.frame = x
		category_container.category = categories[x]
		category_containers.append(category_container)
		
		add_child(category_container)
	
	change_category('conveyor')

func change_category(category):
	var x = 0
	for container in containers:
		if x < units_per_category[category].size():
			container.change_unit_to(units_per_category[category][x])
		else:
			container.change_unit_to(null)
		x += 1
	
	for category_container in category_containers:
		if category_container.category == category:
			category_container.outline.visible = true
		else:
			category_container.outline.visible = false
	
	if parent.parent != null:
		parent.parent.parent.select_unit(parent.parent.parent.unit_to_place)
	

func set_level(level: int):
	units_per_category.clear()
	
	units_per_category = available_units_per_level[level].duplicate()
	print(units_per_category)
