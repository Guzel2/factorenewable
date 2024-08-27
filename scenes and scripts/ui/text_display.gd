extends Label

onready var parent = get_parent()

var bitmap

export var height = 7

var all_letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.,:"!?/-1234567890 '

var wider_letters = 'MTVWYZmvwxz'
var thin_letters = 'Ifijklrt.,/1"'

var timer = 5.0
var space_size = 2

func set_text_to(new_text):
	text = new_text

func old_way_of_making_font():
	bitmap = BitmapFont.new()
	bitmap.add_texture(load("res://sprites/ui/font.png"))
	
	bitmap.set_height(height)
	bitmap.set_ascent(5)
	
	var x = 0
	
	for letter in all_letters:
		bitmap.add_char(ord(letter), 0 , Rect2(Vector2(x, 0), Vector2(5, 9)))
		bitmap.add_kerning_pair(ord(letter), ord(' '), space_size)
		bitmap.add_kerning_pair(ord(letter), ord('.'), space_size-1)
		x += 5
		
	
	for letter in wider_letters:
		for letter2 in all_letters:
			bitmap.add_kerning_pair(ord(letter), ord(letter2), -1)
		bitmap.add_kerning_pair(ord(letter), ord(' '), space_size-1)
		bitmap.add_kerning_pair(ord(letter), ord('.'), space_size-2)
	
	for letter in thin_letters:
		for letter2 in all_letters:
			bitmap.add_kerning_pair(ord(letter), ord(letter2), 1)
		bitmap.add_kerning_pair(ord(letter), ord(' '), space_size+1)
		bitmap.add_kerning_pair(ord(letter), ord('.'), space_size)
	
	theme = Theme.new()
	theme.default_font = bitmap
