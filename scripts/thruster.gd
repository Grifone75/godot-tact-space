extends Node3D

@export var max_thrust = 1.0

signal current_thrust

var vessel_thrust_axis:Vector3 = Vector3(0,0,1)
var vessel_thruster_offset:Vector3 = Vector3.ZERO
var _ref_rb
var curr_thust_vec: Vector3 = Vector3.ZERO
var new_thust_vec: Vector3 = Vector3.ZERO
var updating : bool = false
var current_noise_level = 0.0

var audionode
#var thruster_sound = preload("res://data/audio/thrusters_loopwav-14699.mp3")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$plume_mesh_1.set_instance_shader_parameter("_Seed", randf_range(0,1.0))
	audionode = $AudioStreamPlayer3D
	if audionode.stream:
		audionode.stop()
		audionode.stream.set_loop(true)
	_manage_sound()
	
	
# func _process(delta):
# 	if _ref_rb:
# 		DebugDraw.draw_line(
# 				global_transform.origin, 
# 				global_transform.origin + _ref_rb.global_transform.basis * vessel_thrust_axis * 5, 
# 				Color(0, .2, .5)
# 			)	
func _manage_sound():
	while true:
		if $AudioStreamPlayer3D.stream:
			if current_noise_level > 0.1 and not $AudioStreamPlayer3D.playing:
				$AudioStreamPlayer3D.play()
			if current_noise_level < 0.1 and $AudioStreamPlayer3D.playing:
				$AudioStreamPlayer3D.stop()
			if $AudioStreamPlayer3D.playing:
				$AudioStreamPlayer3D.volume_db = current_noise_level * 60 - 40
		await get_tree().create_timer(.1).timeout
				


func set_thrust(value):

	var fvalue = clampf(-vessel_thrust_axis.dot(value)/max_thrust,0.0,1.0)
	$thruster.set_instance_shader_parameter("_Thrust",fvalue)
	$plume_mesh_1.set_instance_shader_parameter("_Throttle",fvalue-0.2)
	current_thrust.emit({self.name:fvalue})
	
	

	current_noise_level = fvalue
	
	#new_thust_vec = value	
	#if not updating: _update_thrust()
	#temporarily disabling particles
#	if value.z > 0.5:
#		$plume_particles.amount = int(fvalue * 50)+1
#		$plume_particles.emitting = true
#	else:
#		$plume_particles.emitting = false
		
func _update_thrust():
	updating = true
	while curr_thust_vec.distance_squared_to(new_thust_vec) > 0.01:
		#print(curr_thust_vec.distance_squared_to(new_thust_vec))
		curr_thust_vec = curr_thust_vec.lerp(new_thust_vec,.1)
		#TODO 3 lines below also go out of the loop?
		var fvalue = clampf(-vessel_thrust_axis.dot(curr_thust_vec),0,1)
		$thruster.set_instance_shader_parameter("_Thrust",fvalue)
		$plume_mesh_1.set_instance_shader_parameter("_Throttle",fvalue)
		await get_tree().create_timer(.05).timeout
	curr_thust_vec = new_thust_vec
	updating = false

func init_placement(ref_rb):
	_ref_rb = ref_rb
	vessel_thrust_axis = self.global_transform.basis.z * ref_rb.global_transform.basis
	vessel_thruster_offset = (self.global_position - ref_rb.global_position) * ref_rb.global_transform.basis

func _calculate_force_from_torque(t:Vector3):
	#1st determine if lever and torque axis are aligned, 
	#if they are at 90' the effect of the lever is maximum if they are aligned is null
	var reference_versor = vessel_thruster_offset.normalized().cross(vessel_thrust_axis.normalized())
	var effect_factor = t.normalized().dot(reference_versor)
	
	#var lever_effect = 1.0 - abs(t.normalized().dot(vessel_thruster_offset.normalized()))
	#var torque_thruster_alignment = t.normalized().dot(vessel_thrust_axis.normalized())
	var force_from_torque = clampf(-effect_factor * t.length()/vessel_thruster_offset.length(),0.0,.6)
	#debug
	# if _ref_rb:
	# 	DebugDraw.draw_line(
	# 		_ref_rb.global_position, 
	# 		_ref_rb.global_position + _ref_rb.global_transform.basis * t,
	# 		Color(.5, .2, .0)
	# 	)	
		
	# 	DebugDraw.draw_line(
	# 		_ref_rb.global_position, 
	# 		_ref_rb.global_position + _ref_rb.global_transform.basis * vessel_thruster_offset,
	# 		Color(.0, .2, .0)
	# 	)	
	
	if _ref_rb and force_from_torque>0.1:
		$thruster.set_instance_shader_parameter("_Thrust",force_from_torque)
		$plume_mesh_1.set_instance_shader_parameter("_Throttle",force_from_torque-0.2)
		# DebugDraw.draw_line(
		# 	global_transform.origin, 
		# 	global_transform.origin + _ref_rb.global_transform.basis * vessel_thrust_axis * force_from_torque, 
		# 	Color(0, .2, .5)
		# )	


