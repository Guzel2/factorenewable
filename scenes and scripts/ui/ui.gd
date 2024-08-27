extends Node2D

onready var parent = get_parent()
onready var ressource_display = $ressource_display
onready var unit_display = $unit_display
onready var task_display = find_node('task_display')
onready var task_description = find_node('task_description')
onready var selected_unit_display = find_node('selected_unit_display')
onready var unit_description = find_node('unit_description')

onready var area = find_node('area')
onready var area_col = area.find_node('col')

var standard_polygon

func _ready():
	standard_polygon = area_col.polygon

func _on_area_mouse_exited():
	parent.parent.mouse_in_ui = false

func _on_area_mouse_entered():
	parent.parent.mouse_in_ui = true


func print_line(text, margin_top):
	var text_display = load("res://scenes/text_display.tscn")
	var t = text_display.instance()
	t.text = text
	t.rect_position.y += margin_top
