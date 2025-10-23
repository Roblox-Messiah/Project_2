extends Node

# This file will store our save data
const SAVE_FILE_PATH = "user://savegame.save"
var save_data = {
	"unlocked_levels": [1] # Start with only Level 1 unlocked
}

func _ready():
	load_game()

func save_game():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(save_data)
	print("Game saved!")

func load_game():
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		save_data = file.get_var()
		print("Game loaded!")
	else:
		print("No save file found. Starting fresh.")

func is_level_unlocked(level_number: int) -> bool:
	return level_number in save_data.unlocked_levels

func unlock_level(level_number: int):
	if not is_level_unlocked(level_number):
		save_data.unlocked_levels.append(level_number)
		save_game()

func reset_progress():
	save_data.unlocked_levels = [1]
	save_game()
