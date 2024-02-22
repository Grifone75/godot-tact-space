extends Node


signal vessel_info

var local_torque_input: Vector3 = Vector3.ZERO
var local_force_input: Vector3 = Vector3.ZERO
var nav_target
var functionals: Dictionary
var ref_rb:RigidBody3D
#account for drive engine inertia
var current_local_force_input : Vector3 = Vector3.ZERO
var current_local_torque_input : Vector3 = Vector3.ZERO
var warp_mode: bool = false
var warp_set:bool = false
var warp_speed = 0.1

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
			if "vessels" in nav_target.get_parent().get_parent().get_groups():
				turret.set_target(nav_target)
			else:
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
		if !warp_set:
			#first cap the local force according to thrusters (TEMP)
			local_force_input = local_force_input.clamp(Vector3(-1.,-1.,-1.),Vector3(1.,1.,10.))
			
			current_local_force_input = current_local_force_input.lerp(local_force_input,.05)
			current_local_torque_input = current_local_torque_input.lerp(local_torque_input,.05)
			
			var gforce =  ref_rb.global_transform.basis * current_local_force_input
			var gtorque =  ref_rb.global_transform.basis * current_local_torque_input
			#vessel_info.emit("%3.3f" % (ref_rb.linear_velocity.length()))
			vessel_info.emit("%3.3f - %3.3f - %3.3f" % [current_local_force_input.x,current_local_force_input.y,current_local_force_input.z])
			
			#debug info
			# DebugDraw.draw_line(
			# 	ref_rb.global_transform.origin, 
			# 	ref_rb.global_transform.origin+gforce*10.0, 
			# 	Color(0, 0, .2)
			# )
			# if nav_target:
			# 	DebugDraw.draw_line(
			# 		ref_rb.global_transform.origin,
			# 		nav_target.global_position, 
			# 		Color(.2, .2, .2)
			# 	)

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
			# 	ref_rb.global_transform.origin+current_local_force_input.z * ref_rb.global_transform.basis.z * 10, 
			# 	Color(0, 0, 1)
			# )
			# DebugDraw.draw_line(
			# 	ref_rb.global_transform.origin, 
			# 	ref_rb.global_transform.origin+current_local_force_input.x * ref_rb.global_transform.basis.x * 10, 
			# 	Color(1, 0, 0)
			# )
			# DebugDraw.draw_line(
			# 	ref_rb.global_transform.origin, 
			# 	ref_rb.global_transform.origin+current_local_force_input.y * ref_rb.global_transform.basis.y * 10, 
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
				thruster.set_thrust(current_local_force_input)
				thruster._calculate_force_from_torque(local_torque_input)
		else:
			pass
			ref_rb.global_position += ref_rb.global_transform.basis.z * warp_speed
		local_force_input = Vector3.ZERO
		local_torque_input = Vector3.ZERO

		if warp_mode and warp_speed < 100000.0:
			warp_set = true
			warp_speed = warp_speed * 1.1
		if !warp_mode: 
			if warp_speed > 0.1:
				warp_speed = warp_speed*0.9
			else:
				warp_set = false

func update_control_torque(v3):
	local_torque_input = v3
	
func update_control_force(v3):
	local_force_input = v3

func update_nav_target(n3):
	nav_target = n3
	
func toggle_warp_mode():
	warp_mode = !warp_mode


func get_docking_port():
	if functionals.get("dockports"):
		return functionals.get("dockports")[0]
