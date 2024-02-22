/*BetterGlas.gdshader*/
shader_type spatial;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;


render_mode depth_draw_always, specular_disabled, shadows_disabled, cull_front, ambient_light_disabled, unshaded;


uniform float distortion_size = 0.4;
uniform sampler2D glass;

void fragment() {
	vec2 d = texture(glass, UV).xy - vec2(0.5);
	vec4 bg = texture(SCREEN_TEXTURE, SCREEN_UV + d * distortion_size);
	ALBEDO = bg.rgb;
	//ALBEDO = texture(SCREEN_TEXTURE, SCREEN_UV + d * distortion_size).rgb;
}