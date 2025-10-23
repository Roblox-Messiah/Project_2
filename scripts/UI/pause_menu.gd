# PauseMenu.gd
extends CanvasLayer

func _ready():
	# Hide the menu initially
	hide()
	# Connect button signals
	$VBoxContainer/ContinueButton.pressed.connect(toggle_pause)
	$VBoxContainer/RestartButton.pressed.connect(_on_restart_button_pressed)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit_button_pressed)

func _unhandled_input(event):
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

func toggle_pause():
	# Invert the paused state
	get_tree().paused = not get_tree().paused
	# Show or hide the menu based on the paused state
	visible = get_tree().paused

func _on_restart_button_pressed():
	# Unpause before reloading to avoid issues
	get_tree().paused = false
	# Reload the current scene
	get_tree().reload_current_scene()

func _on_exit_button_pressed():
	# Unpause before changing scenes
	get_tree().paused = false
	# Go back to the level select screen (adjust path if needed)
	get_tree().change_scene_to_file("res://scenes/UI/level_select.tscn")
