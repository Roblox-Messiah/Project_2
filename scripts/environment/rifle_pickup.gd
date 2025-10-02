extends Area2D

const RIFLE_SCENE = preload("res://scenes/weapons/assault_rifle.tscn")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("equip_weapon"):
		body.equip_weapon(RIFLE_SCENE) # tells player what to pickup
		queue_free() # pickup disappears
