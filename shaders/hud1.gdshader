shader_type canvas_item;

void fragment() {
	// Place fragment code here.
	float rad = .15;
	float edge = .0025;
	vec2 uvc = UV - vec2(.5,.5);
	float val = smoothstep(rad,rad+edge,uvc.x*uvc.x + uvc.y*uvc.y) - smoothstep(rad+edge,rad+2.0*edge,uvc.x*uvc.x + uvc.y*uvc.y);;
	COLOR = vec4(0.0,val,val*.8,val*.5);
}
