extends RigidBody2D

func _on_timer_timeout():
	queue_free() # Delete the casing when the timer runs out.
