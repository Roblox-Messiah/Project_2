extends StaticBody2D

# This will hold a reference to the player when they are in range
var player_in_area = null

# These optional textures can be set in the Inspector
@export var locked_texture: Texture2D
@export var unlocked_texture: Texture2D

@onready var sprite_2d = $Sprite2D
@onready var collision_shape_2d = $CollisionShape2D

func _ready():
	# Connect the signals from the InteractionArea
	$InteractionArea.body_entered.connect(_on_interaction_area_body_entered)
	$InteractionArea.body_exited.connect(_on_interaction_area_body_exited)
	
	# Set the initial sprite if one is provided
	if locked_texture:
		sprite_2d.texture = locked_texture

func _process(_delta):
	# Every frame, check if the player is in the area and presses the interact button
	if player_in_area and Input.is_action_just_pressed("Interact"):
		# Check if the player has the key
		if player_in_area.has_key:
			unlock()
		else:
			print("Door is locked!")
			# Optional: Play a "locked" sound or show a message
			# $LockedSound.play()

func unlock():
	# Disable the physical collision so the player can pass through
	collision_shape_2d.set_deferred("disabled", true)
	
	# Change the sprite to the unlocked version if it exists
	if unlocked_texture:
		sprite_2d.texture = unlocked_texture
	
	# Play an unlock sound
	# $UnlockSound.play()
	
	# Stop script from running any more checks
	set_process(false)

func _on_interaction_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = body

func _on_interaction_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = null
