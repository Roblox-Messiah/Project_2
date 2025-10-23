extends Control

func _ready():
	$VBoxContainer/StartButton.pressed.connect(_on_start_button_pressed)
	$VBoxContainer/NewGameButton.pressed.connect(_on_new_game_button_pressed)
	$VBoxContainer/TutorialButton.pressed.connect(_on_tutorial_button_pressed)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit_button_pressed)

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/UI/level_select.tscn")

func _on_new_game_button_pressed():
	
	# SaveManager.reset_progress()
	$ConfirmationPopup.popup_centered()

func _on_tutorial_button_pressed():
	
	get_tree().change_scene_to_file("res://scenes/levels/tutrorial.tscn")

func _on_exit_button_pressed():
	get_tree().quit()


func _on_confirmation_dialog_confirmed() -> void:
	SaveManager.reset_progress()
	print("Progress has been reset.")
