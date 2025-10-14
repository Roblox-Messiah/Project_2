extends Area2D

@onready var key_pickup_sound = $"Key Pickup Sound"
@onready var sprite_2d = $Sprite2D
@onready var collision_shape_2d = $CollisionShape2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Prevent the key from being picked up multiple times
		collision_shape_2d.set_deferred("disabled", true)

		body.has_key = true
		print("Player picked up the key!")
		
		# Play the sound effect
		key_pickup_sound.play()
		
		# Make the key's visuals disappear immediately
		sprite_2d.hide()
		
		# Wait for the sound to finish before deleting the key node
		await key_pickup_sound.finished
		
		queue_free()
