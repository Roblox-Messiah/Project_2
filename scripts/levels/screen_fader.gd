extends CanvasLayer

# This signal tells us when the fade-out is complete
signal fade_finished

@onready var animation_player = $AnimationPlayer

func _ready():
	# Automatically play the fade-in animation when any level starts
	fade_in()

func fade_in():
	animation_player.play("fade_in")

func fade_out():
	animation_player.play("fade_out")
	# Wait for the animation to finish before emitting our signal
	await animation_player.animation_finished
	fade_finished.emit()
