extends Node2D

onready var parent = get_parent()
onready var bg = find_node('bg')
onready var text_display = find_node('text_display')

var top_left_offset = Vector2(64, 64)
var step_num = 4

var active = false

var positions_and_scales = [
	[Vector2(-150, -136), Vector2(300, 47)], #ressource display
	[Vector2(150, -136), Vector2(90, 75)], #unit display
	[Vector2(150, -64), Vector2(90, 39)], #more unit info
	[Vector2(-240, -136), Vector2(480, 272)], #the full screen thing
	[Vector2(-32, -32), Vector2(64, 64)], # HQ highlight
	[Vector2(-16, -16), Vector2(196, 80)], # place conveyor
	[Vector2(-32, -32), Vector2(224, 112)], # expand the srap producton
	[Vector2(-240, -136), Vector2(90, 27)], # task
	[Vector2(-112, -96), Vector2(112, 112)], # last hint
	[Vector2(-240, -136), Vector2(480, 272)], #finishd
]

var descriptions = [
	'In this area you can see all the ressources currently stored in the headquarters (HQ). You need them to build units.                        (Click to continue)',
	'Select the unit you want to place from here. Try selecting the conveyor in the top left.',
	'Click here to see more details about the selected unit.',
	'',
	'This is your Headquarters (HQ). Your ressources are stored here.',
	'Try connecting these two conveyors to build a working ressource chain. Hint: Rotate Conveyors using the mouse wheel.',
	'Expand your scrap production by building and connecting more Recyclers. Hint: Copy placed units by pressing mouse wheel.',
	'Your tasks for the level are displayed here. Complete these to progress.',
	'One last hint: Use right click to deconstruct misplaced buildings (like this conveyor) and use WASD to move the camera.',
	''
]

func go_to_next_position():
	visible = true
	move_bg_to(positions_and_scales[step_num][0], positions_and_scales[step_num][1])
	text_display.text = descriptions[step_num]
	step_num += 1

func move_bg_to(pos: Vector2, size: Vector2):
	bg.scale = size
	bg.position = pos - (top_left_offset)*bg.scale
	
	text_display.margin_left = pos.x
	text_display.margin_right = pos.x + size.x
	text_display.margin_top = pos.y + size.y + 1
