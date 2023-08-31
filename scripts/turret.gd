extends Node3D


@export var target : Node3D
@export var yaw_pivot : Node3D
@export var pitch_pivot : Node3D
@export var bolt_gen : Node3D
@export var yaw_speed_rad_sec = 0.1
@export var pitch_speed_rad_sec = 0.1

enum TURRET_STATES {IDLE,TRACKING}
@export var turret_state : TURRET_STATES

var pitch_min = -0.5
var pitch_max = 1.2
var initial_yaw_basis
var initial_pitch_basis
var yaw_angle
var pitch_angle

# Called when the node enters the scene tree for the first time.
func _ready():
	# nb hierarchy is turret -> yaw_axis -> pitch_axis
	initial_yaw_basis = yaw_pivot.transform.basis #in turret_space
	initial_pitch_basis = pitch_pivot.transform.basis # in yaw pivot_space
	# test
	_test_mad_shooter()
	
	
func _test_mad_shooter():
	while true:
		await get_tree().create_timer(.3).timeout
		if turret_state == TURRET_STATES.TRACKING:
			var bolt = load("res://scenes/base_shot.tscn").instantiate()
			get_tree().get_root().add_child(bolt)
			bolt.global_transform = bolt_gen.global_transform
		
		
		


func _minimal_angle(v3_normal,v3_forward,p3):
	"""
	returns minimal angle between v3_forward and p3 (in the same space of the vectors) projected on plane 
	defined by v3_normal
	"""
	var plane = Plane(v3_normal)
	var p3_on_plane = plane.project(p3)
	var uangle = v3_forward.signed_angle_to(p3_on_plane.normalized(),v3_normal)
	return uangle

func _get_target_lead_position(tgt):
	#TODO implement here call to lead calculation
	return tgt.global_position


func _aim_to(tgt,delta):
	"""NB there is still a little conceptual error here as the logic will align
	the forward vector of the pitch axis to the target but there might be an offset between the axis of the 
	barrel and the former. This might be negligible at long distances but noticeable at short ones.
	TBC if needed to account for it in the calculations
	"""
	var tgt_pos = _get_target_lead_position(tgt)
	var ys_target = yaw_pivot.to_local(tgt_pos)
	var delta_yaw_angle = _minimal_angle(Vector3.UP, Vector3.BACK, ys_target)
	delta_yaw_angle = clampf(delta_yaw_angle,-yaw_speed_rad_sec*delta,yaw_speed_rad_sec*delta)
	yaw_pivot.rotate_object_local(Vector3.UP, delta_yaw_angle)
	
	var ps_target = pitch_pivot.to_local(tgt_pos)
	var delta_pitch_angle = _minimal_angle(Vector3.RIGHT, Vector3.BACK, ps_target)
	
	var neg_p_limit = 0 if pitch_angle<pitch_min else 1.
	var pos_p_limit = 0 if pitch_angle>pitch_max else 1.
	delta_pitch_angle = clampf(
		delta_pitch_angle,
		-pitch_speed_rad_sec*delta*pos_p_limit,
		pitch_speed_rad_sec*delta*neg_p_limit)
	
	#print(delta_pitch_angle)
	pitch_pivot.rotate_object_local(Vector3.RIGHT, delta_pitch_angle)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# calculate target in yaw_space
	yaw_angle = yaw_pivot.transform.basis.z.signed_angle_to(initial_yaw_basis.z,initial_yaw_basis.y)
	pitch_angle = pitch_pivot.transform.basis.z.signed_angle_to(initial_pitch_basis.z,initial_pitch_basis.x)
	#print("yaw : ",rad_to_deg(yaw_angle), " - pitch : ",rad_to_deg(pitch_angle))
	match turret_state:
		TURRET_STATES.IDLE:
			_aim_to($resting_aim,delta)
		TURRET_STATES.TRACKING:
			_aim_to(target,delta)
	
	
func set_target(t):
	if t == null:
		target = null
		turret_state = TURRET_STATES.IDLE
	else:
		target = t
		turret_state = TURRET_STATES.TRACKING
	
func set_material_properties(prop_dict):
	var tiles_col = prop_dict.get("albedo")
	var main_col = prop_dict.get("main_color")
	$yaw_axis/pitch_axis/gun_body.set_instance_shader_parameter("albedo", tiles_col)
	$yaw_axis/pitch_axis/gun_body.set_instance_shader_parameter("main_color", main_col)
	$yaw_axis/pitch_axis/gun_body/gun_barrel2.set_instance_shader_parameter("main_color", main_col)
	$yaw_axis/gun_yaw.set_instance_shader_parameter("main_color", main_col)
	
