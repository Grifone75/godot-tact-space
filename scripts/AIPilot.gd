extends Node

signal torque_input
signal force_input
signal changed_target
signal pilot_info

var orientation_target: Node3D
var local_rototranslation_node : Node3D
var nav_target: Node3D
var pid_pos: Pid_3f
var pid_vel: Pid_3f
var ref_rb: RigidBody3D
var nav_method
var nav_method_name = ""

# Called when the node enters the scene tree for the first time.
func _ready():	
	nav_method = []
	pid_pos = Pid_3f.new(5,0.3,10)
	pid_vel = Pid_3f.new(5,0.3,10)
	ref_rb = get_parent().get_node("VesselController/RigidBody3D")
	_monitor_target()


func _helper_find_target():
	var n3 = get_tree().get_nodes_in_group("navpoints").pick_random()
	update_navtarget(n3)
	

func update_navtarget(n3):
	orientation_target = n3
	nav_target = n3
	changed_target.emit(nav_target)
	print("** switched to target : "+nav_target.name)
	
func update_navmode(index):
	if index == 0:
		nav_method = []
		nav_method_name = "idle"
	if index == 1:
		nav_method = [_apply_axial_translation]
		nav_method_name = "axial"
	if index == 2:
		nav_method = [_apply_orientation]
		nav_method_name = "face to"
	if index == 3:
		nav_method = [_apply_orientation, _apply_axial_translation]
		nav_method_name = "slow approach"

func _monitor_target():
	while true:
		if nav_target:
			if ref_rb.global_position.distance_to(nav_target.global_position) < 1.:
				_helper_find_target()
		await get_tree().create_timer(2.).timeout

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#torque_input.emit(Vector3.FORWARD * 0.1)
	#force_input.emit(Vector3.FORWARD)

func _physics_process(delta):
	if nav_target == null:
		_helper_find_target()
	for method in nav_method:
		method.call()	
	#_apply_orientation()
	#_apply_axial_translation()
	pilot_info.emit(nav_method_name+"\n"+nav_target.name)

var frequency = 0.5 #the higher the faster turn rate
var damping = 0.8
var kp = 6*frequency*6*frequency*0.25
var kd = 4.5 * frequency * damping

func _apply_axial_translation():
	var AXIAL_THRUST_MULTIPLIER = 0.05
	var g_offset = Vector3.ZERO
	if local_rototranslation_node:
		g_offset = ref_rb.global_position - local_rototranslation_node.global_position
	if nav_target:
		var nav_target_linear_velocity
		if nav_target.get_class() == "RigidBody3D":
			nav_target_linear_velocity = nav_target.linear_velocity
		else: nav_target_linear_velocity = Vector3.ZERO
		
		var dt = get_physics_process_delta_time()
		var l_translation_to_target = ((ref_rb.global_position - nav_target.global_position) + g_offset) * ref_rb.global_transform.basis
		var l_velocity_to_target = (ref_rb.linear_velocity - nav_target_linear_velocity) * ref_rb.global_transform.basis
		var cumulated_thust = pid_pos.update(dt,l_translation_to_target,Vector3.ZERO) +	pid_vel.update(dt,l_velocity_to_target,Vector3.ZERO)
		force_input.emit(cumulated_thust*AXIAL_THRUST_MULTIPLIER)

	



func _apply_orientation():
	
	if orientation_target:
		var dt = get_physics_process_delta_time()
		var g = 1/(1+ kd*dt + kp*dt*dt)
		var ksg = kp * g
		var kdg = (kd + kp * dt) * g
		
		#for the time being we only implement facing toward an object
		var qdelta
		var facing_pos = orientation_target.global_position
		
		var local_ref_transform
		if local_rototranslation_node:
			local_ref_transform = local_rototranslation_node.global_transform
		else:
			local_ref_transform = ref_rb.global_transform
		
		var v1 = local_ref_transform.basis.z
		var v2 = (facing_pos - local_ref_transform.origin).normalized()
		qdelta = Quaternion(
			v1,
			v2)
			
		if qdelta.w < 0:
			#Convert the quaterion to eqivalent "short way around" quaterion
			qdelta.x = -qdelta.x;
			qdelta.y = -qdelta.y;
			qdelta.z = -qdelta.z;
			qdelta.w = -qdelta.w;
	

		# this is a 3x3 matrix differently than Unity3d
		var inertia_tensor = PhysicsServer3D.body_get_direct_state(ref_rb.get_rid()).inverse_inertia_tensor.inverse()
		var w_inertia_tensor = ref_rb.global_transform.basis * inertia_tensor
		
		var pidv = kp * qdelta.get_angle() * qdelta.get_axis().normalized() - kd * ref_rb.angular_velocity
		
		pidv =  pidv * w_inertia_tensor 
		
		torque_input.emit(pidv * 1)
		
		
func _apply_approach():
	pass		
		
