extends Camera3D

@export var tracked : Node3D
@export var focus : Node3D



signal tracked_updated
signal focus_updated



var delta_rotation : Quaternion = Quaternion.IDENTITY
var current_rotation : Quaternion = Quaternion.IDENTITY
var current_dir_up : Vector3 = Vector3.UP
var current_cam_pos : Vector3 = Vector3.ZERO
var current_tracked_pos : Vector3 = Vector3.ZERO
var _mouse_position = Vector2.ZERO
var sensitivity = 0.01
var zoom = 1.0
var t_obs_pos = Vector3(0,0,10)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func old_update_tracked(n3):
	tracked = n3
	tracked_updated.emit(n3)
	global_position = tracked.global_position - tracked.global_transform.basis.z * 10
	$ReflectionProbe.tracked_object = n3
	
func update_tracked(n3):
	tracked = n3
	tracked_updated.emit(n3)
	self.get_parent().remove_child(self)
	tracked.get_node("Smoothing").add_child(self)
	#$ReflectionProbe.tracked_object = n3
	
	
func update_focus(n3):
	focus = n3
	focus_updated.emit(n3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_update_mouselook()
	if tracked:
		t_obs_pos = t_obs_pos * zoom
		zoom = 1
		var new_basis = Basis(current_rotation * delta_rotation)
		current_rotation = Quaternion.IDENTITY
		var l_new_cam_pos = (new_basis * t_obs_pos)
		self.position = l_new_cam_pos
		self.look_at(tracked.global_position, tracked.global_transform.basis.y)

func old_process(delta):
	_update_mouselook()
	if tracked:

		# rotate the camera position using the camera basis as refernce transform
		#var obs_vec = -Vector3(0,0,zoom * 10)
		t_obs_pos = t_obs_pos * zoom
		zoom = 1
		
		#camera in tracked space
		#var t_cam_pos = (global_position - tracked.global_position) * tracked.global_transform.basis
		#rotated tracked basis
		var ref_basis = tracked.global_transform.basis
		var qref = Quaternion(ref_basis)
		var new_basis = Basis(qref * current_rotation)
		current_rotation = Quaternion.IDENTITY
		# new rotated camera position
		var w_new_cam_pos = (new_basis * t_obs_pos) + tracked.global_position
		t_obs_pos = tracked.to_local(w_new_cam_pos)
		
		
		
		
		
		#*******************************
		#var obs_vec = to_local(tracked.global_position) * zoom
		#zoom = 1.0
		#var ref_basis = global_transform.basis
		#var qref = Quaternion(ref_basis)
		#var new_basis = Basis(qref * current_rotation)
		#current_rotation = Quaternion.IDENTITY
		
		# compute observation point in w space
		#var g_obs_pos = -(new_basis * obs_vec)  + tracked.global_position
		var g_tgt_pos = current_tracked_pos.lerp(tracked.global_position,0.1)
		current_tracked_pos = g_tgt_pos



		# var g_cam_pos = Vector3.ZERO
		# var g_tgt_pos = tracked.global_position
		# var look_basis = Basis.looking_at(g_cam_pos-g_tgt_pos, tracked.global_transform.basis.y)
		# if focus:
		# 	g_tgt_pos = focus.global_position
		# 	look_basis = Basis.looking_at(g_cam_pos-g_tgt_pos, tracked.global_transform.basis.y)
			
		# 	#g_cam_pos = tracked.global_position - (g_tgt_pos - tracked.global_position).normalized() * 10

		# g_cam_pos = tracked.global_position - (
		# 	look_basis.z * 10 + 
		# 	look_basis.x*lateral_offset.x + 
		# 	look_basis.y*lateral_offset.y) # back 10 units
		
		#global_transform.basis = tracked.global_transform.basis
		current_dir_up = current_dir_up.lerp(tracked.global_transform.basis.y,0.02)
		current_cam_pos = current_cam_pos.lerp(w_new_cam_pos, 0.1)
		self.look_at_from_position(current_cam_pos, g_tgt_pos, current_dir_up)
		



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
				zoom = clamp(zoom * 1.1, 0.2, 20)
			MOUSE_BUTTON_WHEEL_UP: # zoom in
				zoom = clamp(zoom / 1.1, 0.2, 20)
	
	# Receives key input
	# if event is InputEventKey:
	# 	match event.keycode:
	# 		KEY_UP:
	# 			lateral_offset += Vector2(0,1)
	# 		KEY_DOWN:
	# 			lateral_offset += Vector2(0,-1)
	# 		KEY_LEFT:
	# 			lateral_offset += Vector2(1,0)
	# 		KEY_RIGHT:
	# 			lateral_offset += Vector2(-1,0)


func _update_mouselook():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_position *= sensitivity
		var new_rot = Quaternion.from_euler(Vector3(-_mouse_position.y,_mouse_position.x,0))
		delta_rotation *= new_rot

		_mouse_position = Vector2.ZERO

func reset_origin():
	print("cam resetting")
	var delta = self.current_cam_pos - self.global_position
	self.global_position = Vector3.ZERO
	self.current_cam_pos = delta
