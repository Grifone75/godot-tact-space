class_name Targeting_manager extends Resource


signal target

var current_target: Contactable


func set_target(_contactable):
	self.current_target = _contactable
	target.emit(current_target)

func get_wpos():
	if self.current_target:
		return current_target.get_local_space_position()
	return Vector3.ZERO


func get_wvel():
	if self.current_target == null:
		return Vector3.ZERO
	else:
		return current_target.get_local_space_velocity()

func get_worientation_pos():
	#temporarily returns the position of the target, in the future enhance to support a custom orientation method
	return self.get_wpos()

func get_safe_distance():
	if current_target.contact_type == 'planet':
		return 1000000
	else:
		return 200

	
