shader_type spatial;

uniform sampler2D pnoise;

void fragment() {
	// Place fragment code here.
	vec3 noise = texture(pnoise, UV).rgb;
	float brightness = pow(noise.r, 4.0);
	vec3 col = mix(vec3(1.0,0.6,0.1), vec3(1.0,0.2,0.0), noise.g);
	ALBEDO = vec3(col * brightness);
	
}
