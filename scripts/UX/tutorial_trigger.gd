extends Area2D

## Type the tutorial message here in the Inspector.
@export_multiline var tutorial_text: String = "This is a default message."

# This flag ensures the trigger only works once.
var has_triggered = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player") and not has_triggered:
		has_triggered = true
		
		# Find the tutorial overlay in the scene
		var overlay = get_tree().get_first_node_in_group("tutorial_overlay")
		if overlay:
			overlay.show_message(tutorial_text)
			# The trigger is done, so it removes itself.
			queue_free()
		else:
			print("ERROR: TutorialTrigger could not find a node in the 'tutorial_overlay' group.")
