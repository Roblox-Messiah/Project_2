extends CanvasLayer

# Get a reference to the AnimationPlayer node
@onready var animation_player = $AnimationPlayer

func _unhandled_input(event):
	# If the overlay is visible and the player presses the "restart" action...
	if visible and event.is_action_pressed("restart"):
		# Unpause the game tree before reloading to avoid issues.
		get_tree().paused = false
		# Reload the current level.
		get_tree().reload_current_scene()

# This function will be called by the player when they die.
func show_overlay():
	show()
	# Pause the game to stop all action.
	get_tree().paused = true
	# Play the floating animation.
	animation_player.play("float") 
