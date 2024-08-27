extends Sprite

onready var parent = get_parent()

var width = 0
var containers = {}

func _ready():
	width = texture.get_data().get_width() - 6
	
	for x in range(12):
		var container = load("res://scenes and scripts/ui/ressource_display/ressource_container.tscn").instance()
		
		if x < 6:
			container.position.x = (-width/2) + (width/6) * x
			container.position.y = -20
		else:
			container.position.x = (-width/2) + (width/6) * (x-6)
		
		match x:
			0:
				container.ressource = 'scrap'
				containers['scrap'] = container
			1:
				container.ressource = 'wood'
				containers['wood'] = container
			2:
				container.ressource = 'water'
				containers['water'] = container
			3:
				container.ressource = 'biomass'
				containers['biomass'] = container
			4:
				container.ressource = 'plastic'
				containers['plastic'] = container
			5:
				container.ressource = 'co2'
				containers['co2'] = container
		
		add_child(container)
