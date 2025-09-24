extends Camera2D

# Assign your player node to this in the Inspector
@export var target_node: Node2D

# How quickly the camera moves to its target. Higher values are faster.
@export var smoothing: float = 5.0

# How far the camera looks ahead towards the mouse.
# 0.0 = centered on player, 0.5 = halfway to the mouse.
@export var look_ahead_amount: float = 0.25

func _ready():
	# Make the camera the current active camera for the scene
	make_current()
	
	# Check if the target node (the player) exists and has the signal
	if target_node and target_node.has_signal("took_damage"):
		# If it does, connect our shake function to that signal
		target_node.took_damage.connect(shake)

func _process(delta: float) -> void:
	# Exit if no target is assigned to prevent crashes
	if not target_node:
		return
	
	# 1. Get the player and mouse positions
	var player_position = target_node.global_position
	var mouse_position = get_global_mouse_position()
	
	# 2. Calculate the "look-ahead" target position
	# This finds a point 25% of the way from the player to the mouse
	var target_position = player_position.lerp(mouse_position, look_ahead_amount)
	
	# 3. Smoothly move the camera to the target position
	# Using delta makes the movement frame-rate independent
	global_position = global_position.lerp(target_position, smoothing * delta)

func shake(intensity: float = 8.0, duration: float = 0.2):
	var timer = get_tree().create_timer(duration)
	
	while timer.time_left > 0:
		# Set the offset to a random position within a circle
		offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * intensity
		# Wait for the next frame
		await get_tree().process_frame
		
	# Reset the offset to zero when the shake is over
	offset = Vector2.ZERO
