extends Node2D

onready var parent = get_parent()
onready var label = find_node('label')
onready var sprite = find_node('sprite')

var active = false
var wait_time = 5
var wait_timer = wait_time

var base_offset
var ui_offset = Vector2(0, 46)

var ui_barriers = [Vector2(-220, -40), Vector2(220, 115)] #[Vector2(-100, -75), Vector2(100, 120)] center cube

func _ready():
	base_offset = position
	visible = false
	z_index = parent.get_parent().map_size_y

func set_warning_message(message: String):
	visible = true
	label.text = message
	active = true
	modulate = Color(1, 1, 1, 1)
	wait_timer = wait_time

func _process(delta):
	if active:
		if parent.on_screen:
			sprite.visible = false
			label.visible = true
			
			position = base_offset
			active = false
		else:
			sprite.visible = true
			label.visible = false
			
			var base_pos = -parent.position + parent.parent.player.position
			var dir = (parent.position - parent.parent.player.position)
			
			var rotated_dir = dir.rotated((90.0 + 22.5) /180.0*PI)
			var angle = rotated_dir.angle() * 180/PI
			if angle < 0:
				angle = 360.0 + angle
			var frame = floor(angle/45)
			sprite.frame = frame
			
			dir.x = clamp(dir.x, ui_barriers[0].x * parent.parent.player.scale.x, ui_barriers[1].x * parent.parent.player.scale.x)
			dir.y = clamp(dir.y, ui_barriers[0].y * parent.parent.player.scale.x, ui_barriers[1].y * parent.parent.player.scale.x)
			
			position = base_pos + dir
	else:
		if visible:
			if wait_timer >= 0:
				wait_timer -= delta
			else:
				var new_col = modulate
				new_col[3] -= delta
				modulate = new_col
				
				if new_col[3] <= 0:
					visible = false
