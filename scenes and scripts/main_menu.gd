extends Node2D

onready var parent = get_parent()
onready var camera = find_node('camera')
onready var button_continue = find_node('continue')
onready var button_tutorial = find_node('tutorial')
onready var button_levels = find_node('levels')
onready var button_credits = find_node('credits')

var button_base_pos = Vector2(-47, -50)

var has_save = false

func enter():
	for x in range(1, 5):
		if parent.gameplay.read_file(parent.gameplay.save_path + String(x) + '.dat') != null:
			has_save = true
			break
	
	visible = true
	set_process(true)
	camera.current = true
	
	var buttons_to_place = [button_tutorial, button_levels, button_credits]
	
	if has_save:
		button_continue.visible = true
		buttons_to_place.push_front(button_continue)
	else:
		button_continue.visible = false
	
	var x = 0
	for button in buttons_to_place:
		button.rect_position = button_base_pos + Vector2(0, x*35)
		x += 1

func exit():
	visible = false
	set_process(false)
	camera.current = false

func _on_continue_pressed():
	exit()
	parent.level_select.enter()
	parent.level_select.continue_level = true

func _on_tutorial_pressed():
	exit()
	parent.gameplay.set_level(0, false)
	parent.gameplay.enter()
	parent.gameplay.player.tutorial.step_num = 0
	parent.gameplay.player.tutorial.go_to_next_position()
	parent.gameplay.player.tutorial.active = true

func _on_levels_pressed():
	exit()
	parent.level_select.enter()
	parent.level_select.continue_level = false


func _on_credits_pressed():
	exit()
	parent.credits_menu.enter()
