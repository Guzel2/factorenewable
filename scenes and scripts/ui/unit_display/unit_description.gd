extends Sprite

onready var parent = get_parent()
onready var text = find_node('text_display')

var currently_active = false

var descriptions = {
	'conveyor': [
		'Transports items slowly forward.',
		'',
		'Inventory Size: 1 Item',
		'Transport Time: .25s'
	],
	'conv_junction': [
		'Transports items horizontally and/or vertically.',
		'This acts as a crossroad for 2 conveyor paths.',
		'',
		'Inventory Size: 1 Item',
		'Transport Time: .25s'
	],
	'conv_router': [
		'Distributes items equally to 3 output directions.',
		'Use this to fuel several factories at the same time.',
		'',
		'Inventory Size: 1 Item',
		'Transport Time: 0.25s'
	],
	'plastic_conveyor': [
		'Transports items quickly forward.',
		'An improved conveyor build using plastic.',
		'',
		'Inventory Size: 1 Item',
		'Transport Time: .15s'
	],
	'plastic_junction': [
		'Transports items horizontally and/or vertically.',
		'This acts as a crossroad for 2 conveyor paths.',
		'An improved junction build using plastic.',
		'',
		'Inventory Size: 1 Item',
		'Transport Time: 0.15s'
	],
	'plastic_router': [
		'Distributes items equally to 3 output directions.',
		'Use this to fuel several factories at the same time.',
		'An improved router build using plastic.',
		'',
		'Inventory Size: 1 Item',
		'Transport Time: 0.15s'
	],
	'big_mine': [
		'Recycles trash from Rusted cities into Scrap.',
		'Outputs scrap to adjacent conveyors.',
		'',
		'Inventory Size: 30 Items',
		'Production Speed: 0.2 Scrap per Rusted City Tile per Second',
		'',
		'Warning: This unit runs out of ressources after a while!'
	],
	'forester': [
		'Gathers wood from neighboring trees.',
		'',
		'Inventory Size: 10 Items',
		'Production Speed: 0.15 Wood per neighboring Tree Tile per Second',
		'Range: All trees 2 tiles away horizontally or vertically and',
		'          all diagonal trees are neighboring Trees',
		'',
		'',
		'Plants new Trees in close range if provided with water',
		'',
		'Production Speed: 5s',
		'Production Cost: 5 Water',
		'Range: 2 tiles horizontally or vertically, and 1 tile diagonally.'
	],
	'pump': [
		'Pumps water from lakes and seas.',
		'',
		'Inventory Size: 10 Items',
		'Production Speed: 0.2 Water per Second',
		'',
		'Warning: This unit runs out of ressources after a while!'
	],
	'biomass_press': [
		'Combines Water and Wood to produce Biomass.',
		'',
		'Inventory Size: 30 Items',
		'Production Speed: 0.75s',
		'',
		'Input: 1 Water + 2 Wood = 2 Biomass'
	],
	'plastic_farm': [
		'Fishes Plastic from lakes and seas.',
		'',
		'Inventory Size: 30 Items',
		'Production Speed: 0.05 Plastic per Second per Water tile in this units range',
		'Range: 3x2 Tiles in the direction the unit is facing'
	],
	'bio_generator': [
		'Uses Biomass to produce Power.',
		'',
		'Inventory Size: 50 Items',
		'Production Speed: 2s',
		'Output: 1.5 Powerunits per Second'
	],
	'solar_panel': [
		'Uses Solar Energy to produce Power.',
		'',
		'Output: 0.25 Powerunits per Second'
	],
	'electric_pump': [
		'Pumps water from lakes and seas.',
		'This pump uses Power to be more sustainable than normal pumps.',
		'Because of that it never runs out of ressources.',
		'',
		'Inventory Size: 30 Items',
		'Production Speed: 0.25 Water per Water Tile, covered by this pump, per Second',
		'',
		'Input: 0.5 Powerunits per Second',
	],
	'co2_collector': [
		'Collects CO2 from the atmosphere.',
		'This unit does not remove the CO2, it only collects it for other units to use.',
		'',
		'Inventory Size: 30 Items',
		'Production Speed: 0.6 CO2 per Second',
		'',
		'Input: 0.75 Powerunits per Second'
	],
	'bio_air_booster': [
		'Turns CO2 into O2 using Biomass.',
		'',
		'Inventory Size: 40',
		'Production Speed: 2 Seconds',
		'',
		'Input: 1 CO2 and 0.5 Biomass per Second',
	]
}

func enter():
	visible = true
	currently_active = true
	
	var temp_text = ''
	
	var line_count = 0
	
	for line in descriptions[parent.parent.parent.unit_to_place]:
		temp_text += line
		temp_text += '\n'
		
		line_count += 1
	
	text.text = temp_text
	
	if parent.parent.tutorial.active:
		parent.parent.tutorial.visible = false

func exit():
	visible = false
	currently_active = false
	
	if parent.parent.tutorial.active:
		parent.parent.tutorial.visible = true

func print_this_text(new_text: String):
	visible = true
	currently_active = true
	
	text.text = new_text
