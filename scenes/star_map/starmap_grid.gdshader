shader_type spatial;


void vertex()
{
	//VERTEX = (PROJECTION_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment()
{

	vec2 uv = UV*50.0;
	
	vec2 uv2 = UV*5.0;
	
	bool tx = fract(abs(uv.x)) < 0.05;
	bool ty = fract(abs(uv.y)) < 0.05;
	float tcomb = float(tx || ty);
	
	float txx = 1.0 - (smoothstep(0.0,0.02,fract(abs(uv.x))) - smoothstep(0.98,1.0,fract(abs(uv.x))));
	float tyy = 1.0 - (smoothstep(0.0,0.02,fract(abs(uv.y))) - smoothstep(0.98,1.0,fract(abs(uv.y))));
	
	float txx2 = 1.0 - (smoothstep(0.0,0.03,fract(abs(uv2.x))) - smoothstep(0.997,1.0,fract(abs(uv2.x))));
	float tyy2 = 1.0 - (smoothstep(0.0,0.03,fract(abs(uv2.y))) - smoothstep(0.997,1.0,fract(abs(uv2.y))));

    ALBEDO = vec3((txx+tyy)+(txx2+tyy2));
	ALPHA = 1.0;
}