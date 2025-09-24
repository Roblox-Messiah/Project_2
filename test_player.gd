# TestPlayer.gd
extends CharacterBody2D

func _physics_process(delta: float) -> void:
	# Get directional input
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Set the player's speed
	velocity = direction * 80
	
	
	move_and_slide()
