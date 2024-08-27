extends Sprite

onready var parent = get_parent()
onready var unit_display = find_node('unit_display')
onready var text_display = find_node('text_display')
onready var ressources = []
onready var area = find_node('select_area')
onready var area_col = area.find_node('select_col')

var hovering = false

var unit_descriptions = {
	'conveyor': 'Conveyor: Moves Items',
	'conv_junction':  'Junction: Crosses Paths',
	'conv_router': 'Router:   Spreads Items',
	'plastic_conveyor': 'Plast Conveyor: Moves Items',
	'plastic_junction':  'Plast Junction: Crosses Paths',
	'plastic_router': 'Plast Router:   Spreads Items',
	'big_mine': 'Recycler: Produces Scrap',
	'forester': 'Forester: Produces Wood',
	'pump': 'Pump:    Produces Water',
	'biomass_press': 'Biomass Press: Makes Biomass',
	'plastic_farm': 'Plastic Farm: Collects Plastic',
	'bio_generator': 'Bio-Generator: Produces Power',
	'solar_panel': 'Solar Panel: Produces Power',
	'electric_pump': 'Electric Pump: Produces Water',
	'co2_collector': 'CO2 Collector: Produces CO2',
	'bio_air_booster': 'Bio Air Booster: Consumes CO2'
}

func _ready():
	for child in get_children():
		if 'ressource' in child.name:
			ressources.append(child)

func select_unit(unit):
	unit_display.animation = unit
	
	text_display.text = unit_descriptions[unit]
	
	for ressource in ressources:
		ressource.visible = false
	
	var x = 0
	for ressource in parent.parent.parent.unit_cost[unit]:
		ressources[x].sprite.animation = ressource
		ressources[x].visible = true
		
		var number = ''
		
		if parent.parent.inventory[ressource] > parent.parent.parent.unit_cost[unit][ressource]:
			number += str(parent.parent.parent.unit_cost[unit][ressource])
		else:
			number += str(parent.parent.inventory[ressource])
		
		number += '_'
		number += str(parent.parent.parent.unit_cost[unit][ressource])
		
		for num in ressources[x].numbers:
			num.visible = false
		
		var y = 0
		for num in number:
			ressources[x].numbers[y].visible = true
			ressources[x].numbers[y].animation = num
			y += 1
		
		x += 1
	
	
	var new_polygon = parent.standard_polygon
	
	new_polygon[0].y += 21 + 15 * x
	new_polygon[1].y += 21 + 15 * x
	
	parent.area_col.set_polygon(new_polygon)
	
	area_col.shape.extents.y = (21.0 + 15.0 * x + 3)/2
	area_col.position.y = (21.0 + 15.0 * x + 3)/2


func _on_select_area_mouse_entered():
	hovering = true

func _on_select_area_mouse_exited():
	hovering = false
