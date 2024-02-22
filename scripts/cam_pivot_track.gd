extends Node3D



@export var tracked : Node
@export var focus : Node

var _mouse_position = Vector2.ZERO
var _mouse_position_abs = Vector2.ZERO
var _joy_position = Vector2.ZERO
var sensitivity = 0.01
var zoom = 1.0
var delta_rotation : Quaternion = Quaternion.IDENTITY

var _hold_global_basis

signal tracked_updated
signal focus_updated #TODO not used?
signal clicked_object


func update_tracked(vessel):
	tracked = vessel
	tracked_updated.emit(vessel)
	self.get_parent().remove_child(self)
	tracked.rb.get_node("Smoothing").add_child(self)
	#$ReflectionProbe.tracked_object = vessel.rb

	
#TODO not used?
func update_focus(vessel):
	focus = vessel
	focus_updated.emit(vessel)


func reset_origin():
	#print("cam resetting")
	#var delta_current = self.current_cam_pos - self.global_position
	#var delta_tracked = self.current_tracked_pos - self.global_position
	self.global_position = Vector3.ZERO
	#self.current_cam_pos = delta_current
	#self.current_tracked_pos = delta_tracked



func _input(event):
	# Receives mouse motion
	if event is InputEventMouseMotion:
		_mouse_position = event.relative
		_mouse_position_abs = event.position
	
	# Receives mouse button input
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_RIGHT: # Only allows rotation if right click down
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
			MOUSE_BUTTON_LEFT:
				clicked_object.emit(get_selection())
			MOUSE_BUTTON_WHEEL_DOWN: # zoom out
				zoom = clamp(zoom +1.0, -20, 20)
			MOUSE_BUTTON_WHEEL_UP: # zoom in
				zoom = clamp(zoom -1.0, -20, 20)

var old_rotation: Quaternion = Quaternion.IDENTITY
func _update_mouselook():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_position *= sensitivity
		var new_rot = Quaternion.from_euler(Vector3(_mouse_position.y,_mouse_position.x,0))
		delta_rotation = new_rot
		_mouse_position = Vector2.ZERO
	else:
		var jx = Input.get_joy_axis(0,JOY_AXIS_RIGHT_X)
		var jy = Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y)
		
		var tx = signf(jx) * ease(absf(jx),3)
		var ty = signf(jy) * ease(absf(jy),3)
		_joy_position = Vector2(tx,ty)
		var new_rot = Quaternion.from_euler(Vector3(-_joy_position.y*0.1,-_joy_position.x*0.1,0))
		delta_rotation = new_rot
		_joy_position = Vector2.ZERO
		
	# when this is true we are changing the rotation through the input so we want to suspend the hold rotation function
	if delta_rotation != old_rotation:
		hold_suspend = 50
	old_rotation = delta_rotation
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	_hold_global_basis = $BasePivot.global_transform.basis
	set_notify_transform(true)
	set_notify_local_transform(true)


	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	

	_update_mouselook()
	
	if tracked:
		var new_basis = Basis($BasePivot.transform.basis.get_rotation_quaternion() * delta_rotation )
		$BasePivot.transform.basis = $BasePivot.transform.basis.slerp(new_basis,0.1).orthonormalized()

		
		$BasePivot/CameraArm.transform.origin.z += zoom
		zoom = 0.0
		
	if hold_suspend>0:
		hold_suspend -= 1
	
	
func _on_camera_hold_toggled(button_pressed):
	is_hold_activated = button_pressed
	
var hold_suspend = 0
var is_hold_activated = false
func _notification(what):

	if what == NOTIFICATION_TRANSFORM_CHANGED:
		if hold_suspend == 0 and is_hold_activated: 
			$BasePivot.global_transform.basis = _hold_global_basis
		else:
			_hold_global_basis = $BasePivot.global_transform.basis


func get_selection():
	var worldspace = get_world_3d().direct_space_state
	var start = $BasePivot/CameraArm/cam_track.project_ray_origin(_mouse_position_abs)
	var end = $BasePivot/CameraArm/cam_track.project_position(_mouse_position_abs, 1000)
	var query = PhysicsRayQueryParameters3D.create(start, end)
	var result = worldspace.intersect_ray(query)
	var coll = result.get("collider")
	if coll:
		return coll.get_parent().get_parent()
	else: 
		return null
	



