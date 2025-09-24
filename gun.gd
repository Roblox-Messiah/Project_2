extends Node2D

const BULLET = preload("res://bullet.tscn")
const BULLET_CASING = preload("res://bullet_casing.tscn") # Load the bullet casing scene
@onready var muzzle: Marker2D = $Marker2D

@onready var shoot_sound = $AudioStreamPlayer
@onready var fire_rate_timer = $Timer

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())

	if Input.is_action_pressed("shoot") and fire_rate_timer.is_stopped():
		fire_rate_timer.start()
		shoot_sound.play()

		# --- Bullet Spawning Logic ---
		var bullet_instance = BULLET.instantiate()
		bullet_instance.origin = self #tells the bullet who shot it
		
		get_tree().root.add_child(bullet_instance)
		bullet_instance.global_position = muzzle.global_position
		bullet_instance.rotation = rotation

		# --- Bullet Casing Ejection Logic ---
		var bullet_casing_instance = BULLET_CASING.instantiate()
		get_tree().root.add_child(bullet_casing_instance)
		bullet_casing_instance.global_position = global_position # Start at the gun's pivot point

		# Give the casing a push to make it fly out
		var eject_direction = Vector2.LEFT.rotated(rotation) # Eject to the gun's left
		var eject_strength = randf_range(75.0, 125.0)     # Randomize the force
		var spin = randf_range(-30.0, 30.0)                 # Randomize the spin
		
		bullet_casing_instance.apply_impulse(eject_direction * eject_strength)
		bullet_casing_instance.apply_torque_impulse(spin)
