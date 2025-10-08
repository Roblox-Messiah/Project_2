extends Node2D

# --- WEAPON RESOURCES ---
const BULLET = preload("res://scenes/weapons/bullets/bullet.tscn")
const BULLET_CASING = preload("res://scenes/weapons/bullets/bullet_casing.tscn")

# --- NODE REFERENCES ---
@onready var shoot_sound = $AudioStreamPlayer
@onready var empty_sound = $"empty sound"
@onready var reload_sound: AudioStreamPlayer2D = $"reload sound"
@onready var reload_empty_sound = $"reload_empty_sound"
@onready var fire_rate_timer = $Timer
@onready var reload_timer = $ReloadTimer
@onready var muzzle = $Marker2D

# --- AMMO VARIABLES ---
@export var magazine_size: int = 15
@export var reserve_ammo: int = 90
var current_ammo: int

# --- STATE VARIABLES ---
var is_reloading = false

# This signal tells the UI when to update
signal ammo_changed(current, reserve)

func _ready():
	# --- DEBUGGING CODE ---
	print("--- DEBUGGING GUN SCENE ---")
	print("This script is running on the node named: '", name, "'")
	print("Its children are:")
	for child in get_children():
		print("- ", child.name)
	print("--- END DEBUG ---")
	# --- End of Debugging Code ---
	
	current_ammo = magazine_size
	ammo_changed.emit(current_ammo, reserve_ammo)

func _process(_delta: float) -> void:
	look_at(get_global_mouse_position())
	
	# --- Shooting Logic ---
	if Input.is_action_pressed("shoot") and fire_rate_timer.is_stopped() and not is_reloading:
		if current_ammo > 0:
			fire_rate_timer.start()
			shoot_sound.play()
			
			var bullet_instance = BULLET.instantiate()
			bullet_instance.origin = self
			get_tree().root.add_child(bullet_instance)
			bullet_instance.global_position = muzzle.global_position
			bullet_instance.rotation = rotation
			
			var bullet_casing_instance = BULLET_CASING.instantiate()
			get_tree().root.add_child(bullet_casing_instance)
			bullet_casing_instance.global_position = global_position
			var eject_direction = Vector2.LEFT.rotated(rotation)
			var eject_strength = randf_range(75.0, 125.0)
			var spin = randf_range(-30.0, 30.0)
			bullet_casing_instance.apply_impulse(eject_direction * eject_strength)
			bullet_casing_instance.apply_torque_impulse(spin)
			
			current_ammo -= 1
			ammo_changed.emit(current_ammo, reserve_ammo)
		else:
			# Play empty sound only once per trigger pull
			if Input.is_action_just_pressed("shoot"):
				empty_sound.play()
	
	# --- Reloading logic ---
	if Input.is_action_just_pressed("reload") and not is_reloading:
		reload()

func reload():
	if current_ammo < magazine_size and reserve_ammo > 0:
		is_reloading = true
		
		if current_ammo == 0:
			reload_timer.wait_time = 1.8 # Set a longer empty reload time
			reload_empty_sound.play()
		else:
			reload_timer.wait_time = 1.2 # Set the normal tactical reload time
			reload_sound.play()
		
		reload_timer.start()

func _on_reload_timer_timeout():
	var ammo_needed = magazine_size - current_ammo
	var ammo_to_move = min(ammo_needed, reserve_ammo)
	
	current_ammo += ammo_to_move
	reserve_ammo -= ammo_to_move
	
	is_reloading = false
	ammo_changed.emit(current_ammo, reserve_ammo)
