extends Node3D

@export var docking_port: Node3D
@export var dock_alignment_reference: Node3D
@export var dock_alignment_reference_anti: Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	$alignment_point/origin_shiftable.set_active(false)

func set_taken():
	docking_port._open_arm()

	
func set_free():
	docking_port._close_arm()


func get_alignment_point():
	return $alignment_point


func get_dockport_reference(direction_in = true):
	if direction_in:
		return dock_alignment_reference
	else:
		return dock_alignment_reference_anti

func switch_reference_visual(on = true):
	$alignment_point.visible = on
