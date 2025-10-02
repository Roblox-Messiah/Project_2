
extends GPUParticles2D

func _ready():
	# When the particle system is finished emitting, delete it.
	finished.connect(queue_free)
