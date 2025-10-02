extends CharacterBody2D

signal took_damage
@onready var sprite_2d = $Marker2D/Sprite2D
@onready var weapon_holder = $WeaponHolder
var current_weapon_node = null
@onready var rotation_pivot = $Marker2D
@onready var collision_shape_2d = $CollisionShape2D # Get a reference to the collision shape

@onready var hurt_sound = $player_hurt_sound
@onready var death_sound = $player_death_sound
const DEAD_TEXTURE = preload("res://Art/player/player_dead.png")
const BLOOD_PARTICLES = preload("res://scenes/particles/blood_particles.tscn")
const PISTOL_SCENE = preload("res://scenes/weapons/gun.tscn")
const RIFLE_SCENE = preload("res://scenes/weapons/assault_rifle.tscn")
const PISTOL_PLAYER_TEXTURE = preload("res://Art/player/player_pistol.png")
const RIFLE_PLAYER_TEXTURE = preload("res://Art/player/player_assault_rifle.png")


# --- PLAYER STATS ---
@export var health: int = 100
@export var knockback_distance: float = 50.0
var has_key = false

func _ready() -> void:
	equip_weapon(PISTOL_SCENE)

func _physics_process(delta: float) -> void:
	# --- MOVEMENT ---
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down") # Get directional input
	velocity = direction * 80 # Set the player's speed
	move_and_slide()

func take_damage(amount: int, attacker_position: Vector2):
	health -= amount
	took_damage.emit() # Announce that damage was taken
	hurt_sound.play()
	
	# --- BLOOD SPRAY EFFECT ---
	# Create an instance of the blood particle scene
	var blood = BLOOD_PARTICLES.instantiate()
	
	# Add it to the main game world
	get_tree().root.add_child(blood)
	
	# Position the effect at the character's location
	blood.global_position = global_position
	
	# Point the spray away from the attacker/bullet
	var direction_from_attack = attacker_position.direction_to(global_position)
	blood.rotation = direction_from_attack.angle()
	
	# Start the particle emission
	blood.emitting = true
	
	# --- DAMAGE FLASH ---
	var damage_tween = create_tween()
	damage_tween.tween_property(sprite_2d, "modulate", Color(2, 1, 1, 1), 0.1) # Flash to a bright red tint over 0.1 seconds
	damage_tween.tween_property(sprite_2d, "modulate", Color(1, 1, 1, 1), 0.1) # Animate back to the normal color over 0.1 seconds
	
	# --- KNOCKBACK ---
	var knockback_direction = attacker_position.direction_to(global_position)
	var target_position = global_position + (knockback_direction * knockback_distance)
	
	var knockback_tween = create_tween()
	knockback_tween.tween_property(self, "global_position", target_position, 0.2).set_ease(Tween.EASE_OUT)
	
	if health <= 0:
		death_sound.play()
		z_index = -1 # Move the dead body to a lower render layer
		
		# 1. Disable player controls and movement.
		set_physics_process(false)
		rotation_pivot.set_process(false)
		
		# 2. Disable the collision shape so enemies don't get stuck on the body.
		collision_shape_2d.set_deferred("disabled", true)
		if current_weapon_node:
			current_weapon_node.set_process(false)
		
		# 3. Change to the dead player sprite.
		sprite_2d.texture = DEAD_TEXTURE
		var direction_to_attacker = global_position.direction_to(attacker_position)
		rotation = direction_to_attacker.angle() - (PI / 2)
		
		# 4. Wait for 2 seconds before restarting.
		await get_tree().create_timer(2.0).timeout
		
		# 5. Reload the entire scene to restart the level.
		get_tree().reload_current_scene()

func equip_weapon(weapon_scene):
	if current_weapon_node: # gets rid of weapon if there is one
		current_weapon_node.queue_free()
	
	if weapon_scene == PISTOL_SCENE:
		$Marker2D/Sprite2D.texture = PISTOL_PLAYER_TEXTURE
	elif weapon_scene == RIFLE_SCENE:
		$Marker2D/Sprite2D.texture = RIFLE_PLAYER_TEXTURE
