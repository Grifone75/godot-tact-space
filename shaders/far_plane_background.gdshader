shader_type sky;

uniform sampler2D background_planets;
uniform sampler2D equirect_nebula;
uniform sampler3D noise_stars;
uniform sampler3D noise_stars_filter2;
uniform sampler2D ui;

void sky() {
	// Place fragment code here.
	vec3 stars0 = texture(noise_stars, EYEDIR).rgb;
	float starfield = texture(noise_stars_filter2, EYEDIR).r;
	float stars_filter = (smoothstep(.87,.95,texture(noise_stars, EYEDIR*10.0).r) + 
		smoothstep(.88,.95,texture(noise_stars, EYEDIR*10.0+vec3(2.5,3.8,0.4)).r)) * 
		starfield ;
	float spectrum = texture(noise_stars, EYEDIR*5.0 + vec3(2.0,3.1,5.4)).g;
	vec3 color = vec3(1.0,0.2,0.2)*(1.0-smoothstep(0.35,0.4,spectrum)) + 
		vec3(1.0,1.0,1.0)*(smoothstep(0.35,0.4,spectrum)-smoothstep(0.6,0.65,spectrum)) +
		vec3(0.2,0.2,1.0)*(smoothstep(0.6,0.65,spectrum));
	
	stars0 = (stars0*color * stars_filter) * 5.0 + vec3(0.0,0.001,0.002) * starfield * stars0.r;
	vec4 cplanets = texture(background_planets,SCREEN_UV);
	vec4 cnebula = texture(equirect_nebula,SKY_COORDS);
	
	vec3 cbackground = (1.0 - cnebula.a) * stars0 + cnebula.a * cnebula.rgb;
	
	vec4 ui_col = texture(ui,SCREEN_UV);
	//(1.-cplanets.a) * cbackground + cplanets.a * cplanets.rgb;
	// vec3(cplanets.a,.0,.0);
	// cnebula.rgb;
	float scanline = abs(sin(SCREEN_UV.y*600.0+TIME*2.0))+0.3;
	COLOR = (1.-cplanets.a) * cbackground + cplanets.a * cplanets.rgb + ui_col.rgb*3.0*ui_col.a*scanline;
	
}
