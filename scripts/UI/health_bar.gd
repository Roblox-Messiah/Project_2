extends TextureProgressBar

@onready var liquid = $ColorRect as ColorRect

# These variables control the "jiggle" when health changes.
var health_visual: float = 100.0
var health_target: float =  100.0

func _process(delta):
	# Smoothly move the visual health towards the target health
	health_visual = lerp(health_visual, health_target, delta * 5.0)
	
	# Update the progress bar and the shader's fill ratio
	value = health_visual
	(liquid.material as ShaderMaterial).set_shader_parameter("fill_ratio", value / max_value)

# This public function is called by the player to update the health bar.
func update_health(current_health, max_health):
	health_target = current_health
	max_value = max_health
