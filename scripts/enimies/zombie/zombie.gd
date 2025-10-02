extends CharacterBody2D

# --- CONFIGURATION ---
@export var knockback_distance: float = 15.0
var target = null
var speed = 20
var health = 100
const BLOOD_PARTICLES = preload("res://scenes/particles/blood_particles.tscn")

# --- RESOURCES ---
const DEAD_TEXTURE = preload("res://Art/enemies/enemy_1/enemy_1_dead.png")
const DAMAGE_TEXTURE = preload("res://Art/enemies/enemy_1/enemy_1_damage.png")

# --- PRIVATE VARIABLES ---
var original_texture: Texture2D
var player_in_attack_range = false

# --- NODE REFERENCES ---
@onready var hurt_sound = $"hurt sound"
@onready var death_sound = $"death sound"
@onready var sprite_2d = $enemy_1/Sprite2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var attack_area = $AttackArea
@onready var attack_cooldown = $AttackCooldown



func _ready():
	# Store the zombie's default texture when it's created
	original_texture = sprite_2d.texture
	
	# Connect the AttackArea signals to their functions
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)

func _physics_process(delta: float) -> void:
	if target == null:
		return

	# --- MOVEMENT ---
	# The zombie will always try to move towards its target.
	look_at(target.global_position)
	var direction = global_position.direction_to(target.global_position)
	velocity = direction * speed
	move_and_slide()

	# --- ATTACK LOGIC ---
	# Independently, check if the player is in range and the cooldown is ready.
	if player_in_attack_range and attack_cooldown.is_stopped():
		attack(target)


# --- SIGNAL CALLBACKS ---
func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = body

func _on_attack_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_attack_range = true

func _on_attack_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_attack_range = false


# --- PUBLIC FUNCTIONS ---
func attack(player):
	attack_cooldown.start() # Start the attack cooldown timer
	if player.has_method("take_damage"):
		# Deal 10 damage and tell the player where the attack came from
		player.take_damage(20, global_position)

# This function is 'async' to allow the use of 'await' for the damage effect timer
func take_damage(amount: int, bullet):
	# Return if the zombie is already dead/dying
	if health <= 0:
		return
		
	health -= amount
	
	# AGGRO LOGIC: If we don't have a target, the bullet's owner becomes our new target.
	if target == null and "origin" in bullet and bullet.origin != null:
		target = bullet.origin
	
	if health <= 0:
		# --- DEATH LOGIC ---
		z_index = -1 # Move the dead body to a lower render layer
		set_physics_process(false)
		collision_shape_2d.set_deferred("disabled", true)
		
		# Rotate the sprite so its legs face the bullet that killed it.
		var direction_to_bullet = global_position.direction_to(bullet.global_position)
		sprite_2d.rotation = direction_to_bullet.angle() - (PI / 2)
		
		sprite_2d.texture = DEAD_TEXTURE
		death_sound.play()
		
		# Fade out the body and then delete it.
		var tween = create_tween()
		tween.tween_property(sprite_2d, "modulate:a", 0.0, 10.0).set_delay(5.0)
		tween.tween_callback(queue_free)
		
	else:
		# --- HURT LOGIC ---
		hurt_sound.play()
		# --- BLOOD SPRAY EFFECT ---
		# Create an instance of the blood particle scene
		var blood = BLOOD_PARTICLES.instantiate()
	
		# Add it to the main game world
		get_tree().root.add_child(blood)
	
		# Position the effect at the character's location
		blood.global_position = global_position
	
		# Point the spray away from the attacker/bullet
		var direction_from_attack = bullet.global_position.direction_to(global_position)
		blood.rotation = direction_from_attack.angle()
	
		# Start the particle emission
		blood.emitting = true

		# KNOCKBACK: Start the knockback animation
		var knockback_direction = bullet.global_position.direction_to(global_position)
		var target_position = global_position + (knockback_direction * knockback_distance)
		var knockback_tween = create_tween()
		knockback_tween.tween_property(self, "global_position", target_position, 0.1).set_ease(Tween.EASE_OUT)

		# DAMAGE VISUALS: Swap sprite and flash color at the same time
		sprite_2d.texture = DAMAGE_TEXTURE
		var flash_tween = create_tween()
		flash_tween.tween_property(sprite_2d, "modulate", Color(1.5, 1.5, 1.5, 1), 0.1)
		flash_tween.tween_property(sprite_2d, "modulate", Color(1, 1, 1, 1), 0.1)

		# Wait for the effect to be visible
		await get_tree().create_timer(0.2).timeout

		# Swap the texture back to the original if still alive
		if health > 0:
			sprite_2d.texture = original_texture
