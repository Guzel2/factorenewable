extends Node2D

onready var ressource_sprite = $ressource_sprite

var numbers = []

var ressource

func _ready():
	for child in get_children():
		if "number" in child.name:
			numbers.append(child)
	
	if ressource != null:
		ressource_sprite.animation = ressource
	else:
		visible = false

func display_number(num):
	if num <= 0:
		visible = false
	else:
		visible = true
		var num_as_str = str(num)
		
		for number in numbers:
			number.visible = true
		
		if num < 1000:
			pass
		elif num < 10000:
			num_as_str = num_as_str[0] + 'k'
		elif num < 100000:
			num_as_str = num_as_str[0] + num_as_str[1] + 'k'
		else:
			num_as_str = num_as_str[1] + num_as_str[2] + 'k'
		
		for digit in num_as_str.length():
			numbers[digit].animation = num_as_str[digit]
		
		for difference in numbers.size() - num_as_str.length():
			numbers[2-difference].visible = false
	
