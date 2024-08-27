extends Node2D

onready var label = find_node('label')

var active = false

var active_time = 5.0
var active_timer = active_time

func _process(delta):
	if active:
		active_timer -= delta
		position = get_global_mouse_position()
		
		modulate = Color(1, 1, 1, 1)
		
		if active_timer <= 1.0:
			modulate = Color(1, 1, 1, active_timer/1)
		
		if active_timer <= 0:
				active_timer = active_time
				active = false
