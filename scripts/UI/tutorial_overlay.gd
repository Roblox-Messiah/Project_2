extends CanvasLayer

@onready var main_text = $VBoxContainer/MainText

func _ready():
	# Start hidden
	hide()

func _unhandled_input(event):
	# Only listen for input if the overlay is visible
	if visible and event.is_action_pressed("Interact"):
		hide()
		get_tree().paused = false # Unpause the game

# This function is called by the trigger area
func show_message(text: String):
	main_text.text = text
	show()
	get_tree().paused = true # Pause the game
