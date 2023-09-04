
extends Node3D

@export var t0:float

# Called when the node enters the scene tree for the first time.
func _ready():
	t0 = 0.0
	await get_tree().create_timer(2.).timeout
	call_deferred("free")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$ring.set_instance_shader_parameter("time_param", t0)
	t0 += delta
