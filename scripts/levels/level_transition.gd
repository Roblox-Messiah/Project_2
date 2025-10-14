extends Area2D

@export var next_level_path: String
var has_triggered = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player") and not has_triggered:
		has_triggered = true
		print("DEBUG: Player entered transition area. Trying to close door.")

		# Find the door in the scene
		var door = get_tree().get_first_node_in_group("level_door")
		if door:
			# Tell the door to close and WAIT here until it's done.
			await door.close_door()
			# After the door is closed, start the fade.
			start_fade()
		else:
			# If no door, start the fade immediately
			start_fade()

func start_fade():
	print("DEBUG: 'start_fade' function was called. Trying to fade out.")
	var fader = get_tree().get_first_node_in_group("screen_fader")
	if fader:
		# Connect to the fader's signal. When it's done, it will call 'change_level'.
		fader.fade_finished.connect(change_level)
		fader.fade_out()
	else:
		print("DEBUG: No fader found. Changing level immediately.")
		# If no fader, change the level immediately
		change_level()

func change_level():
	print("DEBUG: 'change_level' function was called. Changing scene.")
	if not next_level_path.is_empty():
		get_tree().change_scene_to_file(next_level_path)
