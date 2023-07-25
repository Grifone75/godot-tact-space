extends Node


signal vessel_info

var local_torque_input: Vector3 = Vector3.ZERO
var local_force_input: Vector3 = Vector3.ZERO
var nav_target
var functionals: Dictionary
var ref_rb:RigidBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	_init_rb()
	_delayed_init()

func _delayed_init():
	await get_tree().create_timer(1).timeout
	set_aggressive(false)
	
func set_aggressive(yes_flag):
	for turret in functionals.get("turrets",[]):
		if yes_flag:
			turret.set_target(get_tree().get_nodes_in_group("vessels").pick_random().get_rb())
		else:
			turret.set_target(null)
		


func _init_rb():
	while ref_rb == null:
		ref_rb = get_node("RigidBody3D")
		await get_tree().create_timer(1).timeout
	for thruster in functionals.get("thrusters",[]):
		thruster.init_placement(ref_rb)


func _physics_process(delta):
	if ref_rb:
		# update physics
		
		#first cap the local force according to thrusters (TEMP)
		local_force_input = local_force_input.clamp(Vector3(-1.,-1.,-1.),Vector3(1.,1.,10.))
		
		
		var gforce =  ref_rb.global_transform.basis * local_force_input
		var gtorque =  ref_rb.global_transform.basis * local_torque_input
		#vessel_info.emit("%3.3f" % (ref_rb.linear_velocity.length()))
		vessel_info.emit("%3.3f - %3.3f - %3.3f" % [local_force_input.x,local_force_input.y,local_force_input.z])
		#debug info
		# DebugDraw.draw_line(
		# 	ref_rb.global_transform.origin+Vector3.ONE, 
		# 	ref_rb.global_transform.origin+Vector3.ONE+ ref_rb.global_transform.basis.z * 5, 
		# 	Color(0, 0, .2)
		# )
		# DebugDraw.draw_line(
		# 	ref_rb.global_transform.origin+Vector3.ONE, 
		# 	ref_rb.global_transform.origin+Vector3.ONE+ ref_rb.global_transform.basis.x * 5, 
		# 	Color(.2, 0, 0)
		# )
		# DebugDraw.draw_line(
		# 	ref_rb.global_transform.origin+Vector3.ONE, 
		# 	ref_rb.global_transform.origin+Vector3.ONE+ ref_rb.global_transform.basis.y * 5, 
		# 	Color(0, .2, 0)
		# )		

		# DebugDraw.draw_line(
		# 	ref_rb.global_transform.origin, 
		# 	ref_rb.global_transform.origin + gforce * 10, 
		# 	Color(1, 1, 1)
		# )
		
		# DebugDraw.draw_line(
		# 	ref_rb.global_transform.origin, 
		# 	ref_rb.global_transform.origin+local_force_input.z * ref_rb.global_transform.basis.z * 10, 
		# 	Color(0, 0, 1)
		# )
		# DebugDraw.draw_line(
		# 	ref_rb.global_transform.origin, 
		# 	ref_rb.global_transform.origin+local_force_input.x * ref_rb.global_transform.basis.x * 10, 
		# 	Color(1, 0, 0)
		# )
		# DebugDraw.draw_line(
		# 	ref_rb.global_transform.origin, 
		# 	ref_rb.global_transform.origin+local_force_input.y * ref_rb.global_transform.basis.y * 10, 
		# 	Color(0, 1, 0)
		# )
		# if nav_target:
		# 	DebugDraw.draw_line(
		# 		ref_rb.global_transform.origin, 
		# 		nav_target.global_position, 
		# 		Color(.5, .5, 0)
		# 	)
		
		ref_rb.apply_central_force(gforce)
		ref_rb.apply_torque(gtorque)
		# update other
		for thruster in functionals.get("thrusters",[]):
			thruster.set_thrust(local_force_input)
		
		local_force_input = Vector3.ZERO
		local_torque_input = Vector3.ZERO


func update_control_torque(v3):
	local_torque_input = v3
	
func update_control_force(v3):
	local_force_input = v3

func update_nav_target(n3):
	nav_target = n3
