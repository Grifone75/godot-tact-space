shader_type sky;

uniform sampler2D background;


void sky() {
	// Place fragment code here.
	COLOR = texture(background,SCREEN_UV).rgb;
}
