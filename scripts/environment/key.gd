extends Area2D

func _on_body_entered(body):
	# Check if the node that entered is in the "player" group
	if body.is_in_group("player"):
		body.has_key = true
		
		# Play a pickup sound here
		# $PickupSound.play()
		
		# Remove the key from the scene
		queue_free()
