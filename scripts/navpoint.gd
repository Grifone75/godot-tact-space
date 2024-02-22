@tool
extends Node3D

var initial_position

	
func update_label(value):
	$Label3D.text = str(value)


func _ready():
	if initial_position:
		global_position = initial_position
	$Draw3D.circle_XZ()
	$Draw3D.cube()
	$Label3D.text = str(self.name)

func redraw():
	$Draw3D.clear()
	$Draw3D.circle_XZ()
	$Draw3D.cube()
	$Label3D.text = str(self.name)

