extends Camera3D
var target

@export var main_camera:Camera3D

var target_pos:Vector3 = Vector3.ZERO
# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(1.5).timeout
	target = get_tree().get_nodes_in_group("vessels").pick_random()
	_switch_target()

func _switch_target():
	while true:
		await get_tree().create_timer(10).timeout
		var followed_vessel = $/root/base.followed_vessel
		var targets = get_tree().get_nodes_in_group("vessels")
		var dist = 9999999.0
		var candidate = null
		for el in targets:
			var cdist = (el.smooth.global_position - main_camera.global_position).length_squared()
			if (cdist < dist) and (el != followed_vessel):
				dist = cdist
				candidate = el
		target = candidate
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target:
		var dist = (target.smooth.global_position - main_camera.global_position).length()
		#var fov0 = rad_to_deg(acos(dist/sqrt(dist*dist+10.0)))
		var fov0 = clamp(rad_to_deg(2.0 * atan(1.0/(2.0*dist))),1.01,120.0)
	
		self.set_fov(fov0)
		target_pos = target_pos.slerp(target.smooth.global_position,0.1)
		self.look_at(target_pos, main_camera.global_transform.basis.y)
		#self.look_at_from_position(main_camera.global_position, target.smooth.global_position)
	#self.global_position = self.global_position.slerp(main_camera.global_position,.5)
