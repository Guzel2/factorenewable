extends AnimatedSprite

onready var outline = $outline
onready var parent = get_parent()

var category

func _on_area_mouse_entered():
	parent.hovering_category = category

func _on_area_mouse_exited():
	parent.hovering_category = null
