extends Sprite

onready var parent = get_parent()
onready var text = find_node('text_display')

var currently_active = false

var descriptions = {
	0:
		[
			['Collect a total of 300 Scrap.',
			'Build Recyclers on city tiles (red/orange tiles) to mine Scrap.',
			'Use Scrap to build new units.'],
		],
	1:
		[
			['Collect a total of 2000 Scrap.',
			'Build Recyclers on city tiles (red/orange tiles) to mine Scrap.',
			'Use Scrap to build new units.'],
			
			['Build a Forester near trees to gather wood.',
			'If you provide this Forester with water, it will start planting trees.',]
		],
	2:
		[
			['There are 2 main ways to remove CO2: Trees and the Bio Air Booster',
			'',
			'Each tree removes 0,05 CO2 per Second.',
			'Plant trees using the Forester',
			'',
			'Fuel the Bio Air Booster with CO2 and Biomass to remove 1,0 CO2 per Second.'
			],
			
			['Collect a total of 2500 Plastic.',
			'Build Plastic Farms near the Water to collect Plastic.',
			'Use Plastic to build new units and faster conveyors.'],
			
			['Generate 10 Power units per Second',
			'Use Solar Panels and/or Bio Generators to produce Power'
			]
		]
}

func enter(task_num):
	visible = true
	currently_active = true
	
	var temp_text = ''
	
	var line_count = 0
	
	for line in descriptions[parent.parent.parent.level][task_num]:
		print(line)
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
