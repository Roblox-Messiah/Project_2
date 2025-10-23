# scenes/UI/level_select.gd
extends Control

@onready var back_button = $BackButton


func _ready():
	# Define the structure of your levels first
	var levels = {
		1: {"button_path": "HBoxContainer/Level1", "scene_path": "res://scenes/levels/room.tscn"},
		2: {"button_path": "HBoxContainer/Level2", "scene_path": "res://scenes/levels/level_2.tscn"}
		# Add more levels here, ensure paths are correct
		
	}

	for level_number in levels:
		var level_info = levels[level_number]
		
		# Get the actual button node *inside* _ready()
		var button_node = get_node(level_info.button_path)
		
		# Check if the button was found before trying to use it
		if not button_node:
			print("ERROR: Could not find button at path: ", level_info.button_path)
			continue # Skip to the next level in the loop

		# Now you can safely access the button's properties
		if SaveManager.is_level_unlocked(level_number):
			button_node.disabled = false
			button_node.text = "Level %s" % level_number
			# Connect the button's pressed signal
			button_node.pressed.connect(_on_level_button_pressed.bind(level_info.scene_path))
		else:
			button_node.disabled = true
			button_node.text = "Locked"
			# Optional: Change modulate for silhouette effect
			# button_node.modulate = Color(0.1, 0.1, 0.1, 0.7)

func _on_level_button_pressed(scene_path: String):
	get_tree().change_scene_to_file(scene_path)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
