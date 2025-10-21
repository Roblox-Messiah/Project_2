extends CharacterBody2D

# --- CONFIGURATION ---
@export var knockback_distance: float = 15.0
var target = null
var speed = 20
var health = 100

# --- RESOURCES ---
const DEAD_TEXTURE = preload("res://Art/enemies/enemy_1/enemy_1_dead.png")
const DAMAGE_TEXTURE = preload("res://Art/enemies/enemy_1/enemy_1_damage.png")
const BLOOD_PARTICLES = preload("res://scenes/particles/blood_particles.tscn")

# --- PRIVATE VARIABLES ---
var original_texture: Texture2D
var player_in_attack_range = false
var has_seen := false

# --- NODE REFERENCES ---
@onready var hurt_sound = $"hurt sound"
@onready var death_sound = $"death sound"
@onready var sprite_2d = $enemy_1/Sprite2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var attack_area = $AttackArea
@onready var attack_cooldown = $AttackCooldown
@onready var raycast = $Detection/RayCast2D


# --- GODOT FUNCTIONS ---
func _ready():
	original_texture = sprite_2d.texture
	#attack_area.body_entered.connect(_on_attack_area_body_entered)
	#attack_area.body_exited.connect(_on_attack_area_body_exited)

func _physics_process(_delta: float) -> void:
	if target == null:
		return

	# --- LINE OF SIGHT CHECK ---
	raycast.target_position = to_local(target.global_position)
	raycast.force_raycast_update()
	var can_see_player = false
	if raycast.is_colliding():
		var col = raycast.get_collider()
		if col == target:
			can_see_player = true
			if not has_seen:
				has_seen = can_see_player
		

	# --- ATTACK LOGIC ---
	# The zombie can only attack if it can see the player.
	if can_see_player and player_in_attack_range and attack_cooldown.is_stopped():
		attack(target)
	elif has_seen:
		# --- MOVEMENT LOGIC ---
		# The zombie will always move towards the target, regardless of line of sight.
		look_at(target.global_position)
		var direction = global_position.direction_to(target.global_position)
		velocity = direction * speed
		move_and_slide()


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


# --- PUBLIC & HELPER FUNCTIONS ---
func attack(player):
	attack_cooldown.start()
	if player.has_method("take_damage"):
		player.take_damage(25, global_position)

func take_damage(amount: int, bullet):
	if health <= 0:
		return
		
	health -= amount
	
	if target == null and "origin" in bullet and bullet.origin != null:
		target = bullet.origin
	
	if health <= 0:
		# --- DEATH LOGIC ---
		z_index = -1
		set_physics_process(false)
		collision_shape_2d.set_deferred("disabled", true)
		
		var direction_to_bullet = global_position.direction_to(bullet.global_position)
		sprite_2d.rotation = direction_to_bullet.angle() - (PI / 2)
		
		sprite_2d.texture = DEAD_TEXTURE
		death_sound.play()
		
		var tween = create_tween()
		tween.tween_property(sprite_2d, "modulate:a", 0.0, 10.0).set_delay(5.0)
		tween.tween_callback(queue_free)
		
	else:
		# --- HURT LOGIC ---
		hurt_sound.play()

		var blood = BLOOD_PARTICLES.instantiate()
		get_tree().root.add_child(blood)
		blood.global_position = global_position
		var direction_from_attack = bullet.global_position.direction_to(global_position)
		blood.rotation = direction_from_attack.angle()
		blood.emitting = true

		var knockback_direction = bullet.global_position.direction_to(global_position)
		var target_position = global_position + (knockback_direction * knockback_distance)
		var knockback_tween = create_tween()
		knockback_tween.tween_property(self, "global_position", target_position, 0.1).set_ease(Tween.EASE_OUT)

		var flash_tween = create_tween()
		flash_tween.tween_property(sprite_2d, "modulate", Color(1.5, 1.5, 1.5, 1), 0.1)
		flash_tween.tween_property(sprite_2d, "modulate", Color(1, 1, 1, 1), 0.1)
