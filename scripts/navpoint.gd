extends Node3D

var initial_position

	
func update_label(value):
	$Label3D.text = str(value)


func _ready():
	global_position = initial_position
	$Draw3D.circle_XZ()
	$Draw3D.cube()
