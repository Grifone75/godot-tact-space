extends Node

signal torque_input
signal force_input
signal changed_target
signal pilot_info
var _pilot_info = {}

var local_rototranslation_node : Node3D
var nav_target: Node
var targeting_manager: Targeting_manager
var pid_pos: Pid_3f
var pid_vel: Pid_3f
var ref_rb: RigidBody3D
var ref_vessel


var nav_metrics: Nav_metrics
var nav_details = ""
var mission_details = ""

var _translation_mode: Callable = Callable()
var _orientation_mode: Callable = Callable()
var _tr_mode_name = ""
var _or_mode_name = ""


@export var contact_list = []

# Called when the node enters the scene tree for the first time.
func _ready():	
	
	ref_vessel = get_parent().get_node("VesselController")
	ref_rb = get_parent().get_node("VesselController/RigidBody3D")

	targeting_manager = Targeting_manager.new()
	nav_metrics = Nav_metrics.new(ref_rb, targeting_manager)
	pid_pos = Pid_3f.new(5,0.3,10)
	pid_vel = Pid_3f.new(5,0.3,10)

	_update_contact_list()

	#todo add logic for sequencing missions when the first finishes

func _update_contact_list():
	#wip
	while true:
		contact_list = get_tree().get_nodes_in_group("vessels").filter(func(x): return x != self.get_parent()) + get_tree().get_nodes_in_group("wide_area_nodes")
		await get_tree().create_timer(2.).timeout
		
#TODO rework
func update_navtarget(n):
	nav_target = n
	changed_target.emit(nav_target)
	targeting_manager.set_target(nav_target)
	print("** switched to target : "+nav_target.get_linked_object().name)
	
func update_navmode(index):
	if index == 0:
		self.set_translation_mode('idle').set_orientation_mode('idle')
	if index == 1:
		self.set_translation_mode('stop').set_orientation_mode('face_fixed')
	if index == 2:
		self.set_translation_mode('axial').set_orientation_mode('idle')
	if index == 3:
		self.set_translation_mode('idle').set_orientation_mode('face_target')
	if index == 4:
		self.set_translation_mode('axial').set_orientation_mode('face_target')
	if index == 5:
		self.set_translation_mode('approach').set_orientation_mode('face_target')
	if index == 6:
		self.set_translation_mode('match_velocity').set_orientation_mode('anti_velocity')
	if index == 7:
		self.set_translation_mode('idle').set_orientation_mode('kill_rotation')
	if index == 8:
		self.set_translation_mode('warp').set_orientation_mode('kill_rotation')




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#torque_input.emit(Vector3.FORWARD * 0.1)
	#force_input.emit(Vector3.FORWARD)

func _physics_process(delta):
	_pilot_info = {}

	
	nav_metrics.update_metrics()
	if not _translation_mode.is_null():
		_translation_mode.call()
	if not _orientation_mode.is_null():
		_orientation_mode.call()

	
	_pilot_info["nav mode"] = _or_mode_name + ' - ' + _tr_mode_name
	if nav_target: _pilot_info["nav tgt"] = nav_target.get_linked_object().name
	_pilot_info["tgt dst"] = Metric.dst2str(nav_metrics.l_translation_to_target.length())
	_pilot_info["tgt vel to"] = Metric.vel2str(nav_metrics.l_vtt_sag_pos_len)
	_pilot_info["tgt vel sag"] = Metric.vel2str(nav_metrics.l_vtt_sag.length())
	_pilot_info["tgt vel tan"] = Metric.vel2str(nav_metrics.l_vtt_tan.length())
	_pilot_info["details"] = nav_details
	_pilot_info["mission"] = mission_details
	pilot_info.emit(_pilot_info)


func _apply_axial_translation():
	var AXIAL_THRUST_MULTIPLIER = 0.05
	var reference_pos = ref_rb.global_position
	if local_rototranslation_node:
		reference_pos = local_rototranslation_node.global_position
	
	var nav_target_linear_velocity = targeting_manager.get_wvel()
	if nav_target_linear_velocity != null:
		var dt = get_physics_process_delta_time()
		var l_translation_to_target = ((reference_pos - targeting_manager.get_wpos())) * ref_rb.global_transform.basis
		l_translation_to_target = l_translation_to_target - l_translation_to_target.normalized()*nav_metrics.get_approach_distance()
		var l_velocity_to_target = (ref_rb.linear_velocity - nav_target_linear_velocity) * ref_rb.global_transform.basis
		var cumulated_thust = pid_pos.update(dt,l_translation_to_target,Vector3.ZERO) +	pid_vel.update(dt,l_velocity_to_target,Vector3.ZERO)
		force_input.emit(cumulated_thust*AXIAL_THRUST_MULTIPLIER)

func _kill_relative_velocity():
	var AXIAL_THRUST_MULTIPLIER = 0.05
	var nav_target_linear_velocity = targeting_manager.get_wvel()
	if nav_target_linear_velocity != null:
		var dt = get_physics_process_delta_time()
		var l_translation_to_target = Vector3.ZERO
		var l_velocity_to_target = (ref_rb.linear_velocity - nav_target_linear_velocity) * ref_rb.global_transform.basis
		var cumulated_thust = pid_pos.update(dt,l_translation_to_target,Vector3.ZERO) +	pid_vel.update(dt,l_velocity_to_target,Vector3.ZERO)
		force_input.emit(cumulated_thust*AXIAL_THRUST_MULTIPLIER)
	
func _kill_all_velocity():
	var AXIAL_THRUST_MULTIPLIER = 0.05
	var nav_target_linear_velocity = Vector3.ZERO
	if nav_target_linear_velocity != null:
		var dt = get_physics_process_delta_time()
		var l_translation_to_target = Vector3.ZERO
		var l_velocity_to_target = (ref_rb.linear_velocity - nav_target_linear_velocity) * ref_rb.global_transform.basis
		var cumulated_thust = pid_pos.update(dt,l_translation_to_target,Vector3.ZERO) +	pid_vel.update(dt,l_velocity_to_target,Vector3.ZERO)
		force_input.emit(cumulated_thust*AXIAL_THRUST_MULTIPLIER)


var frequency = 0.2 #the higher the faster turn rate
var damping = 0.8
var kp = 6*frequency*6*frequency*0.25
var kd = 4.5 * frequency * damping
var _orientation_node: Node3D


func _apply_orientation(face_to_pos = null, align_to_node: Node3D = null):
	"""
	this supports the following types of references : 
	- based on rb center or other point (local_rototranslation node)
	- face a target (from nav_metrics), an arbitrary position (from parameter face_to), or an arbitrary basis (from parameter align_to_basis)
	"""

	# let's establish which reference to use for the object
	var local_ref_transform
	if local_rototranslation_node:
		local_ref_transform = local_rototranslation_node.global_transform
	else:
		local_ref_transform = ref_rb.global_transform

	# let's now establish the target orientation we need to reach (and related rotation error to nullify)
	var qdelta

	if align_to_node:
		#kd = 4.5 * frequency * 5.0
		# calculate qdelta based on this
		# it should be quaternion of current rot * inverse quaternion of target rot
		var b1 = local_ref_transform.basis
		var b2 = align_to_node.global_basis
		qdelta = b2.get_rotation_quaternion() * b1.get_rotation_quaternion().inverse()

	else:
		# calculate qdelta based on a target position
		var orientation_pos
		if face_to_pos:
			orientation_pos = face_to_pos
			#print(face_to)
		else:
			orientation_pos = nav_metrics.get_orientation_pointer()	
			
		if orientation_pos:
			var dt = get_physics_process_delta_time()
			var g = 1/(1+ kd*dt + kp*dt*dt)
			var ksg = kp * g
			var kdg = (kd + kp * dt) * g
			
			#for the time being we only implement facing toward an object
			var facing_pos = orientation_pos


			
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
	var ref_thrust = 10.0
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

	var decel_distance = get_braking_distance(nav_metrics.l_vtt_sag_pos_len, ref_thrust, ref_mass) + nav_metrics.get_approach_distance()

	""" 	
	var activation_braking = clamp(remap(
		(decel_distance - nav_metrics.l_translation_to_target.length()),
		-10.,1.,0.,1.
		),0.,1.) """

	var activation_braking
	var pre_braking_distance = 10
	activation_braking = remap(clampf(nav_metrics.l_translation_to_target.length() - decel_distance,0,pre_braking_distance),0,10,1,0)
	if activation_braking > 0.1:
		if nav_metrics.l_vtt_sag_pos_len > 5.0:
			nav_metrics.set_orientation_mode(nav_metrics.ORIENTATION_BASE.AG_VEL)
		else:
			nav_metrics.set_orientation_mode(nav_metrics.ORIENTATION_BASE.TO_TGT)
		
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


# temporary, to be moved in amore appropriate place (like in a functional)
var drone_manager: Drone_manager = null

func spawn_drones():
	if drone_manager == null:
		drone_manager = Drone_manager.new()
	var d = load("res://scenes/drone.tscn").instantiate()
	get_tree().get_root().add_child(d)
	d.global_transform = ref_rb.global_transform
	d.global_position += ref_rb.global_transform.basis.z * 10.0
	d.rotate(Vector3(randf(), randf(),.5).normalized(),randf_range(0,PI))
	d.set_focus(ref_rb.global_position, 10.0).set_manager(drone_manager)

func set_drone_distance(d):
	drone_manager.set_distance(d)

func set_drone_focus(v3):
	drone_manager.set_focus(v3)

func set_drone_destroy():
	drone_manager.destroy()

func process_command(ev):
	if ev == "drone_test":
		if drone_manager != null:
			#drone_manager.set_distance(20)
			drone_manager.set_focus(targeting_manager.get_wpos())
	if ev == "warp_mode":
		get_parent().get_node("VesselController").toggle_warp_mode()
		
		


# interface for controlling the aipilot

func set_translation_mode(param:String):
	_tr_mode_name = param
	pid_vel.tune_derivative_gain(0.3)
	pid_vel.tune_proportional_gain(5)
	ref_vessel.warp_mode = false
	set_warp(false)
	match param:
		'idle':
			_translation_mode = Callable()
		'axial':
			_translation_mode = _apply_axial_translation
		'slow_axial':
			_translation_mode = _apply_axial_translation
			pid_vel.tune_derivative_gain(0.3)
			pid_vel.tune_proportional_gain(20)
		'approach':
			_translation_mode = _apply_approach
		'match_velocity':
			_translation_mode = _kill_relative_velocity
		'stop':
			_translation_mode = _kill_all_velocity
		'warp':
			_translation_mode = _warp
		_:
			_tr_mode_name = "unk"
			_translation_mode = Callable()
	return self


func _warp():
	if nav_metrics.l_translation_to_target.length() > targeting_manager.get_safe_distance():
		if nav_metrics.alignment_to_target<.9:
			ref_vessel.warp_mode = false
			set_warp(false)
			set_orientation_mode('face_target')
			print('orienting... ' + str(nav_metrics.alignment_to_target))
		elif nav_metrics.alignment_to_target<.999 and not ref_vessel.warp_mode:
			set_orientation_mode('face_target')
			print('orienting... ' + str(nav_metrics.alignment_to_target))
		else:
			set_orientation_mode('kill_rotation')
			print("d is : " + str(nav_metrics.l_translation_to_target.length()) + " mspeed is " +  str(min(ref_vessel.max_warp_speed,500000.0)))
			ref_vessel.max_warp_speed = nav_metrics.l_translation_to_target.length() / 20.0
			ref_vessel.warp_mode = true
			set_warp(true)
	else:
		ref_vessel.warp_mode = false
		set_warp(false)
		set_translation_mode('idle')

func set_rototranslation_reference(param:Node3D):
	self.local_rototranslation_node = param
	return self

func clear_rototranslation_reference():
	self.local_rototranslation_node = null
	return self

func set_orientation_node(param:Node3D):
	_orientation_node = param


func set_orientation_mode(param:String):
	_or_mode_name = param
	match param:
		'idle':	
			_orientation_mode = Callable()		
			nav_metrics.set_orientation_mode(nav_metrics.ORIENTATION_BASE.TO_TGT)
		'face_fixed':	
			_orientation_mode = func(): _apply_orientation(ref_rb.global_position + Vector3.FORWARD*10.0, null)
			nav_metrics.set_orientation_mode(nav_metrics.ORIENTATION_BASE.TO_TGT)
		'face_target':
			_orientation_mode = _apply_orientation
			nav_metrics.set_orientation_mode(nav_metrics.ORIENTATION_BASE.TO_TGT)
		'anti_velocity':
			_orientation_mode = _apply_orientation
			nav_metrics.set_orientation_mode(nav_metrics.ORIENTATION_BASE.AG_VEL)
		'custom_basis':
			_orientation_mode = func(): _apply_orientation(null, _orientation_node)
		'kill_rotation':
			_orientation_mode = _apply_orientation
			nav_metrics.set_orientation_mode(nav_metrics.ORIENTATION_BASE.FACING_DIR)
		_:

			_or_mode_name = "unk"
			_orientation_mode = Callable()		
	return self
	

func set_warp(do_warp:bool):
	if do_warp:
		ref_rb.freeze = true
		ref_rb.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	else:
		ref_rb.freeze = false
		ref_rb.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC


func set_local_rototranslation_node(node):
	# set the node
	local_rototranslation_node = node
	# update nav metrics so that also they take it into account
	nav_metrics.set_reference(local_rototranslation_node)

func clear_local_rototranslation_node():
	local_rototranslation_node = null
	nav_metrics.clear_reference()


var _own_dockport = null
func set_docking_mode(target_dock_ref):
	var dockport = ref_vessel.functionals.get("ship_dockport")
	if dockport:
		set_orientation_node(target_dock_ref)
		_own_dockport = dockport[0]
		var own_dock_ref = _own_dockport.get_dockport_reference(false)
		_own_dockport.set_taken()
		set_local_rototranslation_node(own_dock_ref)
		set_translation_mode('slow_axial').set_orientation_mode('custom_basis')
		return true
	else:
		return false

func clear_docking_mode():
	clear_local_rototranslation_node()
	_own_dockport.set_free()
	_own_dockport = null
	set_translation_mode('idle').set_orientation_mode('idle')


func update_contact_list():
	""" this refresh the contact list of the ship.
	initially is a very simple implementation, then to be evolved.
	"""
	#let's start simply with ships
	var raw_list = get_tree().get_nodes_in_group("contactables")
	var output_list = []
	for el in raw_list:
		if (el.get_linked_object() != get_parent()) and (el.discoverable):
			var output_element = Contact.new()
			output_element.contact = el
			output_element.contact_type = el.get_contact_type()
			output_element.get_distance = func(): return (el.get_local_space_position() - self.ref_rb.global_position).length()
			output_element.get_targetable = func(): return el.linked_rb
			output_list.append(output_element)

	return output_list

