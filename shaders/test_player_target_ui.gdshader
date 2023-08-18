shader_type canvas_item;
render_mode blend_mul;

void fragment() {
	// Place fragment code here.
	COLOR = texture(TEXTURE, UV).rgba;
}
