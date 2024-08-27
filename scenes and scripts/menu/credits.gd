extends Node2D

onready var parent = get_parent()
onready var camera = find_node('camera')

func enter():
	visible = true
	set_process(true)
	camera.current = true

func exit():
	visible = false
	set_process(false)
	camera.current = false

func _on_back_pressed():
	exit()
	parent.main_menu.enter()
