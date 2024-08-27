extends Sprite

onready var sprite = $ressource_sprite

var numbers = []

func _ready():
	for child in get_children():
		if child != sprite:
			numbers.append(child)
