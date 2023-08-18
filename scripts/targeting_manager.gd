class_name Targeting_manager extends Resource


signal target

var current_target: Node3D


func set_target(n3):
	self.current_target = n3
	target.emit(current_target)

func get_wpos():
	if self.current_target == null:
		return null
	else:
		return current_target.global_position


func get_wvel():
	if self.current_target == null:
		return Vector3.ZERO
	if current_target.get_class() == "RigidBody3D":
		return current_target.linear_velocity
	if current_target.get_class() == "Node3D":
		return Vector3.ZERO

func get_worientation_pos():
	#temporarily
	return self.get_wpos()

	
