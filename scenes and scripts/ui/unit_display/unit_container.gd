extends AnimatedSprite

onready var parent = get_parent()
onready var outline = $outline

var unit

func change_unit_to(new_unit):
	if new_unit != null:
		unit = new_unit
		animation = unit
		visible = true
	else:
		visible = false

func _on_area_mouse_entered():
	parent.hovering_unit = unit

func _on_area_mouse_exited():
	parent.hovering_unit = null
