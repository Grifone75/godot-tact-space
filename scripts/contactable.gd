extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func get_local_space_position():
	return self.get_parent().global_position * 10000.0
