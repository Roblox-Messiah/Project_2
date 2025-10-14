extends CanvasLayer

@onready var texture_rect = $TextureRect

func show_key():
	texture_rect.show()

func hide_key():
	texture_rect.hide()
