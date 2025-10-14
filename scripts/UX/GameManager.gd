extends Node

func _ready():
	# Wait one frame to ensure the player and UI are ready
	await get_tree().process_frame

	var player = get_tree().get_first_node_in_group("player")
	var key_ui = get_tree().get_first_node_in_group("key_ui") # Make sure your KeyUI is in this group
	
	if player and key_ui:
		# When the key status changes, call the UI's functions
		player.key_status_changed.connect(
			func(has_the_key):
				if has_the_key:
					key_ui.show_key()
				else:
					key_ui.hide_key()
		)
	else:
		print("GameManager Error: Player or KeyUI not found.")
