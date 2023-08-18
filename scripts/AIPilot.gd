extends Node

signal torque_input
signal force_input
signal changed_target
signal pilot_info

var local_rototranslation_node : Node3D
var nav_target: Node3D
var targeting_manager: Targeting_manager
var pid_pos: Pid_3f
var pid_vel: Pid_3f
var ref_rb: RigidBody3D
var nav_method
var nav_method_name = ""
var nav_metrics: Nav_metrics
var nav_details = ""
# Called when the node enters the scene tree for the first time.
func _ready():	
	
	ref_rb = get_parent().get_node("VesselController/RigidBody3D")
	nav_method = []
	targeting_manager = Targeting_manager.new()
	nav_metrics = Nav_metrics.new(ref_rb, targeting_manager)
	pid_pos = Pid_3f.new(5,0.3,10)
	pid_vel = Pid_3f.new(5,0.3,10)
	_monitor_target()


func _helper_find_target():
	var n3 = get_tree().get_nodes_in_group("navpoints").pick_random()
	update_navtarget(n3)
	

func update_navtarget(n3):
	targeting_manager.set_target(n3)
	nav_target = n3
	changed_target.emit(nav_target)
	targeting_manager.set_target(nav_target)
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
	if index == 4:
		nav_method = [_apply_orientation, _apply_approach]
		nav_method_name = "full approach"

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
		nav_metrics.update_metrics()
		method.call()	
	#_apply_orientation()
	#_apply_axial_translation()
	pilot_info.emit(nav_method_name+"\n-------------\n"+nav_details+"\n-------------\n"+nav_target.name)

var frequency = 0.5 #the higher the faster turn rate
var damping = 0.8
var kp = 6*frequency*6*frequency*0.25
var kd = 4.5 * frequency * damping

func _apply_axial_translation():
	var AXIAL_THRUST_MULTIPLIER = 0.05
	var g_offset = Vector3.ZERO
	if local_rototranslation_node:
		g_offset = ref_rb.global_position - local_rototranslation_node.global_position
	
	var nav_target_linear_velocity = targeting_manager.get_wvel()
	if nav_target_linear_velocity != null:
		var dt = get_physics_process_delta_time()
		var l_translation_to_target = ((ref_rb.global_position - nav_target.global_position) + g_offset) * ref_rb.global_transform.basis
		var l_velocity_to_target = (ref_rb.linear_velocity - nav_target_linear_velocity) * ref_rb.global_transform.basis
		var cumulated_thust = pid_pos.update(dt,l_translation_to_target,Vector3.ZERO) +	pid_vel.update(dt,l_velocity_to_target,Vector3.ZERO)
		force_input.emit(cumulated_thust*AXIAL_THRUST_MULTIPLIER)


func _apply_orientation():
	var orientation_pos = targeting_manager.get_worientation_pos()
	if orientation_pos:
		var dt = get_physics_process_delta_time()
		var g = 1/(1+ kd*dt + kp*dt*dt)
		var ksg = kp * g
		var kdg = (kd + kp * dt) * g
		
		#for the time being we only implement facing toward an object
		var qdelta
		var facing_pos = orientation_pos
		
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
		

func get_braking_distance(velocity:float, thrust:float, mass:float):
	var acc = thrust / mass
	return (velocity * velocity)/(2.0*acc)
		

func _apply_approach():
	var ref_thrust = 2.0
	var ref_mass = 3.0

	var approach_rate = nav_metrics.l_velocity_to_target.normalized().dot(nav_metrics.l_translation_to_target.normalized())

	# DebugDraw.draw_line(
	# 	ref_rb.global_transform.origin, 
	# 	ref_rb.global_transform.origin+(ref_rb.global_transform.basis * nav_metrics.l_translation_to_target.normalized())*10.0, 
	# 	Color(.0, .2, 0)
	# )
	# DebugDraw.draw_line(
	# 	ref_rb.global_transform.origin, 
	# 	ref_rb.global_transform.origin+(ref_rb.global_transform.basis * nav_metrics.l_velocity_to_target.normalized())*10.0, 
	# 	Color(.2, .0, 0)
	# )


	var activation_approach_concur = 0.0
	var activation_approach_discord = 0.0


	if (approach_rate >= 0.0) : 
		activation_approach_concur = 1.0
	if (approach_rate < 0.0) : 
		activation_approach_discord = 1.0

	var decel_distance = get_braking_distance(nav_metrics.l_vtt_sag_pos_len, ref_thrust, ref_mass)

	""" 	
	var activation_braking = clamp(remap(
		(decel_distance - nav_metrics.l_translation_to_target.length()),
		-10.,1.,0.,1.
		),0.,1.) """

	var activation_braking
	var pre_braking_distance = 100
	activation_braking = remap(clampf(nav_metrics.l_translation_to_target.length() - decel_distance,0,pre_braking_distance),0,10,1,0)
	"""
	if nav_metrics.l_translation_to_target.length() > decel_distance:
		activation_braking = 0.0
	else: 
		activation_braking = 1.0
	"""

	nav_details = "d: {} vs limit: {}, a-rate: {} , mode ({})".format(["%0.2f" % nav_metrics.l_translation_to_target.length(), "%0.2f" % decel_distance, "%0.2f" % approach_rate , str(activation_braking)], "{}")

	var approach_force = nav_metrics.l_translation_to_target.normalized()*10.0
	var braking_force = -nav_metrics.l_translation_to_target.normalized()*sign(nav_metrics.l_vtt_sag_pos_len)*10.0
	var kill_tan_force = -nav_metrics.l_vtt_tan.limit_length(10.0)

	var final_force = (
			activation_approach_discord * approach_force + 
			activation_approach_concur * ((1-activation_braking)*approach_force + activation_braking * braking_force ) + 
			kill_tan_force
		)

	force_input.emit(final_force)
	

func _apply_approach2():
	var ref_thrust = 2
	var ref_mass = 3

	var approach_rate = nav_metrics.l_velocity_to_target.normalized().dot(nav_metrics.l_translation_to_target.normalized())

	var activation_approach = 0.0
	var activation_recede = 0.0
	var activation_hard_turn = 0.0

	if (nav_metrics.l_velocity_to_target.length() < 0.01) : 
		activation_approach = 1.0
	if (approach_rate >= 0.0) : 
		activation_approach = 1.0
	if (approach_rate < 0.0) : 
		activation_recede = 1.0

	var activation_proximity = clamp(remap(
		nav_metrics.l_translation_to_target.length(),
		0.,100.,1.,0.
		),0.,1.)

	var force_counter_vel = -2. * nav_metrics.l_velocity_to_target.limit_length(3.0)

	#compute hard turn force
	var force_hard_turn = -nav_metrics.l_velocity_to_target.cross(
		nav_metrics.l_velocity_to_target.normalized().cross(nav_metrics.l_translation_to_target.normalized())
	) * 15.0 

	# compute receding case force
	var k_receding = -20.8 
	var k_d_receding = 0.0 
	var max_f_receding = 15.0 
	var force_receding = -nav_metrics.l_velocity_to_target.normalized()*10.0

	# compute approaching case force
	var decel_distance = get_braking_distance(nav_metrics.l_vtt_sag.length(), ref_thrust, ref_mass)
	var activation_braking = clamp(remap(
		(decel_distance - nav_metrics.l_translation_to_target.length()),
		-10.,1.,0.,1.
		),0.,1.)


	var force_towards = nav_metrics.l_translation_to_target.normalized() * 10.
	var force_against = -nav_metrics.l_translation_to_target.normalized() * 10.

	var force_approach = (
		(1.0 - activation_braking) * force_towards
		+ activation_braking * force_against
		+ (-1.0 * nav_metrics.l_vtt_tan.limit_length(2.0))
		)

	nav_details = ""		

	var final_force = (
		activation_approach * force_approach
		+ activation_recede * force_receding
		+ activation_hard_turn * force_hard_turn
		+ activation_proximity * force_counter_vel
		)

	force_input.emit(final_force)
