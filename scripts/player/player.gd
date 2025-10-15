extends CharacterBody2D

signal took_damage
signal key_status_changed(has_key)
@onready var sprite_2d = $Marker2D/Sprite2D
@onready var weapon_holder = $WeaponHolder
var current_weapon_node = null
@onready var rotation_pivot = $Marker2D
@onready var collision_shape_2d = $CollisionShape2D # Get a reference to the collision shape
@onready var invincibility_timer = $InvincibilityTimer
@onready var hurt_sound = $player_hurt_sound
@onready var death_sound = $player_death_sound
@onready var health_bar = get_tree().get_first_node_in_group("ui_healthbar")
const DEAD_TEXTURE = preload("res://Art/player/player_dead.png")
const BLOOD_PARTICLES = preload("res://scenes/particles/blood_particles.tscn")
const PISTOL_SCENE = preload("res://scenes/weapons/gun.tscn")
const RIFLE_SCENE = preload("res://scenes/weapons/assault_rifle.tscn")
const PISTOL_PLAYER_TEXTURE = preload("res://Art/player/player_pistol.png")
const RIFLE_PLAYER_TEXTURE = preload("res://Art/player/player_assault_rifle.png")


# --- PLAYER STATS ---
@export var health: int = 100
@export var max_health: int = 100
@export var knockback_distance: float = 50.0
var has_key = false:
	set(value):
		has_key = value
		key_status_changed.emit(has_key)

func _ready() -> void:
	equip_weapon(PISTOL_SCENE)
	print("h")

func _physics_process(_delta: float) -> void:
	# --- MOVEMENT ---
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down") # Get directional input
	velocity = direction * 80 # Set the player's speed
	move_and_slide()

func take_damage(amount: int, attacker_position: Vector2):
	# 1. If the player is already invincible or dead, do nothing.
	if not invincibility_timer.is_stopped() or health <= 0:
		return

	# 2. Subtract health first to see if this hit is fatal.
	health -= amount
	print("Player was hit! Health is now: ", health)
	
	# Tell the health bar to update
	if health_bar:
		health_bar.update_health(health, max_health)


	# 3. Check if the player has died.
	if health <= 0:
		# --- DEATH LOGIC ---
		# Only run the death sequence.
		death_sound.play()
		z_index = -1 # Move the dead body to a lower render layer
		
		set_physics_process(false)
		if rotation_pivot: # Check if the node exists before using it
			rotation_pivot.set_process(false)
		
		collision_shape_2d.set_deferred("disabled", true)
		if current_weapon_node:
			current_weapon_node.set_process(false)
		
		sprite_2d.texture = DEAD_TEXTURE
		var direction_to_attacker = global_position.direction_to(attacker_position)
		rotation = direction_to_attacker.angle() - (PI / 2)
		
		# Use 'await' to wait for the timer without needing 'async'
		await get_tree().create_timer(2.0).timeout
		get_tree().reload_current_scene()
		
	else:
		# --- HURT LOGIC ---
		# The player was hurt but is still alive. Run all hurt effects.
		
		# A. Start the invincibility timer.
		invincibility_timer.start()
		
		# B. Play the hurt sound and emit the signal.
		hurt_sound.play()
		took_damage.emit()
		
		# C. Create all visual and physics effects.
		
		# BLOOD SPRAY
		var blood = BLOOD_PARTICLES.instantiate()
		get_tree().root.add_child(blood)
		blood.global_position = global_position
		var direction_from_attack = attacker_position.direction_to(global_position)
		blood.rotation = direction_from_attack.angle()
		blood.emitting = true
		
		# DAMAGE FLASH (Combined Red Tint + Invincibility Blink)
		var flash_tween = create_tween().set_loops(2) # Loop the flash twice for invincibility
		# Flash to a bright red tint
		flash_tween.tween_property(sprite_2d, "modulate", Color(2, 1, 1, 0.3), 0.25)
		# Animate back to the normal color
		flash_tween.tween_property(sprite_2d, "modulate", Color(1, 1, 1, 1), 0.25)
		
		# KNOCKBACK
		var knockback_direction = attacker_position.direction_to(global_position)
		var target_position = global_position + (knockback_direction * knockback_distance)
		var knockback_tween = create_tween()
		knockback_tween.tween_property(self, "global_position", target_position, 0.2).set_ease(Tween.EASE_OUT)

func equip_weapon(weapon_scene):
	if current_weapon_node: # gets rid of weapon if there is one
		current_weapon_node.queue_free()
	
	if weapon_scene == PISTOL_SCENE:
		$Marker2D/Sprite2D.texture = PISTOL_PLAYER_TEXTURE
	elif weapon_scene == RIFLE_SCENE:
		$Marker2D/Sprite2D.texture = RIFLE_PLAYER_TEXTURE
