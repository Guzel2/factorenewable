extends TextureButton

onready var text_display = find_node('text_display')

export var number = 0

var hovering = false

func _ready():
	text_display.text = String(number)

func _process(_delta):
	if pressed and hovering:
		text_display.modulate = Color8(143, 143, 143)
	else:
		text_display.modulate = Color8(184, 184, 184)


func _on_level_mouse_entered():
	hovering = true

func _on_level_mouse_exited():
	hovering = false
