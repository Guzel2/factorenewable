extends Node2D

onready var parent = get_parent()
onready var camera = find_node('camera')

var level_buttons = []
var button_was_pressed = []

var level_amount = 2
var button_size = Vector2(50, 50)
var screen_half = 130

var continue_level = false

func _ready():
	var step_size = (screen_half*2 - button_size.x) / (level_amount - 1)
	
	for x in level_amount:
		var button = load("res://scenes and scripts/menu/level_button.tscn").instance()
		button.number = x+1
		add_child(button)
		level_buttons.append(button)
		button_was_pressed.append(false)
		
		button.rect_position = Vector2(-screen_half, -40) + Vector2(step_size*x, 0)

func _process(_delta):
	for button in level_buttons.size():
		if level_buttons[button].hovering == true:
			if level_buttons[button].pressed == true:
				button_was_pressed[button] = true
			elif button_was_pressed[button] == true:
				parent.gameplay.set_level(button+1, !continue_level)
				parent.gameplay.enter()
				exit()
				
				#if button+1 == 2:
				#	parent.gameplay.player.ui.unit_description.print_this_text('Each tree removes 0.05 CO2 per Second')
				
				button_was_pressed[button] = false
		else:
			button_was_pressed[button] = false

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
