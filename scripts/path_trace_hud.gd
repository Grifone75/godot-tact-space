extends Node3D

@export var traced_vessel: Node3D

var trace_points = []
var vcolors = []
var trace_vpoints = []
var trace_length = 40
# Called when the node enters the scene tree for the first time.
func _ready():
	var color_start = Color.AQUAMARINE
	var color_stop = Color.BLACK
	color_stop.a = 0.0
	color_start.a = 0.02
	
	for c in range(35):
		vcolors.push_back(lerp(color_stop,color_start, c/34.0))
	
	for c in range(3):
		vcolors.push_back(lerp(color_start,color_stop,c/2.0))
	vcolors.push_back(color_stop)
	vcolors.push_back(color_stop)
	
	_sample_position()

func _sample_position():
	while true:
		if traced_vessel:
			trace_points.push_back(traced_vessel.global_position)
			if len(trace_points) > trace_length:
				trace_points.pop_front()
		var i = 0
		trace_vpoints = []
		for el in trace_points:
			trace_vpoints.push_back([el,vcolors[i]])
			i += 1
			
		await get_tree().create_timer(.2).timeout

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if len(trace_vpoints) > 1:
		$Draw3D.clear()
		$Draw3D.draw_line(trace_vpoints)
		#for el in trace_points:
		

func manage_origin_shift(shift):
	trace_points = trace_points.map(func(x): return x-shift)
		
