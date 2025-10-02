extends CanvasLayer

@onready var ammo_label = $Label

func _ready() -> void:
	var gun = get_tree().get_first_node_in_group("gun")
	if gun:
		update_ammo_text(gun.current_ammo, gun.reserve_ammo)
		gun.ammo_changed.connect(update_ammo_text)
	else:
		print("UI Error: gun node not found in group 'gun'.")
		
func update_ammo_text(current, reserve):
	ammo_label.text = "%s / %s" % [current, reserve]
