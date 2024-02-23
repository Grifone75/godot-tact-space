extends Node

@export var linked_object: Node
@export var linked_rb: Node
@export var object_space_scale = 1.0
@export var contact_type = "unknown"
# Called when the node enters the scene tree for the first time.
func _ready():
	if not linked_object:
		linked_object = get_parent()

func set_linked_object(obj):
	linked_object = obj
	return self

func set_linked_rb(obj):
	linked_rb = obj
	return self

func set_type(type_name):
	contact_type = type_name
	return self

func set_space_scale(scale):
	object_space_scale = scale
	return self

func get_local_space_position():
	if linked_rb: 
		return linked_rb.global_position * object_space_scale
	return linked_object.global_position * object_space_scale

func get_linked_object():
	return linked_object
	
func get_contact_type():
	return contact_type
