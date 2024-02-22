extends Node

@export var shift_scale = 1.0
@export var connected_shiftable:Node
@export var is_active:bool = true
# Called when the node enters the scene tree for the first time.
func _ready():
	if not connected_shiftable:
		connected_shiftable = get_parent()


func do_origin_shift(shift_value):
	if is_active:
		if connected_shiftable.has_method("manage_origin_shift"):
			connected_shiftable.manage_origin_shift(shift_value/shift_scale)
		else:
			connected_shiftable.global_position -= shift_value/shift_scale

func set_active(flag):
	is_active = flag
