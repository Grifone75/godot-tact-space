shader_type spatial;
render_mode blend_mix, unshaded, cull_disabled;

uniform sampler2D _FlowMap;
uniform sampler2D _NoiseMap;
uniform sampler2D _FlameColors : repeat_disable;
uniform float _ColorSelector;
instance uniform float _Seed = 0.5;
instance uniform float _Throttle = 0.1;



void fragment() {
	
	float throttled_speed = 2.; //(1+_Throttle*2)*.5;
    vec2 seed2 = vec2(_Seed, _Seed+.21568);
    vec2 flow_vector = vec2(0,TIME);
    vec2 flow = texture(_FlowMap,vec2(UV+flow_vector+seed2)).rg;
    vec2 unperturbed_uv = 1.-UV;
	
	float throttled_v =  unperturbed_uv.y / (_Throttle+0.1);
    vec2 perturbed_uv_h = (1.-UV) + flow*(0.03 + _Throttle*.5);
    vec2 perturbed_uv = (1.-UV) + flow*0.03;

    float vertical_v_scaler = 1.8;

    vec3 noise = texture(_NoiseMap,perturbed_uv+seed2+vec2(0,-TIME*throttled_speed)).rgb;
    float flame_spikes = .8*smoothstep(.4,.6,noise.x);
	
	float on = smoothstep(0,0.001,_Throttle);

    //plume fades out as it goes far from the nozzle
    float tail_fadeout = 1.-smoothstep(.2,.5,unperturbed_uv.y);

    //plume is transparent near the nozzle when throttle is low
    float f_in_threshold = (1.-_Throttle)*0.08;
    float tail_fadein = smoothstep(f_in_threshold,f_in_threshold+.3,unperturbed_uv.y);
	
    float perturbed_throttled_presence = 1.-smoothstep(_Throttle-.2,_Throttle+.5,perturbed_uv_h.y*vertical_v_scaler);
    float flame_presence = smoothstep(_Throttle-.1,_Throttle+.1,perturbed_uv_h.y*vertical_v_scaler)-smoothstep(_Throttle,_Throttle+.4,perturbed_uv_h.y);
    float final_presence = flame_presence*flame_spikes+perturbed_throttled_presence;
    vec3 flame_color = texture(_FlameColors, vec2(throttled_v*.5*vertical_v_scaler,_ColorSelector)).rgb;
	
// ColorConstant:2
	vec4 n_out2p0 = vec4(0.337461, 0.656338, 0.900241, 1.000000);

    float color_boost = 2.5;
    float alpha_dim = 0.5;

    vec4 col = vec4(flame_color*color_boost*on,final_presence*alpha_dim*on*tail_fadeout*tail_fadein);  

// Output:0
	ALBEDO = col.rgb * 1.5;
	ALPHA = col.a*.1;
	


}
