shader_type canvas_item;

uniform float fill_ratio = 1.0; // How full the bar is (0.0 to 1.0)
uniform vec2 velocity = vec2(0.0, 0.0); // Player's movement
uniform float slosh_speed = 8.0;
uniform float slosh_amount = 0.02;

void fragment() {
	// Get the surface level of the liquid (Horizontal Bar)
	float surface_x = fill_ratio;

	// Add a gentle, constant wave based on time
	surface_x -= sin(UV.y * 10.0 + TIME * slosh_speed) * slosh_amount;

	// Make the pixel transparent if it's to the right of the liquid surface
	if (UV.x > surface_x) {
		COLOR.a = 0.0;
	}
}