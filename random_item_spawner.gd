extends Node2D

## The scene of the item you want to spawn (e.g., Key.tscn).
@export var item_scene: PackedScene

## The name of the group for the spawn points (e.g., "key_spawns").
@export var spawn_point_group: String


func _ready():
	if not item_scene or spawn_point_group.is_empty():
		print("Spawner is not configured!")
		return

	var spawn_points = get_tree().get_nodes_in_group(spawn_point_group)
	
	if not spawn_points.is_empty():
		var random_spawn_point = spawn_points[randi() % spawn_points.size()]
		var item_instance = item_scene.instantiate()
		
		# Add the item to the level FIRST.
		get_parent().add_child(item_instance)
		
		# THEN, set its position.
		item_instance.global_position = random_spawn_point.global_position
		
		# NOW the spawner can safely remove itself.
