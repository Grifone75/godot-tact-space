extends Node3D

#var old_velocity: Vector3 = Vector3.ZERO
var velocity: Vector3 = Vector3.ZERO
var vmax_length = 5.0
var tgt_pos: Vector3
var focus : Vector3
var distance 
var manager : Drone_manager = null


# Called when the node enters the scene tree for the first time.
func _ready():
	_recalculate_avoidance()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if tgt_pos:
		var delta_pos = tgt_pos - self.global_position
		#old_velocity = velocity
		if delta_pos.length() > 1:
			velocity = velocity.lerp(delta_pos.limit_length(vmax_length),0.05)
		else: 
			velocity = velocity.lerp(Vector3.ZERO,0.05)
		#var deltav = velocity - old_velocity
		#DebugDraw.draw_line(global_position,global_position+global_transform.basis.x * global_transform.basis.tdotx(deltav), Color(.5,0,0))  
			
		self.global_position += velocity * delta
			

func set_focus(center,_distance):
	focus = center
	distance = _distance
	tgt_pos = center + Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)).normalized() * distance
	return self
	
func set_manager(mgr):
	manager = mgr
	manager.add(self)
	return self
	


func _recalculate_avoidance():
	while true:
		if manager:
			var concentration_vector = Vector3.ZERO
			var count = 0
			for el in manager.drone_list:
				if ((el.global_position-self.global_position).length() < 3.0) and (el != self):
					concentration_vector += el.global_position
					count += 1
			if count > 0:
				tgt_pos -= (concentration_vector/count - tgt_pos).normalized()*5.0
			else: 
				tgt_pos = focus + (self.global_position - focus).normalized()*distance
		await get_tree().create_timer(2.).timeout
