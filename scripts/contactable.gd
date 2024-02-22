extends Node

@export var linked_object: Node
@export var object_space_scale = 1.0
# Called when the node enters the scene tree for the first time.
func _ready():
	if not linked_object:
		linked_object = get_parent()


func get_local_space_position():
	return linked_object.global_position * object_space_scale
