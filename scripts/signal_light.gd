extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$light1.set_instance_shader_parameter("phase",0.0)
	$light2.set_instance_shader_parameter("phase",1.0)
	

