# TestDetector.gd
extends Area2D

func _on_body_entered(body):
	print("--- SUCCESS! Test Detector saw the body: ", body.name)
	if body.is_in_group("player"):
		print("--- SUCCESS! The body is in the 'player' group!")
