extends CharacterBody2D

const SPEED: int = 300
var origin = null

func _physics_process(delta: float) -> void:
	# Set the velocity to move the bullet forward along its current rotation.
	velocity = transform.x * SPEED 
	
	# Move the bullet and handle any collisions.
	move_and_slide()
	
	var collision: KinematicCollision2D = get_last_slide_collision()
	if collision:
		var collider = collision.get_collider() # Get the object we hit
		
		# Check if the object has the "take_damage" method and is in the "enemies" group
		if collider.is_in_group("enemies") and collider.has_method("take_damage"):
			collider.take_damage(25, self) # Tell the enemy to take 25 damage
			
		queue_free() # Destroy the bullet after any collision
	
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
