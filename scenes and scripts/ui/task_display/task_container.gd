extends Sprite

onready var parent = get_parent()
onready var text_display =  find_node('text_display')
onready var progress_display =  find_node('progress_display')
onready var progress_bar = find_node('progress_bar')

var text

var starting_value
var target_value
var value

var finished = false

var task_num

func _ready():
	text_display.text = text
	new_value(starting_value)

func new_value(new_value):
	if new_value <= target_value:
		value = new_value
		progress_display.text = str(value) + '/' + str(target_value)
		
		progress_bar.scale.x = (value-starting_value)/(target_value-starting_value)
	elif !finished:
		finished = true
		progress_display.text = str(target_value) + '/' + str(target_value)
		progress_bar.scale.x = 1

func _on_area_mouse_exited():
	parent.task_exited = true

func _on_area_mouse_entered():
	parent.task_entered = true
	parent.hovering_task = task_num
