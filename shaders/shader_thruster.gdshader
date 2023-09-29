// NOTE: Shader automatically converted from Godot Engine 4.0.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;
uniform float point_size : hint_range(0,128);
uniform float roughness : hint_range(0,1);
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_aoch: filter_linear_mipmap,repeat_enable;
uniform sampler2D texture_emission: filter_linear_mipmap,repeat_enable;
uniform float specular;
uniform float metallic;
uniform sampler2D texture_normal : hint_roughness_normal,filter_linear_mipmap,repeat_enable;
uniform float normal_scale : hint_range(-16,16);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
uniform vec4 em_color : source_color;

instance uniform float _Thrust = 0.5;


void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
}


void fragment() {
	float color_mixer1 = smoothstep(0.05,0.09, _Thrust);
	float color_mixer2 = smoothstep(0.09,0.2, _Thrust);
	vec4 final_color = mix(vec4(0.2,0.02,0.0,1.0),mix(vec4(0.5,0.2,0.0,1.0),em_color,color_mixer2),color_mixer1);
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	vec4 aoch_tex = texture(texture_aoch,base_uv);
	vec4 em_tex = texture(texture_emission,base_uv);
	float em_mult = em_tex.r * 25. * _Thrust;
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	float metallic_tex = aoch_tex.g;
	METALLIC = metallic_tex * metallic;
	vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	float roughness_tex = 0.9;
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
	NORMAL_MAP = texture(texture_normal,base_uv).rgb;
	NORMAL_MAP_DEPTH = normal_scale;
	EMISSION = final_color.rgb * em_mult;
	ALPHA = aoch_tex.a * smoothstep(.1,.2,_Thrust);;
	AO = 1.-aoch_tex.r;
}
