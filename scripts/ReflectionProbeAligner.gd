extends ReflectionProbe


var tracked_object

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if tracked_object:
		global_position = tracked_object.global_position
	global_transform.basis = Basis.IDENTITY
