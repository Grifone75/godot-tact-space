extends Node3D

@export var max_thrust = 1.0
var vessel_thrust_axis:Vector3 = Vector3(0,0,1)
var _ref_rb
var curr_thust_vec: Vector3 = Vector3.ZERO
var new_thust_vec: Vector3 = Vector3.ZERO
var updating : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$plume_mesh_1.set_instance_shader_parameter("_Seed", randf_range(0,1.0))
	pass
	
	
# func _process(delta):
# 	if _ref_rb:
# 		DebugDraw.draw_line(
# 				global_transform.origin, 
# 				global_transform.origin + _ref_rb.global_transform.basis * vessel_thrust_axis * 5, 
# 				Color(0, .2, .5)
# 			)	

func set_thrust(value):

	var fvalue = clampf(-vessel_thrust_axis.dot(value)/max_thrust,0.0,1.0)
	$thruster.set_instance_shader_parameter("_Thrust",fvalue)
	$plume_mesh_1.set_instance_shader_parameter("_Throttle",fvalue-0.2)

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

