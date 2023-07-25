extends Node3D

@export var velocity_ms:float = 10
@export var lifetime_s:float = 10


var creation_time:float
# Called when the node enters the scene tree for the first time.
func _ready():
	creation_time = Time.get_unix_time_from_system()
	$MeshInstance3D/GPUParticles3D.emitting = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# check lifetime 
	if (Time.get_unix_time_from_system() - creation_time) > lifetime_s:
		queue_free()

	#update
	global_position = global_position + (-global_transform.basis.z * velocity_ms * delta)
	
	#check collisions
	var space_state = get_world_3d().direct_space_state
	# use global coordinates, not local to node
	var look_forward_distance = velocity_ms * delta * 2
	var collision_query = PhysicsRayQueryParameters3D.create(
		global_position, 
		global_position-global_transform.basis.z * look_forward_distance
	)
	var result = space_state.intersect_ray(collision_query)
	if result:
		#print(result)
		var c = result["collider"]
		#test bounce
		var new_dir = global_transform.basis.z.reflect(result.get("normal"))
		self.look_at(global_position+new_dir)
		var exp = load("res://scenes/explosion01.tscn").instantiate()
		get_tree().get_root().add_child(exp)
		exp.global_position = result["position"]
		exp.global_transform = exp.global_transform.looking_at(result["normal"])
		#c.queue_free()
