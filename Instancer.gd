extends Node3D

@export var model_scene : Resource
@export var cube_size : int
@export var direct_transforms : bool = false

@export var delta:float = 15.


# Called when the node enters the scene tree for the first time.
func _ready():
	var faction = Faction.new()
	for i in range(cube_size):
		for j in range(cube_size):
			for k in range(cube_size):
				var a = model_scene.instantiate()
				if "vessels" in a.get_groups():
					a.faction = faction
				get_parent().add_child.call_deferred(a) # get_tree().get_root()
				a.initial_position = self.global_position + Vector3(i*delta,j*delta,k*delta)+Vector3.ONE*4
				if a.has_method("update_label"): a.update_label("nav "+str(i)+"-"+str(j)+"-"+str(k))
					



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
