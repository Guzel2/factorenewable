extends Node2D

onready var gameplay = find_node('gameplay')
onready var main_menu = find_node('main_menu')
onready var level_select = find_node('level_select')
onready var credits_menu = find_node('credits_menu')

var hovering_task

func _ready():
	gameplay.exit()
	main_menu.enter()
