extends Node2D

## The scene of the item you want to spawn (e.g., Key.tscn).
@export var item_scene: PackedScene

## The name of the group for the spawn points (e.g., "key_spawns").
@export var spawn_point_group: String

func _ready():
	print("=== ITEM SPAWNER DEBUG ===")
	print("Item Scene assigned: ", item_scene != null)
	print("Spawn point group: ", spawn_point_group)
	
	if not item_scene:
		push_error("ItemSpawner: No item_scene assigned in Inspector!")
		return
		
	if spawn_point_group.is_empty():
		push_error("ItemSpawner: No spawn_point_group string set in Inspector!")
		return
	
	var spawn_points = get_tree().get_nodes_in_group(spawn_point_group)
	print("Found ", spawn_points.size(), " spawn points in group '", spawn_point_group, "'")
	
	if spawn_points.is_empty():
		push_error("ItemSpawner: No nodes found in group '", spawn_point_group, "'!")
		push_error("Make sure you have Marker2D nodes added to this group!")
		return
	
	# Pick a random spawn point
	var random_spawn_point = spawn_points[randi() % spawn_points.size()]
	print("Selected spawn point: ", random_spawn_point.name, " at position ", random_spawn_point.global_position)
	
	# Create the item
	var item_instance = item_scene.instantiate()
	
	# Add the item to the level FIRST
	get_parent().add_child.call_deferred(item_instance)
	
	# THEN set its position
	item_instance.global_position = random_spawn_point.global_position
	
	print("Item spawned successfully at: ", item_instance.global_position)
	print("=== END DEBUG ===")
	
	# Remove the spawner
	queue_free()
