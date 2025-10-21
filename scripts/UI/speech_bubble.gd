extends CanvasLayer

# Updated paths to reflect the HBoxContainer
@onready var label = $BubbleLayout/NinePatchRect/Label
@onready var background = $BubbleLayout/NinePatchRect
@onready var portrait = $BubbleLayout/Portrait # Add reference to portrait
@onready var display_timer = $DisplayTimer

func _ready():
	display_timer.timeout.connect(hide_bubble)

# You can optionally add logic to set the portrait texture here
func show_message(text: String, portrait_texture: Texture = null, duration: float = 3.0):
	label.text = text
	if portrait_texture:
		portrait.texture = portrait_texture
		portrait.show() # Make sure portrait is visible
	else:
		portrait.hide() # Hide portrait if no texture is provided

	display_timer.wait_time = duration
	show()
	display_timer.start()

func hide_bubble():
	visible = false
