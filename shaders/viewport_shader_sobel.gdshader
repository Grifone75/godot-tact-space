shader_type canvas_item;

void fragment() {
	float px = SCREEN_PIXEL_SIZE.x * 2.;
	float py = SCREEN_PIXEL_SIZE.y * 2.;
    vec3 col = texture(TEXTURE, UV).xyz * 0.16;
    col += texture(TEXTURE, UV + vec2(px, 0.0)).xyz * 0.15;
    col += texture(TEXTURE, UV + vec2(-px, 0.0)).xyz * 0.15;
    col += texture(TEXTURE, UV + vec2(2.0 * px, 0.0)).xyz * 0.12;
    col += texture(TEXTURE, UV + vec2(2.0 * -px, 0.0)).xyz * 0.12;
    col += texture(TEXTURE, UV + vec2(3.0 * px, 0.0)).xyz * 0.09;
    col += texture(TEXTURE, UV + vec2(3.0 * -px, 0.0)).xyz * 0.09;
    col += texture(TEXTURE, UV + vec2(4.0 * px, 0.0)).xyz * 0.05;
    col += texture(TEXTURE, UV + vec2(4.0 * -px, 0.0)).xyz * 0.05;
    	
	col += texture(TEXTURE, UV).xyz * 0.16;
    col += texture(TEXTURE, UV + vec2(0.0, py)).xyz * 0.15;
    col += texture(TEXTURE, UV + vec2(0.0, -py)).xyz * 0.15;
    col += texture(TEXTURE, UV + vec2(0.0, 2.0 * py)).xyz * 0.12;
    col += texture(TEXTURE, UV + vec2(0.0, 2.0 * -py)).xyz * 0.12;
    col += texture(TEXTURE, UV + vec2(0.0, 3.0 * py)).xyz * 0.09;
    col += texture(TEXTURE, UV + vec2(0.0, 3.0 * -py)).xyz * 0.09;
    col += texture(TEXTURE, UV + vec2(0.0, 4.0 * py)).xyz * 0.05;
    col += texture(TEXTURE, UV + vec2(0.0, 4.0 * -py)).xyz * 0.05;
    COLOR.xyz = col/2.0;
}

