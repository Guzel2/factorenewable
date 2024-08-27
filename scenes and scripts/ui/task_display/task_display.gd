extends Node2D

onready var parent = get_parent()
onready var text_display = find_node('text_display')

var containers = []

var hovering = false
var hovering_task = null

var task_entered = false
var task_exited = false

func _process(_delta):
	if task_entered:
		hovering = true
	elif task_exited:
		hovering = false
	
	task_entered = false
	task_exited = false

func update_tasks(task_num: int, new_value: float):
	if containers[task_num].value != new_value:
		containers[task_num].new_value(new_value)

func tasks_finished():
	text_display.visible = true

func tasks_not_finished():
	text_display.visible = false
	
