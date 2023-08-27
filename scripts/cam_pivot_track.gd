extends Node3D



@export var tracked : Node3D
@export var focus : Node3D

var _mouse_position = Vector2.ZERO
var _joy_position = Vector2.ZERO
var sensitivity = 0.01
var zoom = 1.0
var delta_rotation : Quaternion = Quaternion.IDENTITY

signal tracked_updated
signal focus_updated



func update_tracked(n3):
	tracked = n3
	tracked_updated.emit(n3)
	self.get_parent().remove_child(self)
	tracked.get_node("Smoothing").add_child(self)
	#$ReflectionProbe.tracked_object = n3

	
func update_focus(n3):
	focus = n3
	focus_updated.emit(n3)


func reset_origin():
	print("cam resetting")
	#var delta_current = self.current_cam_pos - self.global_position
	#var delta_tracked = self.current_tracked_pos - self.global_position
	self.global_position = Vector3.ZERO
	#self.current_cam_pos = delta_current
	#self.current_tracked_pos = delta_tracked



func _input(event):
	# Receives mouse motion
	if event is InputEventMouseMotion:
		_mouse_position = event.relative
	
	# Receives mouse button input
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_RIGHT: # Only allows rotation if right click down
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
			MOUSE_BUTTON_WHEEL_DOWN: # zoom out
				zoom = clamp(zoom +1.0, -20, 20)
			MOUSE_BUTTON_WHEEL_UP: # zoom in
				zoom = clamp(zoom -1.0, -20, 20)


func _update_mouselook():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_position *= sensitivity
		var new_rot = Quaternion.from_euler(Vector3(-_mouse_position.y,_mouse_position.x,0))
		delta_rotation *= new_rot

		_mouse_position = Vector2.ZERO
	else:
		var jx = Input.get_joy_axis(0,JOY_AXIS_RIGHT_X)
		var jy = Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y)
		
		var tx = signf(jx) * ease(absf(jx),3)
		var ty = signf(jy) * ease(absf(jy),3)
		_joy_position = Vector2(tx,ty)
		var new_rot = Quaternion.from_euler(Vector3(-_joy_position.y*0.1,-_joy_position.x*0.1,0))
		delta_rotation *= new_rot
		_joy_position = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_update_mouselook()
	if tracked:
		
		var new_basis = Basis($BasePivot.transform.basis.get_rotation_quaternion() * delta_rotation).orthonormalized()
		transform.basis = transform.basis.slerp(new_basis,0.1)
		
		$BasePivot/CameraArm.transform.origin.z += zoom
		zoom = 0.0



