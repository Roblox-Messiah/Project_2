class_name Teleporter
extends Area2D

## Assign the other teleporter to this in the Inspector.
@export var target_teleporter_path: NodePath

@onready var cooldown_timer = $"cooldown timer"
var target_teleporter: Area2D

func _ready():
	# Get the actual node from the path
	if not target_teleporter_path.is_empty():
		target_teleporter = get_node(target_teleporter_path)

	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player") and cooldown_timer.is_stopped():
		if not target_teleporter:
			print("Teleporter target not set!")
			return
		
		var fader = get_tree().get_first_node_in_group("screen_fader")
		
		if fader:
			fader.fade_out()
			await fader.fade_finished
			
			body.global_position = target_teleporter.global_position
			fader.fade_in()
			
			# Cast the target to the Teleporter script type before calling its function
			(target_teleporter as Teleporter).start_cooldown()
		else:
			body.global_position = target_teleporter.global_position
			(target_teleporter as Teleporter).start_cooldown()
			
func start_cooldown():
	cooldown_timer.start()
